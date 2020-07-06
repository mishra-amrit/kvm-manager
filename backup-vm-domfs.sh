#!/bin/bash
VM_NAME="centos8"

virsh domfsfreeze $VM_NAME
qemu-img create -f qcow2 -b $VM_NAME.qcow2 snapshot.qcow2
virsh domfsthaw $VM_NAME

