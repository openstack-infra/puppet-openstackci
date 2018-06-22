exec { 'change hostname':
  command => '/bin/hostname nb03'
}

host { 'nb01.openstack.org':
  host_aliases => 'nb01',
  ip           => '127.0.1.1',
}
