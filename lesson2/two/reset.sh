docker exec -it r1 vbash -c "ip link delete eth10"
docker exec -it r1 vbash -c "ip link delete eth11"

docker exec -it r2 vbash -c "ip link delete eth20"
docker exec -it r2 vbash -c "ip link delete eth21"

docker exec -it r3 vbash -c "ip link delete eth30"
docker exec -it r3 vbash -c "ip link delete eth31"

docker exec -it s1 bash -c "ip link delete eth1"
docker exec -it s2 bash -c "ip link delete eth1"

# vyosを一度止めてまた動かすと壊れるので消してしまう
docker rm r1 r2 r3

# 全ての ovs-bridge を消す
for bridge in $(sudo ovs-vsctl list-br); do sudo ovs-vsctl del-br $bridge; done
echo "done"
