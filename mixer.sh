#!/bin/bash

#umount mnt
#wait

#losetup -d /dev/loop0
#wait

#rm -rf release.img
#wait

mixer init --clear-version 22010 --mix-version 10
wait

cp dm-verity local-bundles/
wait

mixer bundle add dm-verity
wait

mixer add-rpms
wait

mixer build chroots
wait

mixer build update
wait

mixer build image --format=1
wait
