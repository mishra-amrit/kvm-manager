#!/bin/bash

TIMESTAMP=`date +%s`
VM_NAME="centos8"
VM_DISK_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_disk.qcow2"
VM_MEM_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_mem.qcow2"
VM_CONFIG_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_conf.xml"

virsh dumpxml $VM_NAME > $VM_CONFIG_FILE

virsh snapshot-create-as \
	--domain $VM_NAME \
	--name "bkp-${TIMESTAMP}" \
	--atomic \
	--quiesce \
	--disk-only \
	--diskspec vda,file=$VM_DISK_FILE,snapshot=external \
	--no-metadata

virsh blockcommit $VM_NAME vda --active --pivot
