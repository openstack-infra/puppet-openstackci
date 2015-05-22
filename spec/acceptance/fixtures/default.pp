class { '::openstackci::logserver':
  domain          => 'foo.openstack.org',
  jenkins_ssh_key => 'AAAA==',
}
