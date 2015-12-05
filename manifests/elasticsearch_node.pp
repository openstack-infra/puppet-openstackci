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
#
# == Class: openstackci::elasticsearch_node

# Elasticsearch server glue class.
#
class openstackci::elasticsearch_node (
  $discover_nodes = ['localhost'],
  $es_heap_size = '30g',
  $es_version = '1.7.3',
  $es_gw_recover_after_nodes = '5',
  $es_gw_recover_after_time = '5m',
  $es_gw_expected_nodes = '6',
  $es_discovery_min_master_nodes = '4',
  $es_indices_cleanup_hour = '2',
  $es_indices_cleanup_minute = '0',
  $es_indices_cleanup_period = '10 days ago',
) {

  class { 'logstash::elasticsearch': }

  class { '::elasticsearch':
    es_template_config => {
      'index.store.compress.stored'          => true,
      'index.store.compress.tv'              => true,
      'indices.memory.index_buffer_size'     => '33%',
      'indices.breaker.fielddata.limit'      => '70%',
      'bootstrap.mlockall'                   => true,
      'gateway.recover_after_nodes'          => $es_gw_recover_after_nodes,
      'gateway.recover_after_time'           => $es_gw_recover_after_time,
      'gateway.expected_nodes'               => $es_gw_expected_nodes,
      'discovery.zen.minimum_master_nodes'   => $es_discovery_min_master_nodes,
      'discovery.zen.ping.multicast.enabled' => false,
      'discovery.zen.ping.unicast.hosts'     => $discover_nodes,
      'http.cors.enabled'                    => true,
      'http.cors.allow-origin'               => "'*'", # lint:ignore:double_quoted_strings
    },
    heap_size          => $es_heap_size,
    version            => $es_version,
  }

  cron { 'delete_old_es_indices':
    ensure      => 'absent',
    user        => 'root',
    hour        => $es_indices_cleanup_hour,
    minute      => $es_indices_cleanup_minute,
    command     => "curl -sS -XDELETE \"http://localhost:9200/logstash-`date -d '${es_indices_cleanup_period}' +\%Y.\%m.\%d`/\" > /dev/null",
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
  }

  class { 'logstash::curator':
    keep_for_days  => '10',
  }

}
