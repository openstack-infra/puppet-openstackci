#! /usr/bin/env bash


set -e
export DOMAIN=test.domain.com


export JENKINS_SSH_PUBLIC_KEY=testkey
rm -f testkey
rm -f testkey.pub
ssh-keygen -f $JENKINS_SSH_PUBLIC_KEY -N '' -q

PUPPET_MODULE_PATH="--modulepath=/etc/puppet/modules"

# Install Puppet and the OpenStack Infra Config source tree
if [[ ! -e install_puppet.sh ]]; then
  wget https://git.openstack.org/cgit/openstack-infra/system-config/plain/install_puppet.sh
  sudo bash -xe install_puppet.sh
  sudo git clone https://review.openstack.org/p/openstack-infra/system-config.git \
    /root/system-config
  sudo /bin/bash /root/system-config/install_modules.sh
fi

CLASS_ARGS="domain => '$DOMAIN',
            jenkins_ssh_key => '$(cat ${JENKINS_SSH_PUBLIC_KEY}.pub | cut -d ' ' -f 2)', "

sudo puppet apply --verbose $PUPPET_MODULE_PATH -e "class {'openstackci::logserver': $CLASS_ARGS }"

in_log=test_input.log
cat <<EOF > $in_log
This is a test
EOF

out_log=/srv/static/logs/test.log

sudo rm -f $out_log
#SCP the file using the defined key
scp -i $JENKINS_SSH_PUBLIC_KEY -o StrictHostKeyChecking=no $in_log jenkins@localhost:$out_log

#See if you can view the file
wget -O test.log http://localhost/test.log > /dev/null 2> /dev/null

set +e
cmp --silent $in_log test.log
result=$?
if [[ "$result" == "0" ]] ; then
   echo "Congrats"
else
   echo "Sorry: Files don't match"
   diff $in_log test.log
fi

exit $result

