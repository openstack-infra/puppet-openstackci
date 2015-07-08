# == Class: openstackci::logstash
#
class openstackci::logstash (
  $discover_nodes,
  $statsd_host,
  $subunit2sql_db_host,
  $subunit2sql_db_pass,
  $log_processor_config,
) {

  class { 'logstash::web':
    frontend            => 'kibana',
    discover_nodes      => $discover_nodes,
    proxy_elasticsearch => true,
  }

  class { 'log_processor': }

  class { 'log_processor::client':
    config_file => $log_processor_config,
    statsd_host => $statsd_host,
  }

  include 'subunit2sql'

  class { 'subunit2sql::server':
    db_host => $subunit2sql_db_host,
    db_pass => $subunit2sql_db_pass,
  }

  include 'simpleproxy'

  class { 'simpleproxy::server':
    db_host            => $subunit2sql_db_host,
  }

}
