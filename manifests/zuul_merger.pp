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

# == Class: openstackci::zuul_merger
#
class openstackci::zuul_merger(
  $gearman_server       = '127.0.0.1',
  $gerrit_server        = '',
  $gerrit_user          = '',
  $git_email            = 'zuul@domain.example',
  $git_name             = 'Zuul',
  $git_source_repo      = 'https://git.openstack.org/openstack-infra/zuul',
  $known_hosts_content  = '',
  $layout_file_name     = 'layout.yaml',
  $manage_common_zuul   = true,
  $revision             = 'master',
  $vhost_name           = $::fqdn,
  $zuul_ssh_private_key = '',
  $zuul_url             = "http://${::fqdn}/p",
) {

  if $manage_common_zuul {
    class { '::zuul':
      vhost_name           => $vhost_name,
      gearman_server       => $gearman_server,
      gerrit_server        => $gerrit_server,
      gerrit_user          => $gerrit_user,
      zuul_ssh_private_key => $zuul_ssh_private_key,
      layout_file_name     => $layout_file_name,
      zuul_url             => $zuul_url,
      git_email            => $git_email,
      git_name             => $git_name,
      revision             => $revision,
      git_source_repo      => $git_source_repo,
    }
  }

  class { '::zuul::merger': }

  if $known_hosts_content != '' {
    file { '/home/zuul/.ssh':
      ensure  => directory,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0700',
      require => Class['::zuul'],
    }
    file { '/home/zuul/.ssh/known_hosts':
      ensure  => present,
      owner   => 'zuul',
      group   => 'zuul',
      mode    => '0600',
      content => $known_hosts_content,
      replace => true,
      require => File['/home/zuul/.ssh'],
    }
  }
}
