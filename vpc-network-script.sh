#!/bin/bash

#Google cloud project conducted by me Tobez

#VPC NETWORK BASH SCRIPT

#Explore the networks and instances
gcloud compute networks subnets list --network default
gcloud compute routes list --filter="network=default AND priority=1000"
gcloud compute firewall-rules list
gcloud compute firewall-rules delete [NAME]
gcloud compute networks delete default

#Create an auto mode VPC network with firewall rules
gcloud compute networks create mynetwork --subnet-mode=auto --mtu=1460 --bgp-routing-mode=regional

#Creating firewall rules
gcloud compute firewall-rules create mynetwork-allow-custom --network mynetwork --description=Allows\ connection\ from\ any\ source\ to\ any\ instance\ on\ the\ network\ using\ custom\ protocols. --direction=INGRESS --priority=65534 --source-ranges=10.128.0.0/9 --action=ALLOW --rules=all

gcloud compute firewall-rules create mynetwork-allow-icmp --network mynetwork --description=Allows\ ICMP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network. --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=icmp

gcloud compute firewall-rules create mynetwork-allow-rdp --network mynetwork --description=Allows\ RDP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network\ using\ port\ 3389. --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=tcp:3389

gcloud compute firewall-rules create mynetwork-allow-ssh --network mynetwork --description=Allows\ TCP\ connections\ from\ any\ source\ to\ any\ instance\ on\ the\ network\ using\ port\ 22. --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=tcp:22

#Create a VM instance in the Lab Region region.
gcloud compute instances create mynet-us-vm --zone=us-east1-c --machine-type=e2-micro --network-interface=network-tier=PREMIUM,subnet=default --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --create-disk=auto-delete=yes,boot=yes,device-name=mynet-us-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20221102,mode=rw,size=10 --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

#Create a VM instance in the europe-west1 region.
gcloud compute instances create mynet-eu-vm --zone=europe-west1-c --machine-type=e2-micro --network-interface=network-tier=PREMIUM,subnet=default --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --create-disk=auto-delete=yes,boot=yes,device-name=mynet-eu-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20221102,mode=rw,size=10 --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

#Verify connectivity for the VM instances
gcloud compute ssh mynet-us-vm --zone=us-east1-c --internal-ip
ping -c 3 <Enter mynet-eu-vm's internal IP here>
ping -c 3 <Enter mynet-eu-vm's external IP here>

#Convert the network to a custom mode network
gcloud compute networks create mynetwork --subnet-mode=custom --mtu=1460 --bgp-routing-mode=regional

#Create the managementnet network
gcloud compute networks subnets create managementsubnet-us --range=10.240.0.0/20 --stack-type=IPV4_ONLY --network=managementnet --region=us-east1

#To create the privatenet network
gcloud compute networks create privatenet --subnet-mode=custom

#To create the privatesubnet-us subnet
gcloud compute networks subnets create privatesubnet-us --network=privatenet --region=us-east1 --range=172.16.0.0/24

#To create the privatesubnet-eu subnet
gcloud compute networks subnets create privatesubnet-eu --network=privatenet --region=europe-west1 --range=172.20.0.0/20

#To list the available VPC subnets (sorted by VPC network)
gcloud compute networks list

#To list the available VPC subnets (sorted by VPC network)
gcloud compute networks subnets list --sort-by=NETWORK

#Create firewall rules to allow SSH, ICMP, and RDP ingress traffic to VM instances on the managementnet network.
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=PROTOCOL:PORT,...

#To create the privatenet-allow-icmp-ssh-rdp firewall rule
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

#To list all the firewall rules (sorted by VPC network)
gcloud compute firewall-rules list --sort-by=NETWORK

#Create the managementnet-us-vm instance
gcloud compute instances create managementnet-us-vm --zone=us-east1-c --machine-type=e2-micro --network-interface=network-tier=PREMIUM,subnet=managementsubnet-us --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --create-disk=auto-delete=yes,boot=yes,device-name=managementnet-us-vm,image=projects/debian-cloud/global/images/debian-11-bullseye-v20221102,mode=rw,size=10

#To create the privatenet-us-vm instance
gcloud compute instances create privatenet-us-vm --zone=us-east1-c --machine-type=e2-micro --subnet=privatesubnet-us --image-family=debian-11 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=privatenet-us-vm

#To list all the VM instances (sorted by zone),
gcloud compute instances list --sort-by=ZONE

#To test connectivity to mynet-eu-vm, managementnet-us-vm, and privatenet-us-vm with external IP:
gcloud compute ssh mynet-us-vm --us-east1-c --internal-ip  
ping -c 3 <Enter mynet-eu-vm's external IP here>
ping -c 3 <Enter managementnet-us-vm's external IP here>
ping -c 3 <Enter privatenet-us-vm's external IP here>

#To test connectivity to mynet-eu-vm, managementnet-us-vm, and privatenet-us-vm with internal IP:
gcloud compute ssh mynet-us-vm --us-east1-c --internal-ip
ping -c 3 <Enter mynet-eu-vm's internal IP here>
ping -c 3 <Enter managementnet-us-vm's internal IP here>
ping -c 3 <Enter privatenet-us-vm's internal IP here>