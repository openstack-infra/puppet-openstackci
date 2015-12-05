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
  $es_heap_size = '1g',
  $es_version = '1.7.3',
  # Increase the indexer max heap size to twice the default.
  # Default is 25% of memory or 1g whichever is less.
  $indexer_java_args = '-Xmx2g',
  $indexer_conf_template,
  $log_processor_workers = ['A', 'B', 'C', 'D',],
  $es_gw_recover_after_nodes = '5',
  $es_gw_recover_after_time = '5m',
  $es_gw_expected_nodes = '6',
  $es_discovery_min_master_nodes = '5',
) {

  file { '/etc/default/logstash-indexer':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "JAVA_ARGS='${indexer_java_args}'"
  }

  class { 'logstash::indexer':
    conf_template => $indexer_conf_template,
  }

  include log_processor
  log_processor::worker { $log_processor_workers:
    config_file => $log_processor_config,
  }

  class { '::elasticsearch':
    es_template_config => {
      'gateway.recover_after_nodes'          => $es_gw_recover_after_nodes,
      'gateway.recover_after_time'           => $es_gw_recover_after_time,
      'gateway.expected_nodes'               => $es_gw_expected_nodes,
      'discovery.zen.minimum_master_nodes'   => $es_discovery_min_master_nodes,
      'discovery.zen.ping.multicast.enabled' => false,
      'discovery.zen.ping.unicast.hosts'     => $elasticsearch_nodes,
      'node.master'                          => false,
      'node.data'                            => false,
    },
    heap_size          => $es_heap_size,
    version            => $es_version,
  }

}
