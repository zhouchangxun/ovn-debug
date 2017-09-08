#!/bin/sh


function get_ip(){
ns=$1
ip=`ip netns exec $ns ifconfig  | grep 'inet '| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2}'`
echo $ip
}

function get_mac(){
ns=$1
mac=`ip netns exec $ns ifconfig  | grep 'ether '| grep -v '127.0.0.1' | cut  -f2 | awk '{ print $2}'`
echo $mac
}

function alloc_mac(){
  MACADDR="fa:16:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4/')";
  echo $MACADDR
}

#usage:
# ip="$(get_ip vm1)"
# mac="$(get_mac vm1)"

echo "import common..."
