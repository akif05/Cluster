#H clustering
# Clustering, Clastering, read from stdin
corosync on suse
First node: "node1"
	zypper in ha-cluster-bootstrap
	ha-cluster-inet

All other nodes
	zypper in ha-cluster-bootstrap
	ha-cluster-join -c node1

# Check status
	crm_mon
	systemctl status corosync
	
#4.  Configure corosync on Red Hat
# Ha on redhad (centos)
# on all the nodes
yum -y install epel-release
yum -y install pcs fence-agents-all
firewall-cmd --permanent --add-serice=high-availablility 
systemctl enable --now pcsd
echo password | passwd --stdin hacluster

# Authenticate all nodes. Run the command on one node ONLY!
pcs cluster auth server1.example.com server2.example.com server3.example.com

Provide hacluster username and password, that was created

pcs cluster setup --start --name mycluster server1.example.com server2.example.com server3.example.com

After reboot node will not join the cluster automaticaly!
If you want to join automaticaly run:
	pcs cluster enable --all

# Verify cluster opearation
pcs cluster status
systemctl status pcsd
systemctl status corosync
systemctl status corosync -l



# ssh tunnel
# Working all the 3 for loops !!!!!
for i in `seq 1 3`; do ipaddr=$(printf "192.168.4.2%d0\n" $i); echo $ipaddr; ssh root@$ipaddr 'yum -y install epel-release; \
					yum -y install pcs fence-agents-all; \
					firewall-cmd --permanent --add-serice=high-availablility; \ 
					firewall-cmd --reload; \ 
					systemctl enable --now pcsd; \
					echo password | passwd --stdin hacluster'
					done

####
for i in `seq 1 3`; do ipaddr=$(printf "192.168.4.2%d0\n" $i); ssh root@$ipaddr 'awk "!/192.168.4/" /etc/hosts > temp && mv temp /etc/hosts <<< yes; \
			printf "192.168.4.210\tserver1.example.com\tserver1\n192.168.4.220\tserver2.example.com\tserver2\n192.168.4.230\tserver3.example.com\tserver3\n" >> /etc/hosts'
			done

for i in `seq 1 3`; do ipaddr=$(printf "192.168.4.2%d0\n" $i); ssh root@$ipaddr 'cat /etc/hosts'
			done

# Do not use this scripts in production!!!
# Delete the lines starting with 192.168... from the hosts file
for i in `seq 1 3`; do ipaddr=$(printf "192.168.4.2%d0\n" $i); echo $ipaddr; ssh root@$ipaddr 'awk "!/192.168/" /etc/hosts > temp && mv temp /etc/hosts <<< yes'
			done
#

# CIB = Cluster Information Base
Cluster information base is inmemory state of the Cluster

Crmd is 
# CIB = Cluster Information Base
Cluster information base is inmemory state of the Cluster
It is running  in all nodes

Crmd is  rununig on all nodes to provide access to CIB
Cluster Resource Management Daemon

If node needs to creport for a change it is sending infor ot CRMD in all nodes
CRMD is passing ifor ot CIB

Local Resource Manager Daemon
Local service manager


pcs is command line tool to talks pcsd which talks to crmd
pcsd is daemon syncronizes between nodes and
allowes pcs to issue commands that realate to entyer cluster
including creation of the cluster.

On Suse crmsh is command to speack directly to crmd
crmsh  = crmshell
crm tab tab
cibadmin ==== is used to modify cluster config xml code

# Qurey 
cibadmin -Q | less

crm configure tab tab
# Show the cluster information
crm configure show
crm configure edit

crm configure     == opens live shel
crm configure
# Create ip address resource and monitor it every 20 seconds
primive newip ocf:heartbeat:IPaddr2 params ip=192.168.122.55 op monit interval=20s
exit

# write configuration into file
crm configure save cluster-$(date +%m-%d)-01.txt

# Destroy everyting
cibadmin -E --force

# Restore whole cluster from saved config
crm configure load push cluster-06-19-11.txt

# To find out all specification
vi /usr/share/pacemaker/crm.dtd


