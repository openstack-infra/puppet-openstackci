# Copyright (c) 2015 Hewlett-Packard Development Company, L.P.
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

#
# A sample puppet node configuration that installs and configures a server
# that hosts log files that are viewable in a browser.
# Note that using swift is optional and the defaults provided disable its
# usage.

node default {
  class { '::openstackci::logserver':
    domain                  => hiera('domain'),
    jenkins_ssh_key         => hiera('jenkins_ssh_public_key'),
    ara_middleware          => hiera('ara_middleware', false),
    swift_authurl           => hiera('swift_authurl', ''),
    swift_user              => hiera('swift_user', ''),
    swift_key               => hiera('swift_key', ''),
    swift_tenant_name       => hiera('swift_tenant_name', ''),
    swift_region_name       => hiera('swift_region_name', ''),
    swift_default_container => hiera('swift_default_container', ''),
  }
}
