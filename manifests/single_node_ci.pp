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

# == Class: openstackci::single_node_ci
#
# Puppet module that installs Jenkins, Zuul, Jenkins Job Builder,
# and installs JJB and Zuul configuration files from a repository
# called the "project-config data repository".

class openstackci::single_node_ci(
  $vhost_name = $::fqdn,
  $project_config_repo = undef,

  #Jenkins Configurations
  $serveradmin = "webmaster@${::fqdn}",
  $jenkins_username = 'jenkins',
  $jenkins_password = '',
  $jenkins_ssh_private_key = undef,
  $jenkins_ssh_public_key = undef,

  # Zuul Configurations
  $gerrit_server = 'review.openstack.org',
  $gerrit_user = undef,
  $gerrit_user_ssh_public_key = undef,
  $gerrit_user_ssh_private_key = undef,
  $gerrit_ssh_host_key = 'review.openstack.org,23.253.232.87,2001:4800:7815:104:3bc3:d7f6:ff03:bf5d b8:3c:72:82:d5:9e:59:43:54:11:ef:93:40:1f:6d:a5',
  $git_email = 'your.email@example.com',
  $git_name = 'Your Name',
  $logs_url_pattern = 'http://logs.your.domain.com/{build.parameters[LOG_PATH]}',
  $smtp_host = 'localhost',
  $zuul_revision = 'master',
  $zuul_git_source_repo = 'https://git.openstack.org/openstack-infra/zuul',

  # Nodepool configurations
  $mysql_root_password = undef,
  $mysql_nodepool_password = undef,
  # The Jenkins API Key is needed if you have a password for Jenkins user inside Jenkins
  # Jenkins keys are used by jenkins/nodepool provider to enable communication between the jenkins master and slaves
  $jenkins_api_key = '',
  # The Jenkins credentials_id should match the id field of this element:
  # <com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.6">
  # inside this file:
  # /var/lib/jenkins/credentials.xml
  # which is the private key used by the jenkins master to log into the jenkins
  # slave node to install and register the node as a jenkins slave
  $jenkins_credentials_id = '',
  $nodepool_revision = 'master',
  $nodepool_git_source_repo = 'https://git.openstack.org/openstack-infra/nodepool',
){

  class { '::openstackci::jenkins_master':
    vhost_name              => 'jenkins', # Don't use $vhost_name as it conflicts with zuul
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
    known_hosts_content  => '', # Leave blank as it is set by openstackci::zuul_scheduler
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
    url_pattern          => $logs_url_pattern,
    zuul_url             => "http://${vhost_name}/p/",
    job_name_in_report   => true,
    status_url           => "http://${vhost_name}",
    project_config_repo  => $project_config_repo,
    git_email            => $git_email,
    git_name             => $git_name,
    smtp_host            => $smtp_host,
    revision             => $zuul_revision,
#   git_source_repo      => $zuul_git_source_repo,
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
    enable_image_log_via_http => false,
    jenkins_masters           => [
      { name        => 'local-jenkins',
        url         => 'http://localhost:8080/',
        user        => $jenkins_username,
        apikey      => $jenkins_api_key,
        credentials => $jenkins_credentials_id,
      },
    ],
  }

}

