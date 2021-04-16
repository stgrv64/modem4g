sudo ip link set wwan0 down
sudo ip addr flush dev wwan0 
sudo ip -6 addr flush dev wwan0 
sudo ip link set wwan0 up
sudo ip addr add 100.106.210.117/30 dev wwan0 broadcast +
sudo ip route add default via 100.106.210.118 dev wwan0
sudo ip link set mtu 1428 dev wwan0 
sudo systemd-resolve -4 --interface=wwan0 --set-dns=172.20.2.39
sudo systemd-resolve -4 --interface=wwan0 --set-dns=172.20.2.10

