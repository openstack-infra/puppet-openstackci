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

# == Class: openstackci::nodepool_builder
#
class openstackci::nodepool_builder (
  $oscc_file_contents,
  $mysql_root_password = '',
  $mysql_password = '',
  $git_source_repo = 'https://git.openstack.org/openstack-infra/nodepool',
  $revision = 'master',
  $environment = {},
  $vhost_name = $::fqdn,
  $statsd_host = '',
  $image_log_document_root = '/var/log/nodepool/image',
  $image_log_periodic_cleanup = true,
  $enable_image_log_via_http = true,
  $upload_log_document_root = '/var/log/nodepool/upload',
  $upload_log_periodic_cleanup = true,
  $enable_upload_log_via_http = false,
  $project_config_repo = '',
  $project_config_base = undef,
  $builder_logging_conf_template = 'nodepool/nodepool-builder.logging.conf.erb',
  $build_workers = '1',
  $upload_workers = '4',
) {

  if ! defined(Class['project_config']) {
    class { '::project_config':
      url  => $project_config_repo,
      base => $project_config_base,
    }
  }

  class { '::nodepool':
    mysql_root_password         => $mysql_root_password,
    mysql_password              => $mysql_password,
    git_source_repo             => $git_source_repo,
    revision                    => $revision,
    vhost_name                  => $vhost_name,
    statsd_host                 => $statsd_host,
    image_log_document_root     => $image_log_document_root,
    image_log_periodic_cleanup  => $image_log_periodic_cleanup,
    enable_image_log_via_http   => $enable_image_log_via_http,
    upload_log_document_root    => $upload_log_document_root,
    upload_log_periodic_cleanup => $upload_log_periodic_cleanup,
    enable_upload_log_via_http  => $enable_upload_log_via_http,
    environment                 => $environment,
    scripts_dir                 => $::project_config::nodepool_scripts_dir,
    elements_dir                => $::project_config::nodepool_elements_dir,
    require                     => $::project_config::config_dir,
    install_mysql               => false,
    install_nodepool_builder    => false,
  }

  class { '::nodepool::builder':
    statsd_host                   => $statsd_host,
    image_log_document_root       => $image_log_document_root,
    builder_logging_conf_template => $builder_logging_conf_template,
    environment                   => $environment,
    build_workers                 => $build_workers,
    upload_workers                => $upload_workers,
  }

  file { '/etc/nodepool/nodepool.yaml':
    ensure  => present,
    source  => $::project_config::nodepool_config_file,
    owner   => 'nodepool',
    group   => 'root',
    mode    => '0400',
    require => [
      File['/etc/nodepool'],
      User['nodepool'],
      Class['project_config'],
    ],
  }

  file { '/home/nodepool/.config':
    ensure  => directory,
    owner   => 'nodepool',
    group   => 'nodepool',
    require => [
      User['nodepool'],
    ],
  }

  file { '/home/nodepool/.config/openstack':
    ensure  => directory,
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
    content => $oscc_file_contents,
    require => [
      File['/home/nodepool/.config/openstack'],
      User['nodepool'],
    ],
  }

}
