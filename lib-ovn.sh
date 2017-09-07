#!/bin/bash

source lib-common.sh


NBCTL="ovn-nbctl --db=tcp:192.168.133.71:6641 "

# View a summary of the configuration
function topo_show(){
  $NBCTL show 
}

function switch_add()
{
  $NBCTL ls-add $1
}
function switch_del()
{
  $NBCTL ls-del $1
}
function switch_port_add()
{
# Create ports on the local OVS bridge, br-int.  When ovn-controller
# sees these ports show up with an "iface-id" that matches the OVN
# logical port names, it associates these local ports with the OVN
# logical ports.  ovn-controller will then set up the flows necessary
# for these ports to be able to communicate each other as defined by
# the OVN logical topology.
  sw=$1
  vm=$2
  lsp="lsp_$sw-$vm"
  mac="$(get_mac $vm)"
  ip="$(get_ip $vm)"

  $NBCTL lsp-add $sw $lsp || return 1
  $NBCTL lsp-set-addresses $lsp "$mac $ip" || return 1
  ovs-vsctl set interface ovs-$vm external-ids:iface-id="$lsp" || return 1

  echo bind $vm with logical switch port $lsp
}
function switch_port_del()
{
  sw=$1
  vm=$2
  lsp="lsp_$sw-$vm"

  $NBCTL lsp-del $lsp
}
function router_add()
{
  $NBCTL lr-add $1
}
function router_del()
{
  $NBCTL lr-del $1
}
function router_interface_add()
{
  router=$1
  switch=$2
  net=$3 # x.x.x.x/length
  ip=${net%/*}
  lrp="lrp-$router-to-$switch"
  lsp="lsp-$switch-to-$router"
  mac="$(alloc_mac)"

  $NBCTL lrp-add $router $lrp $mac $net
  $NBCTL lsp-add $switch $lsp
  $NBCTL lsp-set-type $lsp router
  $NBCTL lsp-set-addresses $lsp router
  $NBCTL lsp-set-options $lsp router-port=$lrp
}
function router_interface_del()
{
  router=$1
  switch=$2
  lrp="lrp-$router-to-$switch"
  lsp="lsp-$switch-to-$router"

  $NBCTL lrp-del $lrp 
  $NBCTL lsp-del $lsp
}


echo 'import lib-ovn-net...'

# end

