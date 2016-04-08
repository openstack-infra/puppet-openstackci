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
  $mysql_password,
  $mysql_root_password,
  $oscc_file_contents,
  $builder_logging_conf_template = 'nodepool/nodepool-builder.logging.conf.erb',
  $enable_image_log_via_http     = true,
  $environment                   = {},
  $git_source_repo               = 'https://git.openstack.org/openstack-infra/nodepool',
  $image_log_document_root       = '/var/log/nodepool/image',
  $image_log_periodic_cleanup    = true,
  $install_mysql                 = true,
  $jenkins_masters               = [],
  $logging_conf_template         = 'nodepool/nodepool.logging.conf.erb',
  $mysql_bind_address            = '127.0.0.1',
  $mysql_default_engine          = 'InnoDB',
  $mysql_db_name                 = 'nodepool',
  $mysql_max_connections         = 8192,
  $mysql_user_host_access        = 'localhost',
  $mysql_user_name               = 'nodepool',
  $nodepool_ssh_private_key      = '',
  $project_config_repo           = '',
  $revision                      = 'master',
  $statsd_host                   = '',
  $user                          = 'nodepool',
  $vhost_name                    = $::fqdn,
  $yaml_path                     = '/etc/project-config/nodepool/nodepool.yaml',
) {

  if ! defined(Class['project_config']) {
    class { 'project_config':
      url  => $project_config_repo,
    }
  }

  if($install_mysql) {
    class { '::nodepool::mysql' :
      $mysql_bind_address     => $mysql_bind_address,
      $mysql_default_engine   => $mysql_default_engine,
      $mysql_db_name          => $mysql_db_name,
      $mysql_max_connections  => $mysql_max_connections,
      $mysql_root_password    => $mysql_root_password,
      $mysql_user_host_access => $mysql_user_host_access,
      $mysql_user_name        => $mysql_user_name,
      $mysql_user_password    => $mysql_password,
    }
  }

  class { '::nodepool' :
    mysql_root_password           => $mysql_root_password,
    mysql_password                => $mysql_password,
    nodepool_ssh_private_key      => $nodepool_ssh_private_key,
    git_source_repo               => $git_source_repo,
    revision                      => $revision,
    vhost_name                    => $vhost_name,
    statsd_host                   => $statsd_host,
    image_log_document_root       => $image_log_document_root,
    image_log_periodic_cleanup    => $image_log_periodic_cleanup,
    enable_image_log_via_http     => $enable_image_log_via_http,
    environment                   => $environment,
    scripts_dir                   => $::project_config::nodepool_scripts_dir,
    elements_dir                  => $::project_config::nodepool_elements_dir,
    require                       => $::project_config::config_dir,
    logging_conf_template         => $logging_conf_template,
    builder_logging_conf_template => $builder_logging_conf_template,
    jenkins_masters               => $jenkins_masters,
  }

  file { '/etc/nodepool/nodepool.yaml' :
    ensure  => present,
    source  => $yaml_path,
    owner   => $user,
    group   => $user,
    mode    => '0400',
    require => [
      File['/etc/nodepool'],
      User[$user],
      Class['project_config'],
    ],
  }

  file { '/home/nodepool/.config' :
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => [
      File['/home/nodepool'],
      User[$user],
    ],
  }

  file { '/home/nodepool/.config/openstack' :
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => [
      File['/home/nodepool/.config'],
      User[$user],
    ],
  }

  file { '/home/nodepool/.config/openstack/clouds.yaml' :
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0400',
    content => $oscc_file_contents,
    require => [
      File['/home/nodepool/.config/openstack'],
      User[$user],
    ],
  }

}
