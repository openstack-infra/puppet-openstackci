# == Class: openstackci::jenkins_master
#
class openstackci::jenkins_master (
  $serveradmin,
  $jenkins_password,
  $jenkins_username        = 'jenkins',
  $vhost_name              = $::fqdn,
  $logo                    = '', # Logo must be present in puppet-jenkins/files
  $ssl_cert_file           = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $ssl_key_file            = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $ssl_chain_file          = '',
  $ssl_cert_file_contents  = '',
  $ssl_key_file_contents   = '',
  $ssl_chain_file_contents = '',
  $jenkins_ssh_private_key = '',
  $jenkins_ssh_public_key  = '',
  $manage_jenkins_jobs     = false,
  $jenkins_url             = 'http://localhost:8080',
  $jjb_update_timeout      = 1200,
  $jjb_git_url             = 'https://git.openstack.org/openstack-infra/jenkins-job-builder',
  $jjb_git_revision        = 'master',
  $project_config_repo     = '',
  $project_config_base     = '',
  $log_server              = undef,
) {

  class { '::jenkins::master':
    vhost_name              => $vhost_name,
    serveradmin             => $serveradmin,
    logo                    => $logo,
    ssl_cert_file           => $ssl_cert_file,
    ssl_key_file            => $ssl_key_file,
    ssl_chain_file          => $ssl_chain_file,
    ssl_cert_file_contents  => $ssl_cert_file_contents,
    ssl_key_file_contents   => $ssl_key_file_contents,
    ssl_chain_file_contents => $ssl_chain_file_contents,
    jenkins_ssh_private_key => $jenkins_ssh_private_key,
    jenkins_ssh_public_key  => $jenkins_ssh_public_key,
  }

  jenkins::plugin { 'build-timeout':
    version => '1.14',
  }
  jenkins::plugin { 'copyartifact':
    version => '1.22',
  }
  jenkins::plugin { 'dashboard-view':
    version => '2.3',
  }
  jenkins::plugin { 'gearman-plugin':
    version => '0.1.1',
  }
  jenkins::plugin { 'git':
    version => '1.1.23',
  }
  jenkins::plugin { 'greenballs':
    version => '1.12',
  }
  jenkins::plugin { 'extended-read-permission':
    version => '1.0',
  }
  jenkins::plugin { 'zmq-event-publisher':
    version => '0.0.3',
  }
  jenkins::plugin { 'scp':
    version    => '1.9',
    plugin_url => 'http://tarballs.openstack.org/ci/scp.jpi',
  }
  jenkins::plugin { 'jobConfigHistory':
    version => '1.13',
  }
  jenkins::plugin { 'monitoring':
    version => '1.40.0',
  }
  jenkins::plugin { 'nodelabelparameter':
    version => '1.2.1',
  }
  jenkins::plugin { 'notification':
    version => '1.4',
  }
  jenkins::plugin { 'openid':
    version => '1.5',
  }
  jenkins::plugin { 'postbuildscript':
    version => '0.16',
  }
  jenkins::plugin { 'publish-over-ftp':
    version => '1.7',
  }
  jenkins::plugin { 'simple-theme-plugin':
    version => '0.2',
  }
  jenkins::plugin { 'timestamper':
    version => '1.3.1',
  }
  jenkins::plugin { 'token-macro':
    version => '1.5.1',
  }

  if $manage_jenkins_jobs == true {
    if ! defined(Class['project_config']) {
      class { 'project_config':
        url  => $project_config_repo,
        base => $project_config_base,
      }
    }
    class { '::jenkins::job_builder':
      url                         => $jenkins_url,
      username                    => $jenkins_username,
      password                    => $jenkins_password,
      jenkins_jobs_update_timeout => $jjb_update_timeout,
      git_revision                => $jjb_git_revision,
      git_url                     => $jjb_git_url,
      config_dir                  =>
        $::project_config::jenkins_job_builder_config_dir,
      require                     => $::project_config::config_dir,
    }
  }

  if $log_server != undef {
    file {'/var/lib/jenkins/be.certipost.hudson.plugin.SCPRepositoryPublisher.xml':
        ensure  => present,
        owner   => 'jenkins',
        group   => 'jenkins',
        mode    => '0644',
        content => template('openstackci/be.certipost.hudson.plugin.SCPRepositoryPublisher.xml.erb'),
    }
  }
}
