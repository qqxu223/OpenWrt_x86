#!/bin/bash

shopt -s extglob

rm -rf target/linux package/boot package/devel package/firmware package/kernel package/libs package/network tools toolchain
mkdir new; cp -rf .git new/.git
cd new
git reset --hard origin/main

cp -rf --parents target/linux package/boot package/devel package/firmware package/kernel package/libs package/network tools toolchain config ../

cd -


cd feeds/packages
rm -rf net/xtables-addons net/jool kernel/v4l2loopback libs/libpfring libs/libmariadb

git_clone_path master https://github.com/openwrt/packages net/jool kernel/v4l2loopback libs/libpfring net/xtables-addons libs/libmariadb

cd ../../

#cd feeds/miaogongzi
#rm -rf fibocom_QMI_WWAN rkp-ipid
#cd ../../

cd package
rm -rf devel/kselftests-bpf  kernel/mt76 kernel/ath10k-ct 

#libs/libnl/Makefile
#wget -N https://patch-diff.githubusercontent.com/raw/openwrt/mt76/pull/1026.patch -P kernel/mt76/patches/
#mv kernel/mt76/patches/1026.patch kernel/mt76/patches/002-fix-mt76-timer-compat.patch

#wget -N https://raw.githubusercontent.com/mgz0227/openwrt/refs/heads/6.18-libnl/package/libs/libnl/Makefile -P libs/libnl/ 

cd ../

rm -rf package/kernel/ath10k-ct package/kernel/mt76