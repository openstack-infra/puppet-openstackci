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

# == Class: single_node_ci
#
# This class will setup a typical 3rd party CI system using Jenkins
# Zuul, Nodepool, Jenkins Job Builder, onto a single host. It requires
# a 'project-config' data repository to configure these services.
#
# Zuul status page will be available on port 80
# Jenkins UI will be available on port 8080
#
# === Parameters
#
# [*vhost_name*]
#  This is the FQDN of the host running the CI system managed by this class.
#  If you don't have one that resolves correctly, use the host's IP address.
#
# [*project_config_repo*]
#   This is the git URL to the  project-config repo that contains all the
#   jenkins jobs, nodepool configurations, and zuul configurations.
#
# [*serveradmin*]
#  The e-mail address of the owner of the CI system
#
# [*jenkins_username*]
#    If you have Jenkins secured, this is the username Jenkins Job Builder
#    will use to manage all Jenkins jobs. Otherwise the value is ignored.
#
# [*jenkins_password*]
#   If you have Jenkins secured, this is the password associated with the
#   jenkins_username. Otherwise the value is ignored.
#
# [*jenkins_ssh_private_key*]
#   This is the private key the Jenkins master will use to login to
#   Jenkins slaves.
#
# [*jenkins_ssh_public_key*]
#   This is the public key associated with jenkins_ssh_private_key.
#   The public key should not have any white space. Omit the 'ssh-rsa' prefix
#   and comment section / e-mail address suffix.
#
# [*gerrit_server*]
#   This is the host name of the gerrit server this CI system will be
#   listening for events.
#
# [*gerrit_user*]
#   This is the username to access the gerrit server's event stream.
#   You can look up the gerrit username from the gerrit server, under
#   'settings', in the 'profile' section.
#
# [*gerrit_user_ssh_public_key*]
#   This is the public key registered for the gerrit_user's gerrit account.
#   The public key should not have any white space. Omit the 'ssh-rsa' prefix
#   and comment section / e-mail address suffix.
#
# [*gerrit_user_ssh_private_key*]
#   This is the private key associated with the gerrit_user_ssh_public_key.
#
# [*gerrit_ssh_host_key*]
#   This is the host key of the gerrit server.
#
# [*git_email*]
#   The e-mail address for zuul to use for internal git commits.
#
# [*git_name*]
#   The name for zuul to use for internal git commits.
#
# [*log_server*]
#   This is the FQDN/IP address of the log server where log files are uploaded
#   after a job finishes. Jenkins will use its jenkins_ssh_private_key to scp
#   job log files files to it.
#
# [*smtp_host*]
#   The smtp hostname to use for zuul to send notification e-mails
#   if configured to do so in project-config/zuul/layout/layout.yaml
#
# [*smtp_default_from*]
#   The default 'from' e-mail address zuul will use when it sends
#   notification e-mails.
#
# [*smtp_default_to*]
#   The default 'to' e-mail address zuul will use when it sends
#   notification e-mails.
#
# [*zuul_revision*]
#   The branch name used to install zuul.
#
# [*zuul_git_source_repo*]
#   The zuul git source repository to install zuul.
#
# [*oscc_file_contents*]
#   The multi-line contents of os-client-config.
#   This allows the nodepool.yaml file provided to not contain any sensitive
#   provider passwords. See configuration guide for more details:
#   https://git.openstack.org/cgit/openstack/os-client-config/tree/README.rst
#
# [*mysql_root_password*]
#   This is the root mysql password. If mysql is not yet installed,
#   this will be the password. Otherwise, if mysql is already installed,
#   this is the root password needed to setup the nodepool mysql user and
#   database.
#
# [*mysql_nodepool_password*]
#   This is the nodepool user's mysql password.
#
# [*nodepool_jenkins_target*]
#   This is the name of the Jenkins target found in the
#   project-config/nodepool/nodepool.yaml file.
#
# [*jenkins_api_key*]
#   If Jenkins is secured, this the Jenkins API Token need to access the Jenkins API.
#   It is provided in Jenkins UI --> Manage Jenkins --> Manage Users --> 'jenkins user'
#   --> Configure --> Show API Token. Otherwise it is ignored.
#
# [*jenkins_credentials_id*]
#   If Jenkins is secured, this parameter needs to match the id field of this element:
#   <com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.6">
#   inside this file: /var/lib/jenkins/credentials.xml
#   and associated with this this key 'jenkins_ssh_private_key'. Otherwise it is ignored.
#
# [*nodepool_revision*]
#   The branch name used to install nodepool.
#
# [*nodepool_git_source_repo*]
#   The nodepool git source repository to install nodepool.
#

class openstackci::single_node_ci (
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
  $oscc_file_contents            = undef,
  $mysql_root_password           = undef,
  $mysql_nodepool_password       = undef,
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
    log_server              => $log_server,
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
    revision             => $zuul_revision,
  }

  class { '::openstackci::nodepool':
    mysql_root_password       => $mysql_root_password,
    mysql_password            => $mysql_nodepool_password,
    nodepool_ssh_private_key  => $jenkins_ssh_private_key,
    revision                  => $nodepool_revision,
    git_source_repo           => $nodepool_git_source_repo,
    oscc_file_contents        => $oscc_file_contents,
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
