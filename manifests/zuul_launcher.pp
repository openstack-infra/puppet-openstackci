# == Class: openstack_ci::zuul_launcher
#
class openstackci::zuul_launcher(
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gerrit_server = '',
  $gerrit_user = '',
  $gerrit_ssh_host_key = '',
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
  $sysadmins = [],
  $statsd_host = '',
  $project_config_repo = '',
  $project_config_base = '',
  $git_email = 'jenkins@openstack.org',
  $git_name = 'OpenStack Jenkins',
  $workspace_root = '/home/jenkins/workspace',
  $worker_private_key_file = '/var/lib/zuul/ssh/id_rsa',
  $worker_username = 'jenkins',
  $sites = [],
  $nodes = [],
  $accept_nodes = '',
  $zuul_launcher_keytab = '',
) {

  if ! defined(Class['project_config']) {
    class { '::project_config':
      url  => $project_config_repo,
      base => $project_config_base,
    }
  }

  file { '/etc/zuul-launcher.keytab':
    owner   => 'zuul',
    group   => 'zuul',
    mode    => '0400',
    content => $zuul_launcher_keytab,
  }

  file { '/etc/jenkins_jobs':
    ensure => directory,
  }

  file { '/etc/jenkins_jobs/config':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    source  => $::project_config::jenkins_job_builder_config_dir,
    require => [File['/etc/jenkins_jobs'],
                $::project_config::config_dir],
    notify  => Exec['zuul-launcher-reload'],
  }

  file { '/home/zuul/.ssh':
    ensure  => directory,
    owner   => 'zuul',
    group   => 'zuul',
    mode    => '0700',
    require => User['zuul'],
    creates => '/home/zuul/.ssh'
  }

  file { '/home/zuul/.ssh/config':
    ensure  => present,
    source  => 'puppet:///modules/openstack_project/zuul/launcher_ssh_config',
    owner   => 'zuul',
    group   => 'zuul',
    require => File['/home/zuul/.ssh'],
  }

  class { 'zuul::launcher': }
}
