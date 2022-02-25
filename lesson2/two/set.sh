sudo ovs-vsctl list-br

sudo ovs-vsctl add-br br-1
sudo ovs-vsctl add-br br-2
sudo ovs-vsctl add-br br-3
sudo ovs-vsctl add-br br-4

sudo ovs-vsctl list-br

sudo ovs-docker add-port br-1 eth10 r1 --ipaddress=10.1.0.1/24
sudo ovs-docker add-port br-1 eth1 s1 --ipaddress=10.1.0.2/24

sudo ovs-docker add-port br-2 eth20 r2 --ipaddress=10.2.0.1/24
sudo ovs-docker add-port br-2 eth11 r1 --ipaddress=10.2.0.2/24

sudo ovs-docker add-port br-3 eth21 r2 --ipaddress=10.3.0.1/24
sudo ovs-docker add-port br-3 eth31 r3 --ipaddress=10.3.0.2/24

sudo ovs-docker add-port br-4 eth30 r3 --ipaddress=10.4.0.1/24
sudo ovs-docker add-port br-4 eth1 s2 --ipaddress=10.4.0.2/24

# docker exec r1 bash -c "mkdir -p /config && touch /config/dhcpd.leases"

echo "done"
