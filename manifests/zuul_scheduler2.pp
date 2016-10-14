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

# == Class: openstackci::zuul_scheduler2
#
class openstackci::zuul_scheduler2(
  $project_config_repo = '',
  $project_config_revision = 'master',
  $project_config_base = '',
  $known_hosts_content = '',
) {

  if ! defined(Class['project_config']) {
    class { '::project_config':
      url      => $project_config_repo,
      revision => $project_config_revision,
      base     => $project_config_base,
    }
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