# PCS
# check if pcsd running on all nodes
systemctl status pcsd
pcs tab tab
pcs cluster edit
export EDITOR=/usr/bin/vi
# looks licke crm
# check if bash complition is installed
# Create modify resources
pcs resource 
rpm -q | grep bash-com
pcs resource list | less

# Resource for HA
pcs resource describe IPaddr2

# Create Filesystem resource
# macke sure that /dev/sdc1 exist on all nodes!!!
# use pcs resource show
pcs resource create httpfs Filesystem device=/dev/sdc1 directory=/srv/www/htdocs fstype=ext4

# Create an ip address for HA
                    name   Type
pcs resource create myhaip IPaddr2 ip=192.168.4.254 cird_netmask=24 

# In Suse there is HAWK "High Availability Web Console(K in German)
# User hacluster (set when created cluster) and default pass linux

# Generic cluster properties
pcs property list --all | less
 maintenance-mde
 no-quorum..
 shutdown-escalatiion
 stonit-enabled

# How to change property in RedHat
pcs property set stonit-enabled=false

# Suse
crm configure property enable-acl=yes

# Creating resources, monitor, start, stop
open cluster framework == ocf
On Suse
crm ra classes
crm ra list ocf
crm ra info apache
crm ra info Dumy

pcs resource list | less
pcs resource describe virtual-domain

# Fro the web server we need apache resource agent and
# an ip address resorce ( going together, use groups and constrains)

# Suse
crm configure edit

primitive admin_addr IPaddr2 \
        params cidr_netmask="24" ip="192.168.4.101" \
        op monitor interval=10 timeout=20

primitive ip-apache ocf:heartbeat:IPaddr2 \
        params cidr_netmask="24" ip="192.168.4.102" \
        op monitor interval=10 timeout=20

primitive service-apache ocf:heartbeat:apache \
        op stop interval=0 timeout=60 \
        op start interval=0 timeout=60 \
        op monitor interval=10 timeout=60 \    
:wq

ozyper se apache
# On all the nodes !!!
zyper in apache2
crm_mon
crm resource tab tab
crm resource cleanup service-apache

# CentOS
pcs resource list | less
pcs resource describe apache
pcs resource create apache-ip IPaddr2 ip=192.168.4.111 cird_netmask=24
pcs resource show
pcs property set stonit-enabled=false
pcs resource create apache-service apache
pcs resource show

# Configure stonit
# quorum will be configured with corosync0
corosync-quorum
corosync-quorumtool --help
crm_mon

# pcs cluster setup on Red Hat
# Specific options can be used to manipulate quorum
--wait_for_all : wait for all nodes to join the cluster 
                 before applying quorum calculation
--auto_tie_break: 50% will give quorum as well.
                In this case the side with lover ID will win
--last_man_standing: quorumms recalcualationd every 10sec. which
                allowes admins to take out quorum nodes one by one.
                Must be used with --wait_for_all
--two_noe: allows fo a 2 node cluster

# On Suse use settings in corosync.conf

# on Red Hat
# Schedule maintenance and bring down the cluster before applaying changes!
# Or use  systemctl restart corosync node by node when changing these options.
vi /etc/corosync/corosync.conf
quorum {
    provider: corosync_votequorum
    last_man_standing: 1
    wait_for_all: 1
    auto_tie_breaker: 1
    auto_tie_breaker_node: lowest
}
:wq

systemctl restart corosync

pcs cluster sync
pcs cluster start -all
# Verify modifications
corosync-quorumtool

# Quorum and fencing(stonit) are used to mentain integrity of cluster
# If we want to mover 
# There are two fencing mechanisms
#   Power fencig
#   Fabric fencing
# Fencing mechanisms are implemented different fencing agents

# Diferent types of Fence
# Software solutions to prevent failde node to start
    disk
    hypervisor
    power switch
    management board     === ilo or drac
    test agents

fence_apc --help
pcs stonith list

pcs stonith list
pcs stonith describe
pcs stonith crearte name fencing_agent

