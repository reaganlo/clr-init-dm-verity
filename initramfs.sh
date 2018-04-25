#!/bin/bash

echo $1
rm -rf initramfs $1
mkdir -p initramfs/{bin,dev,etc,lib64,usr/lib64,mnt/root,proc,root,sys,run}

mixversion=$(cat mixversion)
echo $mixversion

if [ $mixversion != "" ]
then
   path="update/image/$mixversion/full"
else
   path=""
fi
echo $path

cp -a $path/usr/lib64/{libc.so.?,libgcc_s.so.?,libc-?.??.so,libm.so.?,libm-?.??.so,libpthread.so.?,librt.so.?,libacl.so.?,libattr.so.?,libcap.so.?,ld-linux-x86-64.so.?,libmount.so.?,libblkid.so.?,libuuid.so.?,libcryptsetup.so.?,libpopt.so.?,libdevmapper.so.?.??,libgcrypt.so.??,libudev.so.?,libgpg-error.so.?,ld-?.??.so,libacl.so.?.?.?,libattr.so.?.?.?,libblkid.so.?.?.?,libcap.so.?.??,libcryptsetup.so.?.?.?,libgcrypt.so.??.?.?,libgpg-error.so.?.??.?,libmount.so.?.?.?,libpopt.so.?.?.?,libpthread-?.??.so,librt-?.??.so,libudev.so.?.?.?,libuuid.so.?.?.?,libtinfo.so.?,libtinfo.so.?.?} initramfs/usr/lib64/

cp -a $path/usr/lib64/{libc.so.?,libgcc_s.so.?,libc-?.??.so,libm.so.?,libm-?.??.so,libpthread.so.?,librt.so.?,libacl.so.?,libattr.so.?,libcap.so.?,ld-linux-x86-64.so.?,libmount.so.?,libblkid.so.?,libuuid.so.?,libcryptsetup.so.?,libpopt.so.?,libdevmapper.so.?.??,libgcrypt.so.??,libudev.so.?,libgpg-error.so.?,ld-?.??.so,libacl.so.?.?.?,libattr.so.?.?.?,libblkid.so.?.?.?,libcap.so.?.??,libcryptsetup.so.?.?.?,libgcrypt.so.??.?.?,libgpg-error.so.?.??.?,libmount.so.?.?.?,libpopt.so.?.?.?,libpthread-?.??.so,librt-?.??.so,libudev.so.?.?.?,libuuid.so.?.?.?,libtinfo.so.?,libtinfo.so.?.?} initramfs/lib64/

cp -a $path/bin/{bash,sh,coreutils,mount,umount,veritysetup,switch_root,cat,echo} initramfs/bin/

cp init initramfs/

cd initramfs

chmod +x init

echo $1
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../$1
