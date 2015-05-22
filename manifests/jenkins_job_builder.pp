# == Class: openstackci::jenkins_job_builder
#
class openstackci::jenkins_job_builder (
  $vhost_name = $::fqdn,
  $jenkins_jobs_username = 'gerrit',
  $jenkins_jobs_password = '',
  $jenkins_git_url = 'https://git.openstack.org/openstack-infra/jenkins-job-builder',
  $jenkins_git_revision = 'master',
  $project_config_repo = ''
) {

  class { 'project_config':
    url  => $project_config_repo,
  }

  class { '::jenkins::job_builder':
    jenkins_jobs_update_timeout => 1200,
    url                         => "https://${vhost_name}/",
    username                    => $jenkins_jobs_username,
    password                    => $jenkins_jobs_password,
    git_revision                => $jenkins_git_revision,
    git_url                     => $jenkins_git_url,
    config_dir                  => $::project_config::jenkins_job_builder_config_dir,
    require                     => $::project_config::config_dir,
  }
}
