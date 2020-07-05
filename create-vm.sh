#!/bin/bash
LIBVIRT_HOME=/var/lib/libvirt
WORKING_DIR=$(pwd)
VM_NAME=centos8
VM_DISK_SIZE=40
VM_VCPU_COUNT=1
VM_MEMORY=2048
VM_DISK_FILE=${LIBVIRT_HOME}/images/${VM_NAME}.qcow2
VM_CFG_FILES="${WORKING_DIR}/cloudinit/user-data ${WORKING_DIR}/cloudinit/meta-data"
VM_CONFIG_ISO_FILE=${LIBVIRT_HOME}/images/${VM_NAME}_cloudinit-cfg.iso

# create cloud init cfg iso
genisoimage -o ${VM_CONFIG_ISO_FILE} -V cidata -r -J ${VM_CFG_FILES}

# create qcow2 image
qemu-img create -f qcow2 -o preallocation=metadata $VM_DISK_FILE ${VM_DISK_SIZE}G

# create vm using virt-install
virt-install \
	--os-type generic \
	--virt-type kvm \
	--name $VM_NAME \
	--memory $VM_MEMORY \
	--vcpus $VM_VCPU_COUNT \
	--boot cdrom,hd,network,menu=on \
	--network bridge=br0,model=virtio \
	--noautoconsole --graphics vnc,listen=0.0.0.0,port=5901,password=password \
	--controller type=scsi,model=virtio-scsi \
	--import \
	--disk $VM_DISK_FILE,bus=scsi,format=qcow2 \
	--cdrom $LIBVIRT_HOME/images/CentOS-8.2.2004-x86_64-dvd1.iso
