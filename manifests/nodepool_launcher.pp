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

# == Class: openstackci::nodepool_launcher
#
class openstackci::nodepool_launcher (
  $oscc_file_contents,
  $nodepool_ssh_private_key = undef,
  $mysql_root_password = '',
  $mysql_password = '',
  $nodepool_ssh_public_key = undef,
  $git_source_repo = 'https://git.openstack.org/openstack-infra/nodepool',
  $revision = 'master',
  $statsd_host = '',
  $project_config_repo = '',
  $project_config_base = undef,
  $launcher_logging_conf_template = 'nodepool/nodepool-launcher.logging.conf.erb',
) {

  if ! defined(Class['project_config']) {
    class { '::project_config':
      url  => $project_config_repo,
      base => $project_config_base,
    }
  }

  class { '::nodepool':
    mysql_root_password      => $mysql_root_password,
    mysql_password           => $mysql_password,
    git_source_repo          => $git_source_repo,
    revision                 => $revision,
    statsd_host              => $statsd_host,
    nodepool_ssh_private_key => $nodepool_ssh_private_key,
    scripts_dir              => $::project_config::nodepool_scripts_dir,
    require                  => $::project_config::config_dir,
    install_mysql            => false,
    install_nodepool_builder => false,
  }

  class { '::nodepool::launcher':
    nodepool_ssh_public_key        => $nodepool_ssh_public_key,
    statsd_host                    => $statsd_host,
    launcher_logging_conf_template => $launcher_logging_conf_template,
  }

  file { '/etc/nodepool/nodepool.yaml':
    ensure  => present,
    source  => $::project_config::nodepool_config_file_zuulv3,
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
