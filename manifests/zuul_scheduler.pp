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
  $gearman_server                 = '127.0.0.1',
  $gerrit_server                  = '',
  $gerrit_user                    = '',
  $git_email                      = 'zuul@domain.example',
  $git_name                       = 'Zuul',
  $known_hosts_content            = '',
  $job_name_in_report             = true,
  $project_config_base            = '',
  $project_config_repo            = '',
  $project_config_revision        = 'master',
  $proxy_ssl_cert_file_contents   = '',
  $proxy_ssl_key_file_contents    = '',
  $proxy_ssl_chain_file_contents  = '',
  $revision                       = 'master',
  $smtp_default_from              = "zuul@${::fqdn}",
  $smtp_default_to                = "zuul.reports@${::fqdn}",
  $smtp_host                      = 'localhost',
  $smtp_port                      = 25,
  $status_url                     = 'http://status.domain.example/zuul/',
  $statsd_host                    = '',
  $swift_account_temp_key         = '',
  $swift_auth_version             = '',
  $swift_authurl                  = '',
  $swift_default_container        = '',
  $swift_default_logserver_prefix = '',
  $swift_default_expiry           = 7200,
  $swift_key                      = '',
  $swift_user                     = '',
  $swift_region_name              = '',
  $swift_tenant_name              = '',
  $url_pattern                    = '',
  $vhost_name                     = $::fqdn,
  $zuul_ssh_private_key           = '',
  $zuul_url                       = '',
) {

  if ! defined(Class['project_config']) {
    class { 'project_config':
      url      => $project_config_repo,
      revision => $project_config_revision,
      base     => $project_config_base,
    }
  }

  class { '::zuul':
    vhost_name                     => $vhost_name,
    gearman_server                 => $gearman_server,
    gerrit_server                  => $gerrit_server,
    gerrit_user                    => $gerrit_user,
    zuul_ssh_private_key           => $zuul_ssh_private_key,
    url_pattern                    => $url_pattern,
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
  }

  class { '::zuul::server':
    layout_dir => $::project_config::zuul_layout_dir,
    require    => $::project_config::config_dir,
  }

  if $known_hosts_content != '' {
    class { '::zuul::known_hosts':
      known_hosts_content => $known_hosts_content,
    }
  }
}
