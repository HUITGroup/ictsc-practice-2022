docker exec -it r1 vbash -c "ip link delete eth10"
docker exec -it r1 vbash -c "ip link delete eth12"

docker exec -it s1 bash -c "ip link delete eth11"
docker exec -it s2 bash -c "ip link delete eth13"

# vyosを一度止めてまた動かすと壊れるので消してしまう
docker rm r1

# 全ての ovs-bridge を削除
for bridge in $(sudo ovs-vsctl list-br); do sudo ovs-vsctl del-br $bridge; done
echo "done"
