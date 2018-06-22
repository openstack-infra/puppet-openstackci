exec { 'change hostname':
  command => '/bin/hostname nl04'
}

host { 'nl04.openstack.org':
  host_aliases => 'nl04',
  ip           => '127.0.1.1',
}
