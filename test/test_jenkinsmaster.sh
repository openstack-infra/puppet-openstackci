#! /usr/bin/env bash

# Copyright (c) 2015 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
export DOMAIN=test.domain.com
export ADMIN_MAIL=admin@test.domain.com

# Create certificates
if [[ ! -e /etc/ssl/private/${DOMAIN}.key ]]; then
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=FR/O=Somewhere/CN=test" -keyout /etc/ssl/private/${DOMAIN}.key -out /etc/ssl/certs/${DOMAIN}.pem
    sudo cp /etc/ssl/certs/${DOMAIN}.pem /etc/ssl/certs/intermediate.pem
fi

PUPPET_MODULE_PATH="--modulepath=/etc/puppet/modules"

# Install Puppet and the OpenStack Infra Config source tree
if [[ ! -e install_puppet.sh ]]; then
  wget https://git.openstack.org/cgit/openstack-infra/system-config/plain/install_puppet.sh
  sudo bash -xe install_puppet.sh
  sudo git clone https://review.openstack.org/p/openstack-infra/system-config.git \
    /root/system-config
  sudo /bin/bash /root/system-config/install_modules.sh
fi

CLASS_ARGS="serveradmin => '${ADMIN_MAIL}',
            vhost_name => '$DOMAIN',
            "
set +e
sudo puppet apply --test $PUPPET_MODULE_PATH -e "class {'openstackci::jenkins_master': $CLASS_ARGS }"
PUPPET_RET_CODE=$?
# Puppet doesn't properly return exit codes. Check here the values that
# indicate failure of some sort happened. 0 and 2 indicate success.
if [ "$PUPPET_RET_CODE" -eq "4" ] || [ "$PUPPET_RET_CODE" -eq "6" ] ; then
    exit $PUPPET_RET_CODE
fi
set -e

sleep 5 # Give sometime to jenkins
curl -I http://localhost:8080 | grep '^X-Jenkins'

exit 0
