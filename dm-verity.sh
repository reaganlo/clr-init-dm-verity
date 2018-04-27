#!/bin/bash

disk_image=$1
data_partition=$2
hash_partition=$3
initramfs_fname="initramfs.cpio.gz"

dev=$(losetup -f -P --show $disk_image)

data_dev=$dev"p"$data_partition
hash_dev=$dev"p"$hash_partition

echo "Executing veritysetup format.."
veritysetup --verbose --data-block-size=1024 --hash-block-size=1024 format $data_dev $hash_dev | tee result
root_hash=$(cat result | grep "^Root hash:" | sed -e 's/.*\s\(\S*\)$/\1/')

echo "Copying root_hash to root_hash.txt"
rm root_hash.txt
echo $root_hash > root_hash.txt

losetup -d $dev
