exec { 'change hostname':
  command => '/bin/hostname nb03'
}

host { 'nb01.openstack.org':
  host_aliases => 'nb01',
  ip           => '127.0.1.1',
}

# The cloud-utils package (specifically its euca2ools dependency) on an Ubuntu
# Trusty image created by DIB pulls in python[3]-six, which causes conflicts
# when used with pip 10. We don't need cloud-utils once the image has been
# built, so remove it and allow pip to manage six.
package { ['python-six', 'python3-six']:
  ensure => absent,
}
