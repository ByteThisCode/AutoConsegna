#!/bin/bash

IP_CLIENT=10.10.10.1
IP_ROUTER=localhost
IP_SERVER=10.20.20.1


#--------------------------------CLIENT-----------------------------------#

mkdir -p Client/root

#Tutti i file nella home
scp -r root@$IP_CLIENT:/root/ ./Client/root/
rm -rf ./Client/root/.*

#History
scp root@$IP_CLIENT:/root/.bash_history ./Client/root/.bash_history

#Interfaces
mkdir -p Client/etc/network/
scp root@$IP_CLIENT:/etc/network/interfaces ./Client/etc/network/




#--------------------------------ROUTER-----------------------------------#

mkdir -p Router/root

#Tutti i file nella home
#scp -r root@$IP_ROUTER:/root/[!.]* ./Router/root/
#rm -rf ./Router/root/.*

#History
#scp root@$IP_ROUTER:/root/.bash_history ./Router/root/.


#Interfaces and dnsmasq
mkdir -p Router/etc/network/
#scp root@$IP_ROUTER:/etc/network/interfaces ./Router/etc/network/interfaces
#scp root@$IP_ROUTER:/etc/dnsmasq.conf ./Router/etc/dnsmasq.conf

#SE ROUTER LOCALE
cp -r /root/ ./Router/root/
rm -rf ./Router/root/.*
cp /root/.bash_history ./Router/root/
cp /etc/network/interfaces ./Router/etc/network/
cp /etc/dnsmasq.conf ./Router/etc/



#--------------------------------SERVER-----------------------------------#

mkdir -p Server/root

#Tutti i file nella home
scp -r root@$IP_SERVER:/root/ ./Server/root/
rm -rf ./Server/root/.*

#History
scp root@$IP_SERVER:/root/.bash_history ./Server/root/.bash_history

#Interfaces
mkdir -p Server/etc/network/
scp root@$IP_SERVER:/etc/network/interfaces ./Server/etc/network/interfaces




#----------------------------------TAR------------------------------------#

#tar -zcvf esame.tar.gz ./Client ./Router ./Server

tar -cvzf esame.tgz ./Client ./Router ./Server
