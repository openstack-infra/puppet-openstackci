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

# == Class: openstackci::logserver
#
class openstackci::logserver (
  $config_general_file_content = undef,
  $cron_jobs                   = {},
  $etc_conf_dir                = '/etc/os_loganalyze',
  $file_conditions_content     = undef,
  $file_conditions_path        = '/etc/os_loganalyze/file_conditions.yaml',
  $package                     = 'python-os-loganalyze',
  $service_fqdn                = 'loganalyze.test.local',
  $user                        = 'loganalyze',
  $user_home_dir               = '/var/lib/loganalyze',
  $uwsgi_app_name              = 'wsgi',
  $uwsgi_chdir                 = '/usr/lib/python2.7/dist-packages/os_loganalyze',
  $uwsgi_socket                = '127.0.0.1:4689',
) {

  if($package) {
    package { $package :
      ensure => 'latest',
    }
  }

  $dir_paths = hiera_hash('openstackci::logserver::log_dir_paths', {})

  if($dir_paths) {
    create_resources(file, $dir_paths, {
      ensure => 'directory',
      before => Class['fuel_project::apps::seed']
    })
  }

  group { $user:
    ensure => 'present',
  }

  user { $user :
    ensure     => 'present',
    home       => $user_home_dir,
    shell      => '/bin/false',
    gid        => $user,
    system     => true,
    managehome => true,
    require    => Group[$user],
  }

  uwsgi::application { $uwsgi_app_name :
    plugins   => 'python',
    workers   => $::processorcount,
    uid       => $user,
    gid       => $user,
    socket    => $uwsgi_socket,
    master    => true,
    vacuum    => true,
    chdir     => $uwsgi_chdir,
    module    => $uwsgi_app_name,
    subscribe => Package[$package],
  }

  file { $etc_conf_dir :
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[$package],
  }

  if($config_general_file_content) {
    file { "${etc_conf_dir}/loganalyze.conf" :
      ensure  => 'present',
      owner   => $user,
      group   => $user,
      mode    => '0444',
      content => template('openstackci/os-loganalyze.conf.erb'),
      require => File[$etc_conf_dir],
    }
  }

  if($file_conditions_content) {
    file { $file_conditions_path :
      ensure  => 'present',
      owner   => $user,
      group   => $user,
      mode    => '0444',
      content => $file_conditions_content,
      require => File[$etc_conf_dir],
    }
  }

  include ::nginx

  ::nginx::resource::vhost { 'logserver' :
    ensure              => 'present',
    listen_port         => 80,
    server_name         => [$service_fqdn],
    access_log          => $nginx_access_log,
    error_log           => $nginx_error_log,
    format_log          => $nginx_log_format,
    uwsgi               => $uwsgi_socket,
    location_cfg_append => {
      uwsgi_connect_timeout => '3m',
      uwsgi_read_timeout    => '3m',
      uwsgi_send_timeout    => '3m',
    }
  }

  create_resources(cron, $cron_jobs, {
      ensure => 'present',
  })

}
