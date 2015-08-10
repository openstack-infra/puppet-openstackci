# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: openstackci::subunit_worker
#
# subunit2sql worker glue class.
#
class openstackci::subunit_worker (
  $subunit2sql_db_host,
  $subunit2sql_db_pass,
  $subunit2sql_config_file,
) {

  include subunit2sql
  subunit2sql::worker { 'A':
    config_file => $subunit2sql_config_file,
    db_host     => $subunit2sql_db_host,
    db_pass     => $subunit2sql_db_pass,
    require     => [
      User['logstash'],
      Group['logstash'],
    ]
  }

  # [mmedvede]: subunit2sql is supposed to create users it uses,
  # but it doesn't yet.
  if ! defined(User['logstash']) {
    user {'logstash':
      ensure => present,
    }
  }
  if ! defined(Group['logstash']) {
    group {'logstash':
      ensure => present,
    }
  }
}
