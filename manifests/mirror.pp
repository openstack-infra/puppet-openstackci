# == Class: openstackci::mirror
#
# Configures an Apache cache proxy for the AFS-mirrored repositories used in
# the OpenStack Infra, as well as a reverse proxy for other repositories that
# are not mirrored in the AFS infrastructure.
#
# === Parameters:
#
# [*mirror_root*]
#   (required) Root directory for the mirror
#
# [*vhost_name*]
#   (optional) Virtual host to define in the Apache configuration
#   Defaults to ::fqdn
#
# [*serveraliases*]
#   (optional) List of server aliases to specify in the Apache configuration
#   Defaults to under
#

class openstackci::mirror (
  $mirror_root,
  $vhost_name = $::fqdn,
  $serveraliases = undef,
) {
  $pypi_root = "${mirror_root}/pypi"
  $wheel_root = "${mirror_root}/wheel"
  $ceph_deb_hammer_root = "${mirror_root}/ceph-deb-hammer"
  $ceph_deb_jewel_root = "${mirror_root}/ceph-deb-jewel"
  $ceph_deb_luminous_root = "${mirror_root}/ceph-deb-luminous"
  $ceph_deb_mimic_root = "${mirror_root}/ceph-deb-mimic"
  $gem_root = "${mirror_root}/gem"

  $www_base = '/var/www'
  $www_root = "${www_base}/mirror"

  #####################################################
  # Build Apache Webroot
  file { "${www_base}":
    ensure => directory,
    owner  => root,
    group  => root,
  }

  file { "${www_root}":
    ensure  => directory,
    owner   => root,
    group   => root,
    require => [
      File["${www_base}"],
    ]
  }

  # Create the symlink to pypi.
  file { "${www_root}/pypi":
    ensure  => link,
    target  => "${pypi_root}/web",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to wheel.
  file { "${www_root}/wheel":
    ensure  => link,
    target  => "${wheel_root}",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to centos
  file { "${www_root}/centos":
    ensure  => link,
    target  => "${mirror_root}/centos",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to debian
  file { "${www_root}/debian":
    ensure  => link,
    target  => "${mirror_root}/debian",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to debian-security
  file { "${www_root}/debian-security":
    ensure  => link,
    target  => "${mirror_root}/debian-security",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to Debian OpenStack Packaging Team reprepro.
  file { "${www_root}/debian-openstack":
    ensure  => link,
    target  => "${mirror_root}/debian-openstack",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to rdo
  file { "${www_root}/rdo":
    ensure  => absent,
  }

  # Create the symlink to epel
  file { "${www_root}/epel":
    ensure  => link,
    target  => "${mirror_root}/epel",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to yum-puppetlabs
  file { "${www_root}/yum-puppetlabs":
    ensure  => link,
    target  => "${mirror_root}/yum-puppetlabs",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to fedora
  file { "${www_root}/fedora":
    ensure  => link,
    target  => "${mirror_root}/fedora",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to openSUSE
  file { "${www_root}/opensuse":
    ensure  => link,
    target  => "${mirror_root}/opensuse",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to Ubuntu
  file { "${www_root}/ubuntu":
    ensure  => link,
    target  => "${mirror_root}/ubuntu",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to Ubuntu ports
  file { "${www_root}/ubuntu-ports":
    ensure  => link,
    target  => "${mirror_root}/ubuntu-ports",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to ceph-deb-hammer.
  file { "${www_root}/ceph-deb-hammer":
    ensure  => link,
    target  => "${ceph_deb_hammer_root}",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to ceph-deb-jewel.
  file { "${www_root}/ceph-deb-jewel":
    ensure  => link,
    target  => "${ceph_deb_jewel_root}",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to ceph-deb-luminous.
  file { "${www_root}/ceph-deb-luminous":
    ensure  => link,
    target  => "${ceph_deb_luminous_root}",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to ceph-deb-mimic.
  file { "${www_root}/ceph-deb-mimic":
    ensure  => link,
    target  => "${ceph_deb_mimic_root}",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to Ubuntu Cloud Archive.
  file { "${www_root}/ubuntu-cloud-archive":
    ensure  => link,
    target  => "${mirror_root}/ubuntu-cloud-archive",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to deb-docker.
  file { "${www_root}/deb-docker":
    ensure  => link,
    target  => "${mirror_root}/deb-docker",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  # Create the symlink to Ubuntu Puppetlabs.
  file { "${www_root}/apt-puppetlabs":
    ensure  => link,
    target  => "${mirror_root}/apt-puppetlabs",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  file { "${www_root}/gem":
    ensure  => link,
    target  => "${gem_root}",
    owner   => root,
    group   => root,
    require => [
      File["${www_root}"],
    ]
  }

  file { "${www_root}/robots.txt":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstackci/disallow_robots.txt',
    require => File["${www_root}"],
  }

  #####################################################
  # Build VHost
  include ::httpd

  file { '/opt/apache_cache':
    ensure => absent,
    force  => true,
  }

  file { '/var/cache/apache2/proxy':
    ensure  => directory,
    path    => '/var/cache/apache2/proxy',
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0755',
    require => Class['httpd']
  }

  if ! defined(Httpd::Mod['rewrite']) {
    httpd::mod { 'rewrite':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['substitute']) {
    httpd::mod { 'substitute':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['cache']) {
    httpd::mod { 'cache':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['cache_disk']) {
    httpd::mod { 'cache_disk':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['proxy']) {
    httpd::mod { 'proxy':
      ensure => present,
    }
  }

  if ! defined(Httpd::Mod['proxy_http']) {
    httpd::mod { 'proxy_http':
      ensure => present,
    }
  }

  ::httpd::vhost { $vhost_name:
    port          => 80,
    priority      => '50',
    docroot  => "${www_root}",
    template      => 'openstackci/mirror.vhost.erb',
    serveraliases => $serveraliases,
    require       => [
      File["${www_root}"],
    ]
  }

  # Cache cleanup

  # The apache2-utils package is only required for Debian/Ubuntu
  # In CentOS/RHEL, htcacheclean is part of the httpd package
  if $::osfamily == 'Debian' {
    package { 'apache2-utils':
      ensure => present,
    }
  }

  cron { 'apache-cache-cleanup':
    # Clean apache cache once an hour, keep size down to 50GiB.
    minute      => '0',
    hour        => '*',
    command     => 'flock -n /var/run/htcacheclean.lock htcacheclean -n -p /var/cache/apache2/proxy -t -l 40960M > /dev/null',
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    require     => [
          File['/var/cache/apache2/proxy'],
          Package['apache2-utils'],
      ],
  }

  class { '::httpd::logrotate':
    options => [
      'daily',
      'missingok',
      'rotate 7',
      'compress',
      'delaycompress',
      'notifempty',
      'create 640 root adm',
    ],
  }
}
