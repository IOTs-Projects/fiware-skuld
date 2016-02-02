#!/bin/bash -ex
# Copyright 2015 Telefónica Investigación y Desarrollo, S.A.U
#
# This file is part of FIWARE project.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at:
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.
#
# For those usages not covered by the Apache version 2.0 License please
# contact with opensource@tid.es
#
# Author: Chema

. config_vars

neutron net-create ext-net --router:external True --provider:physical_network external --provider:network_type flat
neutron subnet-create ext-net --name ext-subnet --allocation-pool start=192.168.58.200,end=192.168.58.219  --disable-dhcp --gateway 192.168.58.1 192.168.58.0/24
neutron net-create shared-net
neutron subnet-create shared-net --name shared-subnet --gateway 192.168.59.1 192.168.59.0/24
neutron router-create shared-router
neutron router-interface-add shared-router shared-subnet
neutron router-gateway-set shared-router ext-net

wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
glance image-create --name cirros --container bare --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --is-public True
NETID=$(neutron net-list |awk '/shared-net/ { print $2 }'
export OS_AUTH_URL=$OS_AUTH_URL_V2
nova keypair-add testkey > ~/.ssh/testkey ; chmod 700 ~/.ssh/testkey
nova secgroup-create ssh "open tcp 22"
nova secgroup-add-rule ssh tcp 22 22 0.0.0.0/0

nova boot testvm --flavor m1.tiny --image cirros --nic net-id=$NETID --key-name testkey --security-groups ssh
