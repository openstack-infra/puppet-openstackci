# Copyright (c) 2012-2015 Hewlett-Packard Development Company, L.P.
# Copyright (c) 2015 Red Hat, Inc.
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

# == Class: openstackci::zuul_scheduler
#
class openstackci::zuul_scheduler(
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gerrit_server = '',
  $gerrit_user = '',
  $gerrit_ssh_host_key = '',
  $gerrit_ssh_host_identity = [
    'review.openstack.org',
    '23.253.232.87',
    '2001:4800:7815:104:3bc3:d7f6:ff03:bf5d',
  ],
  $zuul_ssh_private_key = '',
  $url_pattern = '',
  $zuul_url = '',
  $status_url = 'http://status.openstack.org/zuul/',
  $swift_authurl = '',
  $swift_auth_version = '',
  $swift_user = '',
  $swift_key = '',
  $swift_tenant_name = '',
  $swift_region_name = '',
  $swift_default_container = '',
  $swift_default_logserver_prefix = '',
  $swift_default_expiry = 7200,
  $proxy_ssl_cert_file_contents = '',
  $proxy_ssl_key_file_contents = '',
  $proxy_ssl_chain_file_contents = '',
  $statsd_host = '',
  $gearman_workers = [],
  $project_config_repo = '',
  $git_email = 'jenkins@openstack.org',
  $git_name = 'OpenStack Jenkins',
) {

  $gerrit_ssh_ident = inline_template("<%= (@gerrit_ssh_host_identity).join(',') %> <%= @gerrit_ssh_host_key %>")

  class { 'project_config':
    url  => $project_config_repo,
  }

  class { '::zuul':
    vhost_name                     => $vhost_name,
    gearman_server                 => $gearman_server,
    gerrit_server                  => $gerrit_server,
    gerrit_user                    => $gerrit_user,
    zuul_ssh_private_key           => $zuul_ssh_private_key,
    url_pattern                    => $url_pattern,
    zuul_url                       => $zuul_url,
    job_name_in_report             => true,
    status_url                     => $status_url,
    statsd_host                    => $statsd_host,
    git_email                      => $git_email,
    git_name                       => $git_name,
    swift_authurl                  => $swift_authurl,
    swift_auth_version             => $swift_auth_version,
    swift_user                     => $swift_user,
    swift_key                      => $swift_key,
    swift_tenant_name              => $swift_tenant_name,
    swift_region_name              => $swift_region_name,
    swift_default_container        => $swift_default_container,
    swift_default_logserver_prefix => $swift_default_logserver_prefix,
    swift_default_expiry           => $swift_default_expiry,
    proxy_ssl_cert_file_contents   => $proxy_ssl_cert_file_contents,
    proxy_ssl_key_file_contents    => $proxy_ssl_key_file_contents,
    proxy_ssl_chain_file_contents  => $proxy_ssl_chain_file_contents,
  }

  class { '::zuul::server':
    layout_dir => $::project_config::zuul_layout_dir,
    require    => $::project_config::config_dir,
  }

  if $gerrit_ssh_host_key != '' {
    file { '/home/zuul/.ssh':
      ensure  => directory,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0700',
      require => Class['::zuul'],
    }
    file { '/home/zuul/.ssh/known_hosts':
      ensure  => present,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0600',
      content => $gerrit_ssh_ident,
      replace => true,
      require => File['/home/zuul/.ssh'],
    }
  }

  file { '/etc/zuul/logging.conf':
    ensure => present,
    source => 'puppet:///modules/openstack_project/zuul/logging.conf',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/gearman-logging.conf':
    ensure => present,
    source => 'puppet:///modules/openstack_project/zuul/gearman-logging.conf',
    notify => Exec['zuul-reload'],
  }

  file { '/etc/zuul/merger-logging.conf':
    ensure => present,
    source => 'puppet:///modules/openstack_project/zuul/merger-logging.conf',
  }
}
