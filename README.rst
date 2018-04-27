Implementing dm-verity in Clear Linux
#####################################

The repo contains artifacts and details for implementing dm-verity 
in Clear Linux.

Overview
========
- Generate a Clear Linux image with dm-verity enabled.
- Generate the root_hash for the data partition to be verified.
- Generate an initramfs to activate and mount the data partition.
- Update the bootloader config file with the partition, root_hash and
  initramfs info.
  
Downloading artifacts
=====================
- This documentation assumes that the contents of this repo are downloaded
  to the Mixer workspace. They can be downloaded elsewhere too, but would
  require some tweaking to point to the correct file paths.

Details
=======

* `mixer.sh`_
   - This is a sample script that can be used to generate a Clear Linux image
     using Mixer. It uses the ister template file "release-image-config.json"
     and the custom bundle definition file "dm-verity".
   - Prior to running the script, enable dm-verity in the linux kernel and
     build the package i.e. set “CONFIG_DM_VERITY=y” in the kernel config file.
     Then copy the generated rpms (excluding source rpms) into the "local-bundles"
     directory in the Mixer workspace.
   - The default target image name is "release.img". E.g.

.. code-block:: console

   $ sudo -E sh mixer.sh

* `dm-verity.sh`_
   - This script takes the target image name, data partition number and hash partition number
     as inputs and generates the root_hash of the data partition. E.g. 

.. code-block:: console

   $ sudo sh dm-verity.sh release.img 3 4

* `initramfs.sh`_
   - This script takes the initramfs zip file name as input and generates the corresponding 
     zipped initramfs file. It copies the necessary libraries and binaries for the initramfs 
     from the Mixer content or host content. The "init" file contained in this repo is the 
     main logic file in the initramfs. E.g. 

.. code-block:: console

   $ sh initramfs.sh initramfs.cpio.gz

   
* Copy this zipped initramfs file to the corresponding EFI boot partition of the target image.
  E.g. assuming boot partition of target image is mounted on "mnt" directory

.. code-block:: console

   $ sudo cp initramfs.cpio.gz mnt/EFI/org.clearlinux/

* Update the bootloader config file with the partition, root_hash and
  initramfs info. The following is an example for QEMU. Ensure that the "data_block_size",
  "hash_block_size", "verity_name", "data_dev", "hash_dev", "root_hash"
  and "initrd" options are updated accordingly.
  Ensure that the "root", "init", "initcall_debug" and "rw" options are not present.

.. code-block:: console

   title Clear Linux OS for Intel Architecture
   linux /EFI/org.clearlinux/kernel-org.clearlinux.native.4.15.15-538
   options quiet data_block_size=1024 hash_block_size=1024 verity_name=root data_dev=/dev/vda3 hash_dev=/dev/vda4 root_hash=9974e6ee8750462d5b66be2d8fb6a21edebd4ee56acfd51183d1d05b5d50755c modprobe.blacklist=ccipciedrv,aalbus,aalrms,aalrmc console=tty0 console=ttyS0,115200n8  tsc=reliable no_timer_check noreplace-smp kvm-intel.nested=1 rootfstype=ext4,btrfs,xfs intel_iommu=igfx_off cryptomgr.notests rcupdate.rcu_expedited=1 i915.fastboot=1 rcu_nocbs=0-64
   initrd EFI/org.clearlinux/initramfs.cpio.gz
   
* Test it on QEMU. Refer to "qemu_results.png" for basic test result. E.g.

.. code-block:: console

   $ sudo ./start_qemu.sh release.img

* `sample.py`_
   - This python script does all the above mentioned steps right from generating the content
     to updating the bootloader config file. E.g.

.. code-block:: console

   $ sudo python sample.py

.. _mixer.sh: https://github.com/reaganlo/clr-dm-verity/blob/master/mixer.sh
.. _dm-verity.sh: https://github.com/reaganlo/clr-dm-verity/blob/master/dm-verity.sh
.. _initramfs.sh: https://github.com/reaganlo/clr-dm-verity/blob/master/initramfs.sh
.. _sample.py: https://github.com/reaganlo/clr-dm-verity/blob/master/sample.py
