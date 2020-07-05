#!/bin/bash

TIMESTAMP=`date +%s`
VM_NAME="centos8"
VM_DISK_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_disk.qcow2"
VM_MEM_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_mem.qcow2"
VM_CONFIG_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_conf.xml"

virsh dumpxml $VM_NAME > $VM_CONFIG_FILE

STATE=`virsh dominfo $VM_NAME | grep "State" | cut -d " " -f 11`

if [ "$STATE" = "running" ]; then
	virsh snapshot-create-as \
		--domain $VM_NAME $VM_BACKUP_NAME \
		--memspec file=$VM_MEM_FILE,snapshot=external \
		--live
else
	virsh snapshot-create-as \
		--domain $VM_NAME $VM_BACKUP_NAME \
		--diskspec sda,file=$VM_DISK_FILE,snapshot=external \
		--disk-only \
		--live
fi
