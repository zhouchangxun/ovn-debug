#!/bin/bash

. env.sh
. lib-vm.sh
. lib-ovn.sh
. lib-trace.sh
#########################################
echo \
"====== ovn debug env ready! =======
available cmd:
  ==== vm command=======
  1. vm_add
  2. vm_del
  3. vm_list
  ==== switch command=======
  1. switch_add
  3. switch_del
  4. switch_port_add
  5. switch_port_del
  ==== router command=======
  1. router_add
  2. router_del
  3. router_interface_add
  4. router_interface_del
  5. router_gateway_add
  6. router_gateway_del
  ==== trace command=======
  1. send_icmp [vm] [dest ip] 
"

function topo_create(){
switch_add ls1
vm_add vm1 192.168.1.1/24 192.168.1.254
switch_port_add ls1 vm1

switch_add ls2
vm_add vm2 10.1.1.1/24 10.1.1.254
switch_port_add ls2 vm2

router_add lr1
router_interface_add lr1 ls1 192.168.1.254/24
router_interface_add lr1 ls2 10.1.1.254/24

#switch_add ls-ext
#router_interface_add lr1 ls-ext 123.1.1.10/24
#chassis=86710d17-4051-4000-9afc-b20c058a7fca
#ovn-nbctl set logical_router lr1 options:chassis=$chassis

}

function topo_del(){
  vm_del vm1;
  vm_del vm2;
  switch_del ls1
  switch_del ls2
  router_del lr1
}
