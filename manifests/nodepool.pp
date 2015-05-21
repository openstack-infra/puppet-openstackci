# Copyright (c) 2012-2015 Hewlett-Packard Development Company, L.P.
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
# limitations under the License.

# == Class: openstackci::nodepool
#
class openstackci::nodepool (
  $mysql_root_password,
  $mysql_password,
  $nodepool_ssh_private_key = '',
  $nodepool_template = 'nodepool/nodepool.yaml.erb',
  $nodepool_logging_template = 'nodepool/nodepool.logging.conf.erb',
  $vhost_name = $::fqdn,
  $statsd_host = '',
  $jenkins_api_user ='',
  $jenkins_api_key ='',
  $jenkins_credentials_id ='',
  $rackspace_username ='',
  $rackspace_password ='',
  $rackspace_project ='',
  $hpcloud_username ='',
  $hpcloud_password ='',
  $hpcloud_project ='',
  $tripleo_username ='',
  $tripleo_password ='',
  $tripleo_project ='',
  $image_log_document_root = '/var/log/nodepool/image',
  $enable_image_log_via_http = true,
  $project_config_repo = '',
  $clouds_yaml_template = 'nodepool/clouds.yaml.erb',
  $nodepool_cron_cleanup = '*/1 * * * *',
) {

  class { 'project_config':
    url  => $project_config_repo,
  }

  class { '::nodepool':
    mysql_root_password       => $mysql_root_password,
    mysql_password            => $mysql_password,
    nodepool_ssh_private_key  => $nodepool_ssh_private_key,
    vhost_name                => $vhost_name,
    statsd_host               => $statsd_host,
    image_log_document_root   => $image_log_document_root,
    enable_image_log_via_http => $enable_image_log_via_http,
    scripts_dir               => $::project_config::nodepool_scripts_dir,
    elements_dir              => $::project_config::nodepool_elements_dir,
    require                   => $::project_config::config_dir,
    logging_conf_template     => $nodepool_logging_template,
  }

  file { '/etc/nodepool/nodepool.yaml':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'root',
    mode    => '0400',
    content => template($nodepool_template),
    require => [
      File['/etc/nodepool'],
      User['nodepool'],
    ],
  }

  file { '/home/nodepool/.config':
    ensure => directory,
    owner   => 'nodepool',
    group   => 'nodepool',
    require => [
      User['nodepool'],
    ],
  }

  file { '/home/nodepool/.config/openstack':
    ensure => directory,
    owner   => 'nodepool',
    group   => 'nodepool',
    require => [
      File['/home/nodepool/.config'],
    ],
  }

  file { '/home/nodepool/.config/openstack/clouds.yaml':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'nodepool',
    mode    => '0400',
    content => template($clouds_yaml_template),
    require => [
      File['/home/nodepool/.config/openstack'],
      User['nodepool'],
    ],
  }
}
