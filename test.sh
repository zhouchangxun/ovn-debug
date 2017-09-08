
portname=lsp_neutron-b5a0a70e-824c-4a01-9b15-34e1c4c6c6f9-vm1
ofport=`ovs-vsctl --bare --columns=ofport find  interface external-ids:iface-id="$portname"`

ovn-trace  neutron-b5a0a70e-824c-4a01-9b15-34e1c4c6c6f9 \
	   'inport == "$portname"
           && eth.dst == fa:16:3e:ea:89:a2 && eth.src == fa:16:3e:d1:bf:dd 
	   && ip4.dst == 172.17.1.254 && ip4.src == 172.17.1.110 && ip.ttl==64'
