# == Class: openstackci::logstash_worker
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
    config_file => log_processor_config,
  }
  log_processor::worker { 'B':
    config_file => log_processor_config,
  }
  log_processor::worker { 'C':
    config_file => log_processor_config,
  }
  log_processor::worker { 'D':
    config_file => log_processor_config,
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
