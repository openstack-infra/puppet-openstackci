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
) {

  if ! defined(Class['jenkins::jenkinsuser']) {
    class { 'jenkins::jenkinsuser':
      ssh_key => $jenkins_ssh_key,
    }
  }

  include apache
  include apache::mod::wsgi

  if ! defined(A2mod['rewrite']) {
    a2mod { 'rewrite':
      ensure => present,
    }
  }

  if ! defined(A2mod['proxy']) {
    a2mod { 'proxy':
      ensure => present,
    }
  }

  if ! defined(A2mod['proxy_http']) {
    a2mod { 'proxy_http':
      ensure => present,
    }
  }

  if ! defined(File['/srv/static']) {
    file { '/srv/static':
      ensure => directory,
    }
  }

  apache::vhost { "logs.${domain}":
    port     => 80,
    priority => '50',
    docroot  => '/srv/static/logs',
    require  => File['/srv/static/logs'],
    template => 'openstackci/logs.vhost.erb',
  }

  apache::vhost { "logs-dev.${domain}":
    port     => 80,
    priority => '51',
    docroot  => '/srv/static/logs',
    require  => File['/srv/static/logs'],
    template => 'openstackci/logs-dev.vhost.erb',
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
