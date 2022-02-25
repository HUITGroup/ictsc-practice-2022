sudo ovs-vsctl list-br

sudo ovs-vsctl add-br br-1
sudo ovs-vsctl add-br br-2

sudo ovs-vsctl list-br

sudo ovs-docker add-port br-1 eth10 r1
sudo ovs-docker add-port br-1 eth11 s1

sudo ovs-docker add-port br-2 eth12 r1
sudo ovs-docker add-port br-2 eth13 s2

docker exec r1 bash -c "mkdir -p /config && touch /config/dhcpd.leases"

echo "done"
