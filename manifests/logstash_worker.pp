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

# == Class: openstackci::logstash_worker
#
# Logstash indexer worker glue class.
#
class openstackci::logstash_worker (
  $elasticsearch_nodes = [],
  $log_processor_config,
  $heap_size = '1g',
  $version = '0.90.9',
) {

  file { '/etc/default/logstash-indexer':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/openstackci/logstash/logstash-indexer.default',
  }

  class { 'logstash::indexer':
    conf_template => 'openstackci/logstash/indexer.conf.erb',
  }

  include log_processor
  log_processor::worker { 'A':
    config_file => $log_processor_config,
  }
  log_processor::worker { 'B':
    config_file => $log_processor_config,
  }
  log_processor::worker { 'C':
    config_file => $log_processor_config,
  }
  log_processor::worker { 'D':
    config_file => $log_processor_config,
  }

  class { '::elasticsearch':
    es_template_config => {
      'gateway.recover_after_nodes'          => '5',
      'gateway.recover_after_time'           => '5m',
      'gateway.expected_nodes'               => '6',
      'discovery.zen.minimum_master_nodes'   => '5',
      'discovery.zen.ping.multicast.enabled' => false,
      'discovery.zen.ping.unicast.hosts'     => $elasticsearch_nodes,
      'node.master'                          => false,
      'node.data'                            => false,
    },
    heap_size          => $heap_size,
    version            => $version,
  }

}
