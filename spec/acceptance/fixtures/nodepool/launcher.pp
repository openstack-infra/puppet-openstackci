$private_key = '-----BEGIN EC PRIVATE KEY-----
MHcCAQEEILEJO9HQBHkih1m+w+VA9YmoKvuyeHlg8rE1M48swE2roAoGCCqGSM49
AwEHoUQDQgAEQZCY1Ps1AuzJPIUEmdh7lFH/Ku+wTVVgH6EXouZGOjXiiILtpmyY
OFt70lFEz/Ym8MGGUaUzts1xSZcBVKnRzw==
-----END EC PRIVATE KEY-----'

$clouds_yaml = ''

class { '::openstackci::nodepool_launcher':
  nodepool_ssh_private_key => $private_key,
  project_config_repo      => 'https://git.openstack.org/openstack-infra/project-config',
  oscc_file_contents       => $clouds_yaml,
  statsd_host              => 'graphite.openstack.org',
  revision                 => 'master',
  python_version           => 3,
  enable_webapp            => true,
}
