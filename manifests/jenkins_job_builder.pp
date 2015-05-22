# == Class: openstackci::jenkins_job_builder
#
class openstackci::jenkins_job_builder (
  $vhost_name = $::fqdn,
  $jenkins_url = "http://${vhost_name}:8080",
  $jenkins_username = 'gerrit',
  $jenkins_password = '',
  $jjb_update_timeout = 1200,
  $jjb_git_url = 'https://git.openstack.org/openstack-infra/jenkins-job-builder',
  $jjb_git_revision = 'master',
  $project_config_repo = '',
  $project_config_base = '',
) {

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
    config_dir                  => $::project_config::jenkins_job_builder_config_dir,
    require                     => $::project_config::config_dir,
  }
}
