sudo ip link set wwp0s20u4i12 down
sudo ip addr flush dev wwp0s20u4i12 
sudo ip -6 addr flush dev wwp0s20u4i12 
sudo ip link set wwp0s20u4i12 up
sudo ip addr add 100.106.210.117/30 dev wwp0s20u4i12 broadcast +
sudo ip route add default via 100.106.210.118 dev wwp0s20u4i12
sudo ip link set mtu 1428 dev wwp0s20u4i12 
sudo systemd-resolve -4 --interface=wwp0s20u4i12 --set-dns=172.20.2.39
sudo systemd-resolve -4 --interface=wwp0s20u4i12 --set-dns=172.20.2.10
