# This test only runs on Debian flavors
if $::osfamily == 'Debian' {
  class { '::openstackci::logserver':
    domain          => 'foo.openstack.org',
    jenkins_ssh_key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC6WutNHfM+YdnjeNFeaIpvxqt+9aDn95Ykpmc+fASSjlDZJtOrueH3ch/v08wkE4WQKg03i+t8VonqEwMGmApYA3VzFsURUQbxzlSz5kHlBQSqgz5JTwUmnt1RH5sePL5pkuJ6JgqJ8PxJod6fiD7YDjaKJW/wBzXGnGg2EkgqrkBQXYL4hyaPuSwsQF0Gdwg3QFqXl+R/GrM6FscUkkJzbjqGKI2GhLT8mf2BIMEAiMFhF5Wl4FFrbvhTfPfW+9VdcsiMxCXaxp00n1x1+Y7OqR5AZ/id0Lkz9ZoFVGS901OB/L4xXrvUtI2y+kIYeF6hxfmAl/zhY0eWzwo9lDPz'
  }
}

class { '::openstackci::mirror':
  mirror_root   => '/afs/openstack.org/mirror',
  vhost_name    => 'foo.openstack.org',
  serveraliases => ['foo01.openstack.org']
}
