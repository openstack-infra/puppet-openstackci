# == Class: openstackci::mirror
#
# Configures an Apache cache proxy for the AFS-mirrored repositories used in
# the OpenStack Infra, as well as a reverse proxy for other repositories that
# are not mirrored in the AFS infrastructure.
#
# Supports both CentOS and Debian-based mirrors.
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
  case $::osfamily {
    'RedHat': {
      $cache_root = '/var/cache/httpd/proxy'
      $cleanup_requires = File['/var/cache/apache2/proxy']
      $www_user = 'apache'
      $www_group = 'apache'
    }
    'Debian': {
      $cache_root = '/var/cache/apache2/proxy'
      $cleanup_requires = [
          File['/var/cache/apache2/proxy'],
          Package['apache2-utils'],
      ]
      $www_user = 'www-data'
      $www_group = 'www-data'
    }
    default: {
      $cache_root = '/var/cache/apache2/proxy'
      $cleanup_requires = [
          File['/var/cache/apache2/proxy'],
          Package['apache2-utils'],
      ]
      $www_user = 'www-data'
      $www_group = 'www-data'
    }
  }

  $pypi_root = "${mirror_root}/pypi"
  $wheel_root = "${mirror_root}/wheel"
  $ceph_deb_hammer_root = "${mirror_root}/ceph-deb-hammer"
  $ceph_deb_jewel_root = "${mirror_root}/ceph-deb-jewel"
  $ceph_deb_luminous_root = "${mirror_root}/ceph-deb-luminous"
  $gem_root = "${mirror_root}/gem"

  $www_base = '/var/www'
  $www_root = "${www_base}/mirror"

  #####################################################
  # Build Apache Webroot
  file { $www_base:
    ensure => directory,
    owner  => root,
    group  => root,
  }

  file { $www_root:
    ensure  => directory,
    owner   => root,
    group   => root,
    require => [
      File[$www_base],
    ]
  }

  # Create the symlink to pypi.
  file { "${www_root}/pypi":
    ensure  => link,
    target  => "${pypi_root}/web",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to wheel.
  file { "${www_root}/wheel":
    ensure  => link,
    target  => $wheel_root,
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to centos
  file { "${www_root}/centos":
    ensure  => link,
    target  => "${mirror_root}/centos",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to debian
  file { "${www_root}/debian":
    ensure  => link,
    target  => "${mirror_root}/debian",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to Debian OpenStack Packaging Team repo.
  file { "${www_root}/debian-openstack":
    ensure  => link,
    target  => "${mirror_root}/debian-openstack",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
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
      File[$www_root],
    ]
  }

  # Create the symlink to yum-puppetlabs
  file { "${www_root}/yum-puppetlabs":
    ensure  => link,
    target  => "${mirror_root}/yum-puppetlabs",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to fedora
  file { "${www_root}/fedora":
    ensure  => link,
    target  => "${mirror_root}/fedora",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to openSUSE
  file { "${www_root}/opensuse":
    ensure  => link,
    target  => "${mirror_root}/opensuse",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to Ubuntu
  file { "${www_root}/ubuntu":
    ensure  => link,
    target  => "${mirror_root}/ubuntu",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to Ubuntu ports
  file { "${www_root}/ubuntu-ports":
    ensure  => link,
    target  => "${mirror_root}/ubuntu-ports",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to ceph-deb-hammer.
  file { "${www_root}/ceph-deb-hammer":
    ensure  => link,
    target  => $ceph_deb_hammer_root,
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to ceph-deb-jewel.
  file { "${www_root}/ceph-deb-jewel":
    ensure  => link,
    target  => $ceph_deb_jewel_root,
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to ceph-deb-luminous.
  file { "${www_root}/ceph-deb-luminous":
    ensure  => link,
    target  => $ceph_deb_luminous_root,
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to Ubuntu Cloud Archive.
  file { "${www_root}/ubuntu-cloud-archive":
    ensure  => link,
    target  => "${mirror_root}/ubuntu-cloud-archive",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to Ubuntu MariaDB.
  file { "${www_root}/ubuntu-mariadb":
    ensure  => link,
    target  => "${mirror_root}/ubuntu-mariadb",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to deb-docker.
  file { "${www_root}/deb-docker":
    ensure  => link,
    target  => "${mirror_root}/deb-docker",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # Create the symlink to Ubuntu Puppetlabs.
  file { "${www_root}/apt-puppetlabs":
    ensure  => link,
    target  => "${mirror_root}/apt-puppetlabs",
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  # TODO(pabelanger): We can remove this after puppet runs a few times.
  file { "${www_root}/mariadb":
    ensure  => absent,
  }

  file { "${www_root}/gem":
    ensure  => link,
    target  => $gem_root,
    owner   => root,
    group   => root,
    require => [
      File[$www_root],
    ]
  }

  file { "${www_root}/robots.txt":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    source  => 'puppet:///modules/openstackci/disallow_robots.txt',
    require => File[$www_root],
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
    path    => $cache_root,
    owner   => $www_user,
    group   => $www_group,
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

  if $::osfamily == 'RedHat' {
    # NOTE(jpena): Ports 8081/8082 are not allowed by default for httpd
    # Instead of an exec, we could use selinux::port from voxpupuli-selinux
    package { 'policycoreutils-python':
      ensure => present,
    }
    -> exec {'enable-port-8081-selinux':
      command => 'semanage port -m -t http_cache_port_t -p tcp 8081',
      path    => '/usr/sbin:/usr/bin',
      onlyif  => 'semanage port -l |grep http_cache_port_t|grep tcp | grep -v 8081',
      before  => Httpd::Vhost[$vhost_name],
    }
    -> exec {'enable-port-8082-selinux':
      command => 'semanage port -m -t http_cache_port_t -p tcp 8082',
      path    => '/usr/sbin:/usr/bin',
      onlyif  => 'semanage port -l |grep http_cache_port_t|grep tcp | grep -v 8082',
      before  => Httpd::Vhost[$vhost_name],
    }

    # AFS files get the nfs_t label. We need this SELinux boolean to allow
    # Apache to serve them when Enforcing
    selboolean { 'httpd_use_nfs':
      persistent => true,
      value      => on,
    }

    # In CentOS, httpd::vhost will install the mod_ssl package, which creates
    # file /etc/httpd/conf.d/ssl.conf. Since that directory is purged by the
    # httpd class, we create an idempotency problem. Let's make sure the file
    # is not there
    file { '/etc/httpd/conf.d/ssl.conf':
      ensure  => absent,
      require => Httpd::Vhost[$vhost_name],
      notify  => Service['httpd'],
    }
  }

  ::httpd::vhost { $vhost_name:
    port          => 80,
    priority      => '50',
    docroot       => $www_root,
    template      => 'openstackci/mirror.vhost.erb',
    serveraliases => $serveraliases,
    require       => [
      File[$www_root],
    ],
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
    command     => "flock -n /var/run/htcacheclean.lock htcacheclean -n -p ${cache_root} -t -l 40960M > /dev/null",
    environment => 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    require     => $cleanup_requires,
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
