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
# [*jenkins_vhost_name*]
#   This is the alternative hostname or FQDN to use by Jenkins.
#   Don't use $vhost_name as it conflicts with zuul
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
# [*java_args_override*]
#   These are the arguments to pass to Java:
#   "-Xloggc:/var/log/jenkins/gc.log -XX:+PrintGCDetails -Xmx12g -Dorg.kohsuke.stapler.compression.CompressionFilter.disabled=true -Djava.util.logging.config.file=/var/lib/jenkins/logger.conf -Dhudson.model.ParametersAction.keepUndefinedParameters=true"
#   Set this parameter through hieradata.
#   To work around the security restrictions that result from upgrading to version > 1.651.2
#   Add the Java system parameter:
#   "-Dhudson.model.ParametersAction.keepUndefinedParameters=true"
#   Please note that adding this parameter is not secure and it exposes a potential jenkins security vulnerability.
#
# [*jenkins_version*]
#   This is a Jenkins version, such as '1.651', 'present' (to install
#   the most recent, and never upgrade), or latest' (to install the most
#   recent version, and upgrade if a more recent version is published).
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
# [*zuulv2*]
#   Set to true to deploy zuul v2 (incompatible with zuul v3).
#   If set, nodepool_revision and zuul_revision have no effect.
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
  $jenkins_vhost_name            = 'jenkins',
  $serveradmin                   = "webmaster@${vhost_name}",
  $jenkins_username              = 'jenkins',
  $jenkins_password              = undef,
  $jenkins_ssh_private_key       = undef,
  $jenkins_ssh_public_key        = undef,
  $java_args_override            = undef,
  $jenkins_version               = 'present',
  $jjb_git_revision              = 'master',
  $jjb_git_url                   = 'https://git.openstack.org/openstack-infra/jenkins-job-builder',

  # Zuul Configurations
  $gerrit_server                 = 'review.openstack.org',
  $gerrit_user                   = undef,
  $gerrit_user_ssh_public_key    = undef,
  $gerrit_user_ssh_private_key   = undef,
  $gerrit_ssh_host_key           = '[review.openstack.org]:29418,[104.130.246.91]:29418,[2001:4800:7819:103:be76:4eff:fe05:8525]:29418 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfsIj/jqpI+2CFdjCL6kOiqdORWvxQ2sQbCzSzzmLXic8yVhCCbwarkvEpfUOHG4eyB0vqVZfMffxf0Yy3qjURrsroBCiuJ8GdiAcGdfYwHNfBI0cR6kydBZL537YDasIk0Z3ILzhwf7474LmkVzS7V2tMTb4ZiBS/jUeiHsVp88FZhIBkyhlb/awAGcUxT5U4QBXCAmerYXeB47FPuz9JFOVyF08LzH9JRe9tfXtqaCNhlSdRe/2pPRvn2EIhn5uHWwATACG9MBdrK8xv8LqPOik2w1JkgLWyBj11vDd5I3IjrmREGw8dqImqp0r6MD8rxqADlc1elfDIXYsy+TVH',
  $git_email                     = undef,
  $git_name                      = undef,
  $log_server                    = undef,
  $smtp_host                     = 'localhost',
  $smtp_default_from             = "zuul@${vhost_name}",
  $smtp_default_to               = "zuul.reports@${vhost_name}",
  $zuulv2                        = true,
  $zuul_revision                 = 'master',
  $zuul_git_source_repo          = 'https://git.openstack.org/openstack-infra/zuul',

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

  if $zuulv2 {

    $nodepool_revision_ = hiera('nodepoolv2_revision', '0.4.0')
    $zuul_revision_ = hiera('zuulv2_revision', '2.6.0')

  class { '::openstackci::jenkins_master':
    vhost_name              => $jenkins_vhost_name,
    serveradmin             => $serveradmin,
    jenkins_ssh_private_key => $jenkins_ssh_private_key,
    jenkins_ssh_public_key  => $jenkins_ssh_public_key,
    jenkins_version         => $jenkins_version,
    manage_jenkins_jobs     => true,
    jenkins_url             => 'http://127.0.0.1:8080/',
    jenkins_username        => $jenkins_username,
    jenkins_password        => $jenkins_password,
    project_config_repo     => $project_config_repo,
    log_server              => $log_server,
    java_args_override      => $java_args_override,
    jjb_git_revision        => $jjb_git_revision,
    jjb_git_url             => $jjb_git_url,
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
    revision             => $zuul_revision_,
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
    revision             => $zuul_revision_,
  }

  class { '::openstackci::nodepool':
    mysql_root_password       => $mysql_root_password,
    mysql_password            => $mysql_nodepool_password,
    nodepool_ssh_private_key  => $jenkins_ssh_private_key,
    revision                  => $nodepool_revision_,
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

  } else {
  # Zuul V3

    $nodepool_revision_ = hiera('nodepool_revision', 'feature/zuulv3')
    $zuul_revision_ = hiera('zuul_revision', 'feature/zuulv3')

    class { '::zookeeper':
      id             => 1,
      purge_interval => 6,
      servers        => [$::fqdn,],
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
      revision             => $zuul_revision_,
      python_version       => 3,
      # TODO(mmedvede): Set all the v3 specific arguments.
    }
  }

}