To use fancing device, fencing agent needs to be configured.
#6. Configure fencing(stonit) on Centos
# Setting up fence-virtd
# On hipervisor
yum -y install fence-virt fence-virtd fence-virtd-libvirt fence-virtd-multicast
# Create shared secret
mkdir -p /etc/cluster
dd if=/dev/urandom of=/etc/cluster/fence_xvm.key bs=1k count=4
# command above will create random key 4KB 
# configure fence_virtd
fence_virtd -c
systemctl enable --now fence_virtd
# Copy shared key to all hipervisors
# in all nodes
mkdir /etc/clustr
for i in 210 220 230; do scp /etc/cluster/fence_xvm.key 192.168.4.$i:/etc/cluster/; done

virsh list
pcs stonit create fence-centos11 fence_xvm port=centos11 pcmk_host_list=server11.example.com
pcs stonit create fence-centos12 fence_xvm port=centos12 pcmk_host_list=server12.example.com
pcs stonit create fence-centos13 fence_xvm port=centos13 pcmk_host_list=server13.example.com

# Verify
crm_mon

# On virtual machines use:
fence_xvm

#fence_xvm is used on VMs that are on a fence_virtd hypervisor
# Copy /etc/cluster/fence_xvm.key from Host to all vms

# Create fence agent
# Create fence-xvm for all vms
pcs stonith create fence-vm1 fence_xvmm port="vm1" pcmk_host_list="vm1.example.com"
    fence-vm1   - Name of the fence device in the cluster
    fence_xvm   - Nmae of the agent module
    port        - Specifies the (virsh) name of the vm
    pcmk_host_list - Cluster node name

# Test the fencing agent
pcs stonith fence nodename  - thise will reboot the node
pcs stonith fence --off     - these will remove the fencing

# Monitor multicast traffic!!
tcpdump -i virbr -s0 -vv net 224.0.0.0/4

firewall-cmd --permanent --dirct --add-rule ipv4 filter INPUT 0 -m pkttype --pkt-type multicast -j ACCEPT
    OR USE NEXT COMMAND
firewall-cmd --permanent --add-port=1229/udp

systemctl status fence_virtd
virsh list

pcs stonit show 

# thise will frize virtual mashin ( run command on the vm to freez it)
echo c > /proc/sysrq-trigger

pcs cluster status
pcs stonith fence server11.example.com    ( server11 is vm)

# Configure storage fencing
# A device is needed to support SCSI reservation
# RHEL 7 it has a support

# Cluster node will add a key to the shared SCSI device after starting
# When a node needs to be fenced, the other node will remove the
#   node key of the fence target

# Options to be used:
devices=devicepath  ( use /dev/disk/by-id/)
pcmk_monitor_action=metadata
pcmk_host_list=FQDN
pcmk_reboot_action="off"
meta provides="unfencing"
    This options sets the node status to unfenced after it re-joins the cluster
# Redundant fencing is configured by using fencing level
    All level 1 devices are attempted first, before trying level 2 devices

pcs stonit levle add <level> <node> <devices>
    pcs stonit level add 1 node1 fence_node1_ilo
    pcs stonit level add 2 node1 fence_nolde1_apc
# Use pcs stonith level to view fence level configuration
pcs stonith level
pcs stonith level remove 1

pcs stonit show
pcs stonith fence hostname 
fence_xvm -o list


# on Suse use sbd
sbd -d /dev/watherver message hostname { poweroff | reset } to test
fence_scsi     

##7. Resource management
# Resource is anything that is manged by cluster
# These are scripts used to manage cluster (ocf scripts, systemd scrpts)
Open cluster framework  : ocf
in ocf script we can put anyting 
systemd scripts can be managed from cluster
stonit resource management

# Resource types
Primitives  - singular resource that is started ones (like ipaddress)
Clone       - Managed from cluster and running on multiple nodes in same time ( storage )
Multy state (aka Master/Slave) - as drbd
Group       - Group of primitives   ( haipaddres, shared storage, web server)

# Default resource stickiness  ( what to do if primary node failes and after is back, what is happening to resource )
# Createin resources
find / -name IPaddr2
cd /usr/lib/ocf/resource.d/
vi IPaddr2
info IPaddr2

# in Suse
crm configure primitive newip ocf:heartbeat:IPaddr2 params ip=192.168.4.244/24 op monitor interval=10s
crm recource show newip
crm_mon

