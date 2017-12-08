# Copyright (c) 2012-2015 Hewlett-Packard Development Company, L.P.
# Copyright (c) 2015 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License

# == Class: openstackci::zuul_scheduler
#
class openstackci::zuul_scheduler(
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gearman_check_job_registration = false,
  $gerrit_server = '',
  $gerrit_user = '',
  $gerrit_strip_branch_ref = '',
  $known_hosts_content = '',
  $zuul_ssh_private_key = '',
  $layout_file_name = 'layout.yaml',
  $url_pattern = '',
  $zuul_url = '',
  $job_name_in_report = true,
  $status_url = 'http://status.domain.example/zuul/',
  $swift_account_temp_key = '',
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
  $statsd_host = '',
  $project_config_repo = '',
  $project_config_revision = 'master',
  $project_config_base = '',
  $git_email = 'zuul@domain.example',
  $git_name = 'Zuul',
  $smtp_host = 'localhost',
  $smtp_port = 25,
  $smtp_default_from = "zuul@${::fqdn}",
  $smtp_default_to = "zuul.reports@${::fqdn}",
  $revision = 'master',
  # v3 additions
  $python_version = 2,
  $zookeeper_hosts = '127.0.0.1:2181',
  $zookeeper_session_timeout = undef,
  $zuulv3 = false,
  $connections = [],
  $connection_secrets = [],
  $zuul_status_url = 'http://127.0.0.1:8001',
  $gearman_client_ssl_cert = undef,
  $gearman_client_ssl_key = undef,
  $gearman_server_ssl_cert = undef,
  $gearman_server_ssl_key = undef,
  $gearman_ssl_ca = undef,
  $github_key_content = undef,
) {

  if ! defined(Class['project_config']) {
    class { '::project_config':
      url      => $project_config_repo,
      revision => $project_config_revision,
      base     => $project_config_base,
    }
  }

  class { '::zuul':
    vhost_name                     => $vhost_name,
    gearman_server                 => $gearman_server,
    gearman_check_job_registration => $gearman_check_job_registration,
    gerrit_server                  => $gerrit_server,
    gerrit_user                    => $gerrit_user,
    gerrit_strip_branch_ref        => $gerrit_strip_branch_ref,
    zuul_ssh_private_key           => $zuul_ssh_private_key,
    url_pattern                    => $url_pattern,
    layout_file_name               => $layout_file_name,
    zuul_url                       => $zuul_url,
    job_name_in_report             => $job_name_in_report,
    status_url                     => $status_url,
    statsd_host                    => $statsd_host,
    git_email                      => $git_email,
    git_name                       => $git_name,
    smtp_host                      => $smtp_host,
    smtp_port                      => $smtp_port,
    smtp_default_from              => $smtp_default_from,
    smtp_default_to                => $smtp_default_to,
    swift_account_temp_key         => $swift_account_temp_key,
    swift_authurl                  => $swift_authurl,
    swift_auth_version             => $swift_auth_version,
    swift_user                     => $swift_user,
    swift_key                      => $swift_key,
    swift_tenant_name              => $swift_tenant_name,
    swift_region_name              => $swift_region_name,
    swift_default_container        => $swift_default_container,
    swift_default_logserver_prefix => $swift_default_logserver_prefix,
    swift_default_expiry           => $swift_default_expiry,
    proxy_ssl_cert_file_contents   => $proxy_ssl_cert_file_contents,
    proxy_ssl_key_file_contents    => $proxy_ssl_key_file_contents,
    proxy_ssl_chain_file_contents  => $proxy_ssl_chain_file_contents,
    revision                       => $revision,
    python_version                 => $python_version,
    zookeeper_hosts                => $zookeeper_hosts,
    zookeeper_session_timeout      => $zookeeper_session_timeout,
    zuulv3                         => $zuulv3,
    connections                    => $connections,
    connection_secrets             => $connection_secrets,
    zuul_status_url                => $zuul_status_url,
    gearman_client_ssl_cert        => $gearman_client_ssl_cert,
    gearman_client_ssl_key         => $gearman_client_ssl_key,
    gearman_server_ssl_cert        => $gearman_server_ssl_cert,
    gearman_server_ssl_key         => $gearman_server_ssl_key,
    gearman_ssl_ca                 => $gearman_ssl_ca,
  }

  if $zuulv3 {
    if ($github_key_content != undef) {
      file { '/etc/zuul/github.key':
        ensure  => present,
        owner   => 'zuul',
        group   => 'zuul',
        mode    => '0600',
        content => $github_key_content,
        require => File['/etc/zuul'],
      }
    }
    class { '::zuul::scheduler':
      layout_dir     => $::project_config::zuul_layout_dir,
      require        => $::project_config::config_dir,
      python_version => $python_version,
      use_mysql      => true,
    }
    class { '::zuul::web': }
  } else {
    class { '::zuul::server':
      layout_dir => $::project_config::zuul_layout_dir,
      require    => $::project_config::config_dir,
    }
  }

  if $known_hosts_content != '' {
    class { '::zuul::known_hosts':
      known_hosts_content => $known_hosts_content,
    }
  }
}
