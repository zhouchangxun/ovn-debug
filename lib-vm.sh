#!/usr/bin/env bash

. lib-common.sh

#
# Delete namespaces from the running OS
#
function ns_del ()
{
  local name=$1;
  ip netns del $name
}

#
# Add new namespaces, if ns exists, the old one
# will be remove before new ones are installed.
#
function ns_add ()
{
  local name=$1;
  ip netns add $name 
}

#
# Execute 'command' in 'namespace'
#
function ns_exec ()
{
  local name=$1;
  ip netns exec $@
}

# ADD_VETH([port], [namespace], [ovs-br], [ip_addr] [mac_addr [gateway]])
#
# Add a pair of veth ports. 'port' will be added to name space 'namespace',
# and "ovs-'port'" will be added to ovs bridge 'ovs-br'.
#
# The 'port' in 'namespace' will be brought up with static IP address
# with 'ip_addr' in CIDR notation.
#
# Optionally, one can specify the 'mac_addr' for 'port' and the default
# 'gateway'.
#
# The existing 'port' or 'ovs-port' will be removed before new ones are added.
#
function add_veth ()
{
local namespace=$1
local vm=$1
local ip_addr=$2
local gateway=$3
local mac_addr=$4
      # add veth pair interface.
      ip link add veth-$vm type veth peer name ovs-$vm || return 77

      # move veth-$vm to vm's namespace
      ip link set veth-$vm netns $vm

      ip link set dev ovs-$vm up
      ovs-vsctl add-port br-int ovs-$vm 
      ns_exec $vm "ip addr add $ip_addr dev veth-$vm"
      ns_exec $vm "ip link set dev veth-$vm up"

      if test -n "$gateway"; then
        ns_exec $vm "ip route add default via $gateway"
      fi

      if test -n "$mac_addr"; then
        ns_exec $vm "ip link set dev veth-$vm address $mac_addr"
      fi
}

function vm_add()
{
  if [[ $# -lt 3 ]]; then
    echo "help: vm_add [vm_name] [ip/mask] [gateway] "
    return 1
  fi
  local vm_name=$1
  local ip=$2  #format as x.x.x.x/length
  local gw=$3
  local mac=$4

  ns_add $vm_name 
  ns_exec $vm_name "ifconfig lo up"
  add_veth $vm_name $ip $gw $mac
}

function vm_del()
{
set -x
  vm_name=$1
  ip link del ovs-$vm_name >/dev/null 2>&1
  ovs-vsctl del-port br-int ovs-$vm_name >/dev/null 2>&1
  ns_del $vm_name >/dev/null 2>&1
set +x
}

function vm_exe()
{
  ns_exec $@ 
}
function vm_list()
{
  ip netns
}

echo 'import lib-vm-port...'

# end

