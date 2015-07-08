# == Class: openstackci::elasticsearch_node
#
class openstackci::elasticsearch_node (
  $discover_nodes = ['localhost'],
  $heap_size = '30g',
  $version = '0.90.9',
) {

  class { 'logstash::elasticsearch': }

  class { '::elasticsearch':
    es_template_config => {
      'index.store.compress.stored'          => true,
      'index.store.compress.tv'              => true,
      'indices.memory.index_buffer_size'     => '33%',
      'bootstrap.mlockall'                   => true,
      'gateway.recover_after_nodes'          => '5',
      'gateway.recover_after_time'           => '5m',
      'gateway.expected_nodes'               => '6',
      'discovery.zen.minimum_master_nodes'   => '4',
      'discovery.zen.ping.multicast.enabled' => false,
      'discovery.zen.ping.unicast.hosts'     => $discover_nodes,
    },
    heap_size          => $heap_size,
    version            => $version,
  }

  cron { 'delete_old_es_indices':
    user        => 'root',
    hour        => '2',
    minute      => '0',
    command     => 'curl -sS -XDELETE "http://localhost:9200/logstash-`date -d \'10 days ago\' +\%Y.\%m.\%d`/" > /dev/null',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
  }

  cron { 'optimize_old_es_indices':
    ensure      => absent,
    user        => 'root',
    hour        => '13',
    minute      => '0',
    command     => 'curl -sS -XPOST "http://localhost:9200/logstash-`date -d yesterday +\%Y.\%m.\%d`/_optimize?max_num_segments=2" > /dev/null',
    environment => 'PATH=/usr/bin:/bin:/usr/sbin:/sbin',
  }
}
