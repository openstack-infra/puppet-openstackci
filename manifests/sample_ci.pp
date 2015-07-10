# Puppet module that installs Jenkins, Zuul, Jenkins Job Builder,
# and installs JJB and Zuul configuration files from a repository
# called the "data repository".

class openstackci::master{
  $jenkins_username = 'jenkins'
  $jenkins_ssh_public_key = 'AAAAB+your+key+123'

  $vhost_name = $::fqdn

  $project_config_repo     = 'https://git.openstack.org/openstack-infra/project-config'

  $git_email = 'your.email@domain.com'

  $git_name = 'Your Name'

  $gerrit_server = 'review.openstack.org'
  $gerrit_user   = 'gerrit_user_name'
  $gerrit_ssh_host_key = 'review.openstack.org,23.253.232.87,2001:4800:7815:104:3bc3:d7f6:ff03:bf5d b8:3c:72:82:d5:9e:59:43:54:11:ef:93:40:1f:6d:a5'

  $logs_url_pattern = 'http://logs.your.domain.com/{build.parameters[LOG_PATH]}'

  class { '::openstackci::jenkins_master':
    vhost_name              => $master::vhost_name,
    serveradmin             => 'stack',
    jenkins_ssh_private_key => hiera('jenkins_ssh_private_key_contents', 'XXX'),
    jenkins_ssh_public_key  => $master::jenkins_ssh_public_key,
    manage_jenkins_jobs     => true,
    jenkins_url             => 'http://localhost:8080/',
    jenkins_username        => $master::jenkins_username,
    jenkins_password        => hiera('jenkins_jobs_password', 'XXX'),
    project_config_repo     => $master::project_config_repo,
  }

  class { '::openstackci::zuul_merger':
    vhost_name           => $master::vhost_name,
    gearman_server       => 'localhost',
    gerrit_server        => $master::gerrit_server,
    gerrit_user          => $master::gerrit_user_name,
    known_hosts_content  => '', # Leave blank as it is set by openstackci::zuul_scheduler
    zuul_ssh_private_key => hiera('gerrit_user_ssh_private_key_contents', 'XXX'),
    zuul_url             => "http://${master::vhost_name}/p/",
    git_email            => $master::git_email,
    git_name             => $master::git_name,
    manage_common_zuul   => false,
  }

  class { '::openstackci::zuul_scheduler':
    vhost_name           => $master::vhost_name,
    gearman_server       => 'localhost',
    gerrit_server        => $master::gerrit_server,
    gerrit_user          => $master::gerrit_user_name,
    known_hosts_content  => $master::gerrit_ssh_host_key,
    zuul_ssh_private_key => hiera('zuul_ssh_private_key_contents', 'XXX'),
    url_pattern          => $master::logs_url_pattern,
    zuul_url             => "http://${master::vhost_name}/p/",
    job_name_in_report   => true,
    status_url           => "http://${master::vhost_name}",
    project_config_repo  => $master::project_config_repo,
    git_email            => $master::git_email,
    git_name             => $master::git_name,
  }

  class { '::openstackci::nodepool':
    mysql_root_password      => hiera('mysql_root_password', 'XXX'),
    mysql_password           => hiera('mysql_password', 'XXX'),
    yaml_path                => '/etc/project-config/nodepool/nodepool.yaml',
    nodepool_ssh_private_key => hiera('jenkins_ssh_private_key_contents', 'XXX'),
    environment              => {
      # Set up the key in /etc/default/nodepool, used by the service.
      'NODEPOOL_SSH_KEY' => $master::jenkins_ssh_public_key
    },
    project_config_repo      => $master::project_config_repo,
    jenkins_masters          => [
      { name        => 'local-jenkins',
        url         => 'http://localhost:8080/',
        user        => $master::jenkins_username,
        apikey      => hiera('jenkins_api_key', 'XXX'),
        credentials => hiera('jenkins_credentials_id', 'XXX'),
      },
    ],
  }

}

