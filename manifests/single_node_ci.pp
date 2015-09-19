# Copyright (c) 2015 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License

#
# Puppet class to install a typical 3rd party ci system using Jenkins
# Zuul, Nodepool, Jenkins Job Builder, onto a single VM using the
# specified project-config repository and other configurations.
# Zuul status page will be available on port 80
# Jenkins UI will be available on port 8080

class openstackci::single_node_ci (
  # If your fqdn is not resolvable, use your ip address
  $vhost_name                    = $::fqdn,
  $project_config_repo           = undef,

  # Jenkins Configurations
  $serveradmin                   = "webmaster@${vhost_name}",
  $jenkins_username              = 'jenkins',
  $jenkins_password              = undef,
  $jenkins_ssh_private_key       = undef,
  $jenkins_ssh_public_key        = undef,

  # Zuul Configurations
  $gerrit_server                 = 'review.openstack.org',
  $gerrit_user                   = undef,
  $gerrit_user_ssh_public_key    = undef,
  $gerrit_user_ssh_private_key   = undef,
  $gerrit_ssh_host_key           = 'review.openstack.org,23.253.232.87,2001:4800:7815:104:3bc3:d7f6:ff03:bf5d b8:3c:72:82:d5:9e:59:43:54:11:ef:93:40:1f:6d:a5',
  $git_email                     = undef,
  $git_name                      = undef,
  $log_server                    = undef,
  $smtp_host                     = 'localhost',
  $smtp_default_from             = "zuul@${vhost_name}",
  $smtp_default_to               = "zuul.reports@${vhost_name}",
  $zuul_revision                 = 'master',
  $zuul_git_source_repo          =  'https://git.openstack.org/openstack-infra/zuul',

  # Nodepool configurations
  $mysql_root_password           = undef,
  $mysql_nodepool_password       = undef,
  # The nodepool_jenkins_target must match the name in your
  # project-config's nodepool.yaml targets section
  $nodepool_jenkins_target       = undef,
  $jenkins_api_key               = undef,
  $jenkins_credentials_id        = undef,
  $nodepool_revision             = 'master',
  $nodepool_git_source_repo      = 'https://git.openstack.org/openstack-infra/nodepool',
) {

  class { '::openstackci::jenkins_master':
    # Don't use $vhost_name as it conflicts with zuul
    vhost_name              => 'jenkins',
    serveradmin             => $serveradmin,
    jenkins_ssh_private_key => $jenkins_ssh_private_key,
    jenkins_ssh_public_key  => $jenkins_ssh_public_key,
    manage_jenkins_jobs     => true,
    jenkins_url             => 'http://127.0.0.1:8080/',
    jenkins_username        => $jenkins_username,
    jenkins_password        => $jenkins_password,
    project_config_repo     => $project_config_repo,
  }

  class { '::openstackci::zuul_merger':
    vhost_name           => $vhost_name,
    gearman_server       => 'localhost',
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    # known_hosts_content is set by openstackci::zuul_scheduler
    known_hosts_content  => '',
    zuul_ssh_private_key => $gerrit_user_ssh_private_key,
    zuul_url             => "http://${vhost_name}/p/",
    git_email            => $git_email,
    git_name             => $git_name,
    manage_common_zuul   => false,
    revision             => $zuul_revision,
    git_source_repo      => $zuul_git_source_repo,
  }

  class { '::openstackci::zuul_scheduler':
    vhost_name           => $vhost_name,
    gearman_server       => 'localhost',
    gerrit_server        => $gerrit_server,
    gerrit_user          => $gerrit_user,
    known_hosts_content  => $gerrit_ssh_host_key,
    zuul_ssh_private_key => $gerrit_user_ssh_private_key,
    url_pattern          => "http://${log_server}/{build.parameters[LOG_PATH]}",
    zuul_url             => "http://${vhost_name}/p/",
    job_name_in_report   => true,
    status_url           => "http://${vhost_name}",
    project_config_repo  => $project_config_repo,
    git_email            => $git_email,
    git_name             => $git_name,
    smtp_host            => $smtp_host,
    smtp_default_from    => $smtp_default_from,
    smtp_default_to      => $smtp_default_to,
  }

  class { '::openstackci::nodepool':
    mysql_root_password       => $mysql_root_password,
    mysql_password            => $mysql_nodepool_password,
    nodepool_ssh_private_key  => $jenkins_ssh_private_key,
    revision                  => $nodepool_revision,
    git_source_repo           => $nodepool_git_source_repo,
    environment               => {
      # Set up the key in /etc/default/nodepool, used by the service.
      'NODEPOOL_SSH_KEY' => $jenkins_ssh_public_key
    },
    project_config_repo       => $project_config_repo,
    # Disable nodepool image logs as it conflicts with the zuul status page
    enable_image_log_via_http => false,
    jenkins_masters           => [
      { name        => $nodepool_jenkins_target,
        url         => 'http://localhost:8080/',
        user        => $jenkins_username,
        apikey      => $jenkins_api_key,
        credentials => $jenkins_credentials_id,
      },
    ],
  }

}

