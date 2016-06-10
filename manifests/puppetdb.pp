# == Class: openstackci::puppetdb
#
class openstackci::puppetdb (
  $version = '2.3.8-1puppetlabs1',
  $manage_database = true,
  $java_args = { '-Xmx' => '512m', '-Xms' => '256m' },
  $ssl_set_cert_paths = true,
  $ssl_cert_path = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $ssl_key_path = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $ssl_ca_cert_path = '/etc/ssl/certs/ca-certificates.crt',
) {

  if $manage_database {
    # The puppetlabs postgres module does not manage the postgres user
    # and group for us. Create them here to ensure concat can create
    # dirs and files owned by this user and group.
    user { 'postgres':
      ensure  => present,
      gid     => 'postgres',
      system  => true,
      require => Group['postgres'],
    }

    group { 'postgres':
      ensure => present,
      system => true,
    }

    class { 'puppetdb::database::postgresql':
      require         => User['postgres'],
    }
  }

  class { '::puppetdb::server':
    database_host      => 'localhost',
    ssl_listen_address => '0.0.0.0', # works for ipv6 too
    ssl_set_cert_paths => $ssl_set_cert_paths,
    ssl_cert_path      => $ssl_cert_path,
    ssl_key_path       => $ssl_key_path,
    ssl_ca_cert_path   => $ssl_ca_cert_path,
    java_args          => $java_args,
    puppetdb_version   => $version,
    require            => [ User['postgres'],
      Class['puppetdb::database::postgresql'],],
  }

  if versioncmp($version, '2.3.8') > 0 {
    file { '/etc/puppetdb/':
       ensure => directory,
       before  => Class['::puppetdb::server'],
    }
    file { '/etc/puppetdb/conf.d/':
       ensure => directory,
       before  => Class['::puppetdb::server'],
    }
    apt::source { 'puppetlabs-pc1':
      location => 'http://apt.puppetlabs.com',
      repos    => 'PC1',
      key      => {
        'id'     =>'47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
        'server' => 'pgp.mit.edu',
      },
      before   => [Class['::puppetdb::server'],
                   Exec['apt_update']],
    }
    exec { 'apt_update':
      command => '/usr/bin/apt-get update',
    }
  }

}
