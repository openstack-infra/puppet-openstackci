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
# A sample puppet node configuration that installs and configures Jenkins,
# Zuul, Nodepool, Jenkins Job Builder, onto a single VM using the
# specified project-config repository and other configurations stored in hiera.
# Zuul status page will be available on port 80
# Jenkins UI will be available on port 8080
# Default values are provided where reasonable options are available assuming
# use of the review.openstack.org Gerrit server and for an unsecured Jenkins.
# All others must be provided by hiera. See the related single_node_ci_hiera.yaml
# which includes all optional and required parameters.

node default {
  # If the fqdn is not resolvable, use its ip address
  $vhost_name = hiera('vhost_name', $::fqdn)

  class { '::openstackci::single_node_ci':
    vhost_name                  => $vhost_name,
    project_config_repo         => hiera('project_config_repo'),
    serveradmin                 => hiera('serveradmin', "webmaster@${vhost_name}"),
    jenkins_username            => hiera('jenkins_username', 'jenkins'),
    jenkins_password            => hiera('jenkins_password', 'XXX'),
    jenkins_ssh_private_key     => hiera('jenkins_ssh_private_key'),
    jenkins_ssh_public_key      => hiera('jenkins_ssh_public_key'),
    gerrit_server               => hiera('gerrit_server', 'review.openstack.org'),
    gerrit_user                 => hiera('gerrit_user'),
    gerrit_user_ssh_public_key  => hiera('gerrit_user_ssh_public_key'),
    gerrit_user_ssh_private_key => hiera('gerrit_user_ssh_private_key'),
    gerrit_ssh_host_key         => hiera('gerrit_ssh_host_key',
      'review.openstack.org,23.253.232.87,2001:4800:7815:104:3bc3:d7f6:ff03:bf5d b8:3c:72:82:d5:9e:59:43:54:11:ef:93:40:1f:6d:a5'),
    git_email                   => hiera('git_email'),
    git_name                    => hiera('git_name'),
    log_server                  => hiera('log_server'),
    smtp_host                   => hiera('smtp_host', 'localhost'),
    smtp_default_from           => hiera('smtp_default_from', "zuul@${vhost_name}"),
    smtp_default_to             => hiera('smtp_default_to', "zuul.reports@${vhost_name}"),
    zuul_revision               => hiera('zuul_revision', 'master'),
    zuul_git_source_repo        => hiera('zuul_git_source_repo',
      'https://git.openstack.org/openstack-infra/zuul'),
    oscc_file_contents          => hiera('oscc_file_contents', ''),
    mysql_root_password         => hiera('mysql_root_password'),
    mysql_nodepool_password     => hiera('mysql_nodepool_password'),
    nodepool_jenkins_target     => hiera('nodepool_jenkins_target', 'jenkins1'),
    jenkins_api_key             => hiera('jenkins_api_key', 'XXX'),
    jenkins_credentials_id      => hiera('jenkins_credentials_id', 'XXX'),
    nodepool_revision           => hiera('nodepool_revision', 'master'),
    nodepool_git_source_repo    => hiera('nodepool_git_source_repo',
      'https://git.openstack.org/openstack-infra/nodepool'),
  }
}

