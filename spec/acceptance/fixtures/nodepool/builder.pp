$public_key = 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEGQmNT7NQLsyTyFBJnYe5RR/yrvsE1VYB+hF6LmRjo14oiC7aZsmDhbe9JRRM/2JvDBhlGlM7bNcUmXAVSp0c8='

$clouds_yaml = ''

class { '::openstackci::nodepool_builder':
  nodepool_ssh_public_key       => $public_key,
  vhost_name                    => $::fqdn,
  enable_build_log_via_http     => true,
  project_config_repo           => 'https://git.openstack.org/openstack-infra/project-config',
  oscc_file_contents            => $clouds_yaml,
  statsd_host                   => 'graphite.openstack.org',
  upload_workers                => '16',
  revision                      => 'master',
  python_version                => 3,
  zuulv3                        => true,
}
