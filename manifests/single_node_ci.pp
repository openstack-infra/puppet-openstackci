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
# called the "data repository".

class openstackci::single_node_ci(
  $serveradmin = 'stack',
  $jenkins_username = 'jenkins',
  $jenkins_jobs_password = 'your jenkins password',
  $vhost_name = $::fqdn,
  $project_config_repo = 'https://github.com/your-account/project-config',
  $git_email = 'your.email@domain.com',
  $git_name = 'Your Name',
  $gerrit_server = 'review.openstack.org',
  $gerrit_user = 'Your Gerrit User',
  $gerrit_user_ssh_public_key = 'AAAAB+your+key+123',
  $gerrit_user_ssh_private_key = undef,
  $gerrit_ssh_host_key = 'review.openstack.org,23.253.232.87,2001:4800:7815:104:3bc3:d7f6:ff03:bf5d b8:3c:72:82:d5:9e:59:43:54:11:ef:93:40:1f:6d:a5',
  $logs_url_pattern = 'http://logs.your.domain.com/{build.parameters[LOG_PATH]}',
  $smtp_host = 'smtp3.hp.com',
){

  class { '::openstackci::jenkins_master':
    serveradmin             => $serveradmin,
    jenkins_username        => $jenkins_username,
    jenkins_password        => $jenkins_jobs_password,
    vhost_name              => $vhost_name,
    #TODO: Any reason jenkins cannot use the same public/private key pair as gerrit?
    jenkins_ssh_private_key => $gerrit_user_ssh_private_key,
    jenkins_ssh_public_key  => $gerrit_user_ssh_public_key,
    manage_jenkins_jobs     => true,
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
  }

#Exlude nodepool until it's ready. Focus on validating the above first
#  class { '::openstackci::nodepool':
#    mysql_root_password      => hiera('mysql_root_password', 'XXX'),
#    mysql_password           => hiera('mysql_password', 'XXX'),
#    yaml_path                => '/etc/project-config/nodepool/nodepool.yaml',
#    nodepool_ssh_private_key => hiera('jenkins_ssh_private_key', 'XXX'),
#    environment              => {
#      # Set up the key in /etc/default/nodepool, used by the service.
#      'NODEPOOL_SSH_KEY' => $jenkins_ssh_public_key
#    },
#    project_config_repo      => $project_config_repo,
#    jenkins_masters          => [
#      { name        => 'local-jenkins',
#        url         => 'http://localhost:8080/',
#        user        => $jenkins_username,
#        apikey      => hiera('jenkins_api_key', 'XXX'),
#        credentials => hiera('jenkins_credentials_id', 'XXX'),
#      },
#    ],
#  }

}

