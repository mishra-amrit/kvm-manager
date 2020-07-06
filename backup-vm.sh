#!/bin/bash

TIMESTAMP=`date +%s`
VM_NAME="centos8"
VM_DISK_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_disk.qcow2"
VM_ARCHIVE_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}.gz"

#VM_MEM_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_mem.qcow2"
VM_CONFIG_FILE="/var/lib/libvirt/backups/${VM_NAME}_${TIMESTAMP}_conf.xml"

echo "dumping xml configuration file.."
virsh dumpxml $VM_NAME > $VM_CONFIG_FILE

echo "freezing filesystems on the vm.."
virsh domfsfreeze $VM_NAME

echo "creating snapshot.."
virsh snapshot-create-as \
	--domain $VM_NAME \
	--name "bkp-${TIMESTAMP}" \
	--disk-only \
	--atomic \
	--diskspec vda,file=$VM_DISK_FILE,snapshot=external \
	--no-metadata
echo "snapshot created."

echo "archiving snapshot.."
dd if=/var/lib/libvirt/images/centos8.qcow2 | gzip | dd of=$VM_ARCHIVE_FILE bs=4096
echo "snapshot archived."

echo "releasing filesystem."
virsh domfsthaw $VM_NAME

echo "performing blockcommit."
virsh blockcommit $VM_NAME vda --active --pivot --verbose