cibadmin -

## CentOS
pcs status
pcs resource create mynewip IPaddr2 ip=192.168.4.244
pcs status

# Working with resources in a cluster!!!!
# Create resource constraints
# USIING GROUPS IS BETTER THAN USING CONSTRAINTS!!!
    Location   - where resource is going to run
    Colocation
    Order

# Using score to give priority to node | give lover or higer
    INFINNITY (1,000,000): must happen
    -INFINNITY (-1,000,000): must not happen
# Resouce migration will enforce a constraint on the resource
    pcs resource move     |      crm migrate
    pcs resource clerar   |      crm unmigrate
# -INIFINITY on location constraint will never run the resource on the node 
# specified, even if the node is the last in the cluster.

# Using constraints
location constraint
# will give score of 1000 for mariadb to run on node2
location db-on_node2 mariadb 1000:node2

# Will start ip before web
order ip-before-web Mandatory: ip web

# inf == means infinity ( must happen )
# Drbd can't be promoted from master to slave before ip address is started
order ip-befoe-DRBD-promote inf:ip:start drbd:promote

# -inf Never web1 and web2 are running in same node
colocation web1-not-with-web2 -inf: web1 web2


## pcs does not need name for the constraints.
## pcs will add the name automaticaly
pcs constraint location web prefers node1

# Try to run on node1 if not run on node2
pcs constraint location web prefers node1=1000; pcs constraint location
                                                web prefers node2=500
pcs constraint location web avoids node1

# web1 and db1 should work together
pcsconstraint colocation add web1 with db1

# web1 and db1 shold be never together!
pcs constraint colocation add web1 with db1 -INFINITY
pcs constraint order webip thenn webserver

## Will show all scores.
crm_simulate -sL

## Using Groups is better solution!!!
pcs resource create myip IPaddr2 ip=192.168.4.240 --group mygroup 
pcs resource create myfs Filesystem device=/dev/sdb1 directory=/myfs --group mygroup

# Resources and groups can be created independantly
# first create resources and then groups
# this is prefered way
group mygroup myip myweb

# if one resource fails wholle resource group will fail!!!
pcs resource creaete ip1 IPaddr2 ip=10.0.0.1 cidr_netmask=24 --group ipgoup
pcs resource creaete ip2 IPaddr2 ip=10.0.0.2 cidr_netmask=24 --group ipgoup
pcs status

## Clone
Primitive that should be started multiple time

## For troublsooting use journalctl -xe or other logs!!!
# Reset the failcoint on the resource

pcs resource failcount show
pcs resource debug-start myresource
pcs resource failcont myresource mynode
pce resource cleanup myresource
crm resource cleanup myresource

less /var/log/
pcs resource describe IPaddr2

# Edit directly xml file
pcs cluster edit

ip addr show
pcs resource update ip1 nic=eth0
pcs resource update ip1 nic=eth1

pcs status

#7.Lab:
# Configure two resource groups, one for Apache and one for vsftpd
# In the groups, have the serices started and give both of them a unique ip addr
# The resource groups may only run on the same node if there is no
#   other choice, but by default they should try to avoid one another
# The vsftpd resource group should be started before the apache resource group

#####
pcs resource group add apache-group apche-ip
pcs resource group add apache-group apache-service
pcs resource create ftp-ip IPaddr2 ip=192.168.4.222 cidr_netmask=24 --group ftp-group
pcs resource list | grep -i ftp
rpm -qa | grep ftp
yum install vsftpd -y

## this is systmd type resource
pcs resource create ftp-service systemd:sftpd --group ftp-group

pcs constraint colocation add apache-group with ftp-group -10000
pcs constraint order apache-group then ftp-group

pcs resource mange
pcs resource unmange

pcs resource utilization myresource ram=20 cpu=10

# Set ntp sync on cenots 7
ser2 'timedatectl set-ntp 0; timedatectl set-ntp 1;'
ser3 'timedatectl set-ntp 0; timedatectl set-ntp 1;'

ssh root@server1 'timedatectl set-ntp 0; timedatectl set-ntp 1;'
ssh root@server2 'timedatectl set-ntp 0; timedatectl set-ntp 1;'

