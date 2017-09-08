


sip=$(get_ip vm1)
smac=$(get_mac vm1)

inport=$(ovs-vsctl --bare --columns=ofport find  interface name=ovs-vm1)

dip=$(get_ip vm2)
dmac=`$NBCTL list logical_router_port lrp-lr1-to-ls1 |grep mac |cut  -d "\"" -f2`

#ovs-appctl ofproto/trace br-int "in_port=$inport,dl_src=$smac,dl_dst=$dmac, ip,nw_src=$sip,nw_dst=$dip,nw_proto=1,nw_ttl=64" -generate

#@1 arp追踪测试：
send_arp_request(){
$OVNTRACE  ls1 \
	"inport == \"lsp_ls1-vm1\" 
&& eth.dst == ff:ff:ff:ff:ff:ff && eth.src == $smac 
&& arp.op == 1 && arp.sha == $smac  && arp.spa == $sip 
&& arp.tha == ff:ff:ff:ff:ff:ff && arp.tpa == 192.168.1.254" 
}
#@L2测试
#ovn-trace  690204f9-f78d-4e95-a2b4-7b6be257b650 \
#	'inport == "c4a7bfb3-2ae3-4756-9313-8fe5ba346d32" 
#&& eth.dst == fa:16:3e:ea:89:a2 && eth.src == fa:16:3e:d1:bf:dd '
#

##@L3路由测试
send_ip(){
$OVNTRACE  ls1 \
	"inport == \"lsp_ls1-vm1\" 
&& eth.dst == $dmac && eth.src == $smac 
&& ip4.dst == 10.1.1.1 && ip4.src == $sip && ip.ttl==64"
}

send_ip

