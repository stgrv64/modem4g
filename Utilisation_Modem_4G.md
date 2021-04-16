# Choix du modem

Le choix du modem s'est porté sur le EM7455, qui est aujourd'hui facilement approvisionnable et est utilisé sous Loinux.

C'est un module Sierra Wireless basé sur une puce Qualcomm.
On le trouve sous plusieurs appelations avec différents VID/PID USB :

- 413C : 81B6 - Dell DW5811e LTE version
- 413C : 81B8 - Dell DW5811e **HSPA only** version (NE PAS UTILISER)
- 1199 : 9071 - EM7455 Generic Sierra Wireless
- 1199 : 9079 - EM7455 Lenovo version

C'est un modem haut débit qui est accessible par les protocoles `MBIM` ou `QMI` qui utilise `Ethernet over USB`.
`MBIM`, or Mobile Broadband Interface Model, is an official USB standard created by the USB Implementors Forum.
`QMI` or Qualcomm Mobile Station Modem Interface was developed by Qualcomm and is only supported by Qualcomm chips.

Il offre également trois interfaces série (non accessibles par défaut) pour accéder au GPS et aux commandes AT.

# Tests sous Linux

## Raspbian

Le modem est reconnu sous Raspbian

```sh
pi@raspberrypi:~ $ sudo dmesg | grep cdc
[ 1674.644230] usbcore: registered new interface driver cdc_ncm
[ 1674.660837] usbcore: registered new interface driver cdc_wdm
[ 1674.730893] cdc_mbim 1-1.5:1.12: cdc-wdm0: USB WDM device
[ 1674.732601] cdc_mbim 1-1.5:1.12 wwan0: register 'cdc_mbim' at usb-20980000.usb-1.5, CDC MBIM, 9e:f2:e0:af:3f:2e
[ 1674.733492] usbcore: registered new interface driver cdc_mbim
```

```sh
wget https://www.thinkpenguin.com/files/em7455-modem-software/swi_setusbcomp.pl
chmod +x swi_setusbcomp.pl
sudo apt install libuuid-tiny-perl libipc-shareable-perl

# Pour voir la config (normalement mode 9 (MBIM) par défaut)
sudo ./swi_setusbcomp.pl
# Pour basculer en mode 8 afin d'accéder aux ports série pour AT et GPS
sudo ./swi_setusbcomp.pl --usbcomp=8
# Pour vérifier la config
sudo ./swi_setusbcomp.pl
# Pour reactiver le modem et créer les ports série
sudo ./swi_usbcomp.pl –reset
```

## Commandes AT

Source : 
[Comment utiliser MBIM](https://gist.github.com/Juul/e42c5b6ec71ce11923526b36d3f1cb2c)
[Commandes AT](https://ltehacks.com/viewtopic.php?t=33)

En utilisant minicom
```sh
minicom -o -D /dev/ttyUSB2 -b 9600

# Pour entrer en mode commande
at!entercnd="A710"
# Status ?
at+cpin?
# Bascule en MBIM
at!usbcomp = 1,1,1009
# Sauvegarde des modifications
at!reset
```

at+cpin

AT+COPS=? permet de lister les opérateurs accessibles.

## Protocole MBIM

```sh
sudo apt install libmbim-utils
```

Editer `/etc/mbim-network.conf` (le créer si nécessaire) pour entrer l'APN du fournisseur d'accès.
Soit, une ligne contenant `APN=mmsbouygtel.com` # APN=sl2sfr pour SFR

```sh
sudo service network-manager stop
# Pour récupérer les caractéristiques du modem
sudo mbimcli --device=/dev/cdc-wdm0  --query-device-caps
# Pour récupérer le niveau de signal
sudo mbimcli -d /dev/cdc-wdm0 --query-signal-state
# Pour vérifier les réseaux accessibles
sudo mbimcli -d /dev/cdc-wdm0 --query-visible-providers
# Pour activer la connexion 
sudo mbim-network /dev/cdc-wdm0 start
```

Si ça fonctionne, une interface du type wwan0 devrait être créée.
On peut la voir en tapant `ip link`.

Pour savoir quelle IP, gateway, DNS utiliser, on utilise :
```sh
sudo mbimcli -d /dev/cdc-wdm0 -p --query-ip-configuration

sudo ip link set dev wwan0 up
sudo ip addr add <IP/subnet> dev wwan0
sudo ip route add default via <Gateway> dev wwan0
```

Il faut ensuite installer un serveur de nom. On le configure en éditant le fichier `/etc/resolv.conf`.
