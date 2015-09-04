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
  $yaml_path = '/etc/project-config/nodepool/nodepool.yaml',
  $oscc_clouds = {},
  $oscc_cache = {},
  $oscc_client = {},
  $environment = {},
  $nodepool_ssh_private_key = '',
  $vhost_name = $::fqdn,
  $statsd_host = '',
  $image_log_document_root = '/var/log/nodepool/image',
  $enable_image_log_via_http = true,
  $project_config_repo = '',
  $jenkins_masters = [],
) {

  if ! defined(Class['project_config']) {
    class { 'project_config':
      url  => $project_config_repo,
    }
  }

  class { '::nodepool':
    mysql_root_password       => $mysql_root_password,
    mysql_password            => $mysql_password,
    nodepool_ssh_private_key  => $nodepool_ssh_private_key,
    vhost_name                => $vhost_name,
    statsd_host               => $statsd_host,
    image_log_document_root   => $image_log_document_root,
    enable_image_log_via_http => $enable_image_log_via_http,
    environment               => $environment,
    scripts_dir               => $::project_config::nodepool_scripts_dir,
    elements_dir              => $::project_config::nodepool_elements_dir,
    require                   => $::project_config::config_dir,
    jenkins_masters           => $jenkins_masters,
  }

  file { '/etc/nodepool/nodepool.yaml':
    ensure  => present,
    source  => $yaml_path,
    owner   => 'nodepool',
    group   => 'root',
    mode    => '0400',
    require => [
      File['/etc/nodepool'],
      User['nodepool'],
      Class['project_config'],
    ],
  }
}
