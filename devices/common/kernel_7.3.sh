#!/bin/bash

shopt -s extglob

git clone --depth 1 --single-branch --branch kernel-7.3 https://github.com/graysky2/openwrt new || exit 1
rm -rf include target/linux target/Config.in scripts/target-metadata.pl package/boot package/devel package/firmware package/kernel package/libs package/network tools toolchain || exit 1
cd new || exit 1

cp -rf --parents rules.mk include target/linux target/Config.in scripts/target-metadata.pl scripts/cache-run.sh scripts/build-time-log.sh package/boot package/devel package/firmware package/kernel package/libs package/network tools toolchain config ../ || exit 1


cd - || exit 1


cd feeds/packages
rm -rf net/xtables-addons net/jool kernel/v4l2loopback kernel/ovpn-dco libs/libpfring libs/libmariadb 
#lang/python

git_clone_path master https://github.com/openwrt/packages net/jool kernel/v4l2loopback libs/libpfring net/xtables-addons libs/libmariadb  kernel/ovpn-dco 
#lang/python

cd ../../

cd package
rm -rf devel/kselftests-bpf  kernel/mt76 kernel/ath10k-ct devel/perf

cd ../

#cd /package/network
#rm -rf  services/dnsmasq
#git_clone_path dnsmasq https://github.com/graysky2/openwrt package/network/services/dnsmasq

#cd ../

rm -rf package/kernel/ath10k-ct package/kernel/mt76 
