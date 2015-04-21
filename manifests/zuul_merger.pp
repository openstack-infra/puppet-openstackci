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
  $vhost_name = $::fqdn,
  $gearman_server = '127.0.0.1',
  $gerrit_server = '',
  $gerrit_user = '',
  $gerrit_ssh_host_key = '',
  $gerrit_ssh_host_identity = [
    'review.domain.example',
  ],
  $zuul_ssh_private_key = '',
  $zuul_url = "http://${::fqdn}/p",
  $git_email = 'zuul@domain.example',
  $git_name = 'Zuul',
  $manage_common_zuul = true,
) {

  $gerrit_ssh_ident = inline_template('<%= (@gerrit_ssh_host_identity).join(",") %> <%= @gerrit_ssh_host_key %>')

  if $manage_common_zuul {
    class { '::zuul':
      vhost_name           => $vhost_name,
      gearman_server       => $gearman_server,
      gerrit_server        => $gerrit_server,
      gerrit_user          => $gerrit_user,
      zuul_ssh_private_key => $zuul_ssh_private_key,
      zuul_url             => $zuul_url,
      git_email            => $git_email,
      git_name             => $git_name,
    }
  }

  class { '::zuul::merger': }

  if $gerrit_ssh_host_key != '' {
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
      content => $gerrit_ssh_ident,
      replace => true,
      require => File['/home/zuul/.ssh'],
    }
  }
}
