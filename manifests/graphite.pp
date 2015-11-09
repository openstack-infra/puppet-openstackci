# == Class: openstackci::graphite
#
class openstackci::graphite (
  $graphite_admin_user,
  $graphite_admin_email,
  $graphite_admin_password,
  $vhost_name = $::fqdn,
) {

  class { '::graphite':
    graphite_admin_user     => $graphite_admin_user,
    graphite_admin_email    => $graphite_admin_email,
    graphite_admin_password => $graphite_admin_password,
    vhost_name              => $vhost_name,
  }

}
