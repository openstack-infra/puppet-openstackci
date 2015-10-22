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
  $domain,
  $jenkins_ssh_key,
  $swift_authurl = '',
  $swift_user = '',
  $swift_key = '',
  $swift_tenant_name = '',
  $swift_region_name = '',
  $swift_default_container = '',
  $ssl = false,
  $ssl_cert_file = '',
  $ssl_cert_file_contents = '',
  $ssl_key_file = '',
  $ssl_key_file_contents = '',
  $ssl_chain_file = '',
  $ssl_chain_file_contents = '',
) {

  if ! defined(Class['::jenkins::jenkinsuser']) {
    class { '::jenkins::jenkinsuser':
      ssh_key => $jenkins_ssh_key,
    }
  }

  include ::httpd
  include ::httpd::mod::wsgi

  if ! defined(Httpd_mod['rewrite']) {
    httpd_mod { 'rewrite':
      ensure => present,
      before => Service['httpd']
    }
  }

  if ! defined(Httpd_mod['proxy']) {
    httpd_mod { 'proxy':
      ensure => present,
      before => Service['httpd']
    }
  }

  if ! defined(Httpd_mod['proxy_http']) {
    httpd_mod { 'proxy_http':
      ensure => present,
      before => Service['httpd']
    }
  }

  if $ssl == true {
    if ! defined(File['/etc/ssl/certs']) {
      file { '/etc/ssl/certs':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
    }

    if ! defined(File['/etc/ssl/private']) {
      file { '/etc/ssl/private':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0700',
      }
    }

    # To use the standard ssl-certs package snakeoil certificate, leave both
    # $ssl_cert_file and $ssl_cert_file_contents empty. To use an existing
    # certificate, specify its path for $ssl_cert_file and leave
    # $ssl_cert_file_contents empty. To manage the certificate with puppet,
    # provide $ssl_cert_file_contents and optionally specify the path to use for
    # it in $ssl_cert_file.
    if ($ssl_cert_file == '') and ($ssl_cert_file_contents == '') {
      $cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    } else {
      if $ssl_cert_file == '' {
        $cert_file = "/etc/ssl/certs/${::fqdn}.pem"
      } else {
        $cert_file = $ssl_cert_file
      }
      if $ssl_cert_file_contents != '' {
        file { $cert_file:
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => $ssl_cert_file_contents,
          require => File['/etc/ssl/certs'],
        }
      }
    }

    # To use the standard ssl-certs package snakeoil key, leave both
    # $ssl_key_file and $ssl_key_file_contents empty. To use an existing key,
    # specify its path for $ssl_key_file and leave $ssl_key_file_contents empty.
    # To manage the key with puppet, provide $ssl_key_file_contents and
    # optionally specify the path to use for it in $ssl_key_file.
    if ($ssl_key_file == '') and ($ssl_key_file_contents == '') {
      $key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'
    } else {
      if $ssl_key_file == '' {
        $key_file = "/etc/ssl/private/${::fqdn}.key"
      } else {
        $key_file = $ssl_key_file
      }
      if $ssl_key_file_contents != '' {
        file { $key_file:
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0600',
          content => $ssl_key_file_contents,
          require => File['/etc/ssl/private'],
        }
      }
    }

    # To avoid using an intermediate certificate chain, leave both
    # $ssl_chain_file and $ssl_chain_file_contents empty. To use an existing
    # chain, specify its path for $ssl_chain_file and leave
    # $ssl_chain_file_contents empty. To manage the chain with puppet, provide
    # $ssl_chain_file_contents and optionally specify the path to use for it in
    # $ssl_chain_file.
    if ($ssl_chain_file == '') and ($ssl_chain_file_contents == '') {
      $chain_file = ''
    } else {
      if $ssl_chain_file == '' {
        $chain_file = "/etc/ssl/certs/${::fqdn}_intermediate.pem"
      } else {
        $chain_file = $ssl_chain_file
      }
      if $ssl_chain_file_contents != '' {
        file { $chain_file:
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => $ssl_chain_file_contents,
          require => File['/etc/ssl/certs'],
          before  => File[$cert_file],
        }
      }
    }

    ::httpd::vhost { "logs.${domain}":
      port       => 443, # Is required despite not being used.
      docroot    => '/srv/static/logs',
      priority   => '50',
      ssl        => true,
      template   => 'openstackci/logs.vhost.erb',
      vhost_name => "logs.${domain}",
      require    => [
        File['/srv/static/logs'],
        File[$cert_file],
        File[$key_file],
      ],
    }

  } else {

    ::httpd::vhost { "logs.${domain}":
      port       => 80, # Is required despite not being used.
      docroot    => '/srv/static/logs',
      priority   => '50',
      template   => 'openstackci/logs.vhost.erb',
      vhost_name => "logs.${domain}",
      require    => File['/srv/static/logs'],
    }

  }

  ::httpd::vhost { "logs-dev.${domain}":
    port       => 80, # Is required despite not being used.
    docroot    => '/srv/static/logs',
    priority   => '51',
    template   => 'openstackci/logs-dev.vhost.erb',
    vhost_name => "logs-dev.${domain}",
    require    => File['/srv/static/logs'],
  }

  if ! defined(File['/srv/static']) {
    file { '/srv/static':
      ensure => directory,
    }
  }

  file { '/srv/static/logs':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  file { '/srv/static/logs/robots.txt':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstackci/disallow_robots.txt',
    require => File['/srv/static/logs'],
  }

  package { 'keyring':
    ensure   => 'latest',
    provider => 'pip',
  }

  vcsrepo { '/opt/os-loganalyze':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://git.openstack.org/openstack-infra/os-loganalyze',
    require  => Package['keyring'],
  }

  exec { 'install_os-loganalyze':
    command     => 'pip install .',
    cwd         => '/opt/os-loganalyze',
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/os-loganalyze'],
    notify      => Service['httpd'],
  }

  file { '/etc/os_loganalyze':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Vcsrepo['/opt/os-loganalyze'],
  }

  file { '/etc/os_loganalyze/wsgi.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'www-data',
    mode    => '0440',
    content => template('openstackci/os-loganalyze-wsgi.conf.erb'),
    require => File['/etc/os_loganalyze'],
  }

  file { '/etc/os_loganalyze/file_conditions.yaml':
    ensure  => present,
    owner   => 'root',
    group   => 'www-data',
    mode    => '0440',
    source  => 'puppet:///modules/openstackci/os-loganalyze-file_conditions.yaml',
    require => File['/etc/os_loganalyze'],
  }

  vcsrepo { '/opt/devstack-gate':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://git.openstack.org/openstack-infra/devstack-gate',
  }

  file { '/srv/static/logs/help':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/srv/static/logs'],
  }

  file { '/srv/static/logs/help/tempest-logs.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'file:///opt/devstack-gate/help/tempest-logs.html',
    require => [File['/srv/static/logs/help'], Vcsrepo['/opt/devstack-gate']],
  }

  file { '/srv/static/logs/help/tempest-overview.html':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'file:///opt/devstack-gate/help/tempest-overview.html',
    require => [File['/srv/static/logs/help'], Vcsrepo['/opt/devstack-gate']],
  }

  file { '/usr/local/sbin/log_archive_maintenance.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0744',
    source => 'puppet:///modules/openstackci/log_archive_maintenance.sh',
  }

  cron { 'gziprmlogs':
    user        => 'root',
    minute      => '0',
    hour        => '7',
    weekday     => '6',
    command     => 'bash /usr/local/sbin/log_archive_maintenance.sh',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
    require     => File['/usr/local/sbin/log_archive_maintenance.sh'],
  }

}
