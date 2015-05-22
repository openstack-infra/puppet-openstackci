# == Class: openstackci::jenkins_job_builder
#
class openstackci::jenkins_job_builder (
  $vhost_name = $::fqdn,
  $jenkins_url = 'http://${vhost_name}:8080',
  $jenkins_jobs_username = 'gerrit',
  $jenkins_jobs_password = '',
  $jenkins_jobs_update_timeout = 1200,
  $jenkins_git_url = 'https://git.openstack.org/openstack-infra/jenkins-job-builder',
  $jenkins_git_revision = 'master',
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
    username                    => $jenkins_jobs_username,
    password                    => $jenkins_jobs_password,
    jenkins_jobs_update_timeout => $jenkins_jobs_update_timeout,
    git_revision                => $jenkins_git_revision,
    git_url                     => $jenkins_git_url,
    config_dir                  => $::project_config::jenkins_job_builder_config_dir,
    require                     => $::project_config::config_dir,
  }
}
