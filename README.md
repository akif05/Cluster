#RH clustering
## Clustering, Clastering, read from stdin
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
	
### Ha on redhad (centos)
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



####### ssh tunnel
### Working all the 3 for loops !!!!!
for i in `seq 1 3`; do ipaddr=$(printf "192.168.4.2%d0\n" $i); echo $ipaddr; ssh root@$ipaddr 'yum -y install epel-release; \
					yum -y install pcs fence-agents-all; \
					firewall-cmd --permanent --add-serice=high-availablility; \ 
					firewall-cmd --reload; \ 
					systemctl enable --now pcsd; \
					echo password | passwd --stdin hacluster'
					done

#########################################################################
for i in `seq 1 3`; do ipaddr=$(printf "192.168.4.2%d0\n" $i); ssh root@$ipaddr 'awk "!/192.168.4/" /etc/hosts > temp && mv temp /etc/hosts <<< yes; \
			printf "192.168.4.210\tserver1.example.com\tserver1\n192.168.4.220\tserver2.example.com\tserver2\n192.168.4.230\tserver3.example.com\tserver3\n" >> /etc/hosts'
			done

for i in `seq 1 3`; do ipaddr=$(printf "192.168.4.2%d0\n" $i); ssh root@$ipaddr 'cat /etc/hosts'
			done

## Do not use this scripts in production!!!
## Delete the lines starting with 192.168... from the hosts file
for i in `seq 1 3`; do ipaddr=$(printf "192.168.4.2%d0\n" $i); echo $ipaddr; ssh root@$ipaddr 'awk "!/192.168*/" /etc/hosts > temp && mv temp /etc/hosts <<< yes'
			done
