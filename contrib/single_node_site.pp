node default {
  class { 'openstackci::single_node_ci':
    project_config_repo => 'https://github.com/rasselin/os-ext-testing-data.git',

    jenkins_ssh_private_key => '',
    jenkins_ssh_public_key => '',

    gerrit_server => 'review.openstack.org',
    gerrit_user => 'Your Gerrit User',
    gerrit_user_ssh_public_key => ''',
    gerrit_user_ssh_private_key => '',

    mysql_root_password => 'mysql_root',
    mysql_nodepool_password => 'mysql_nodepool',
  }
}
