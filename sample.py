#!/usr/bin/env python3
import subprocess
import time
import sys
import os
import urllib.request as request
import json
import fnmatch
import re

image_name = "release.img"
boot_partition = 1
data_partition = 3
hash_partition = 4
verity_name = "root"
efi_dir = "EFI/org.clearlinux/"
bootloader_config_dir = "loader/entries/"
initramfs_fname = "initramfs.cpio.gz"

mount_dir = "mnt"
target_prefix = "/dev/vda"

print("\nGenerating content using mixer..")
subprocess.check_output("sh {0}".format("mixer.sh").split(" "))

print("\nGenerating dm-verity root_hash..")
subprocess.check_output("sh {0} {1} {2} {3}".format("dm-verity.sh", image_name, data_partition, hash_partition).split(" "))
try:
	outfile = open("root_hash.txt", 'r')
	root_hash = outfile.read().rstrip()
	outfile.close()
except IOError:
	print("I/O error")

print("\nCreating initramfs..")
subprocess.check_output("sh {0} {1}".format("initramfs.sh", initramfs_fname).split(" "))

cmd = "losetup -f -P --show {0}".format(image_name)
print("\nExecuting: " + cmd)
try:
    dev = subprocess.check_output(cmd.split(" ")).decode("utf-8").splitlines()
except Exception:
    raise Exception("{0}: {1}".format(cmd, sys.exc_info()))
print(dev[len(dev) - 1])

boot_dev = "{0}{1}{2}".format(dev[0], "p", str(boot_partition))
data_dev = "{0}{1}{2}".format(dev[0], "p", str(data_partition))
hash_dev = "{0}{1}{2}".format(dev[0], "p", str(hash_partition))

subprocess.check_output("rm -rf {0}".format(mount_dir).split(" "))
subprocess.check_output("mkdir {0}".format(mount_dir).split(" "))
subprocess.check_output("mount {0} {1}".format(boot_dev, mount_dir).split(" "))

print("\nCopying initramfs to boot partition..")
mount_path = "{0}/{1}".format(mount_dir, efi_dir)
subprocess.check_output("cp {0} {1}".format(initramfs_fname, mount_path).split(" "))

print("\nUpdating bootloader config..")
verity_content="quiet data_block_size=1024 hash_block_size=1024 verity_name={0} data_dev={1}{2} hash_dev={1}{3} root_hash={4}".format(verity_name, target_prefix, str(data_partition), str(hash_partition), root_hash)

mount_path = "{0}/{1}".format(mount_dir, bootloader_config_dir)
for fname in os.listdir(mount_path):
    if (fnmatch.fnmatch(fname, 'Clear-*')):
        path = "{0}{1}".format(mount_path, fname)
        try:
            outfile = open(path, 'r')
            content = outfile.read()
            print("\nCurrent bootloader config.." + content)
            outfile.close()
        except IOError:
            print("I/O error")

        content = re.sub(r"root=.* quiet", verity_content, content)
        content = re.sub(r"init=.* initcall_debug", "", content)
        content = re.sub(r"rw", "\ninitrd " + efi_dir + initramfs_fname, content)
        print("\nNew bootloader config.." + content)

        try:
            outfile = open(path, 'w')
            outfile.write(content)
            outfile.close()
        except IOError:
            print("I/O error")

subprocess.check_output("umount mnt".split(" "))
subprocess.check_output("rm -rf {0}".format(mount_dir).split(" "))

cmd = "losetup -d {0}".format(dev[0])
print("\nExecuting: " + cmd)
try:
    dev = subprocess.check_output(cmd.split(" ")).decode("utf-8").splitlines()
except Exception:
    raise Exception("{0}: {1}".format(cmd, sys.exc_info()))

print("\nDone!")
