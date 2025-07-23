#! /vendor/bin/sh
md5img=$(md5sum "/vendor/etc/tt_img/Signal.pkg"  | awk '{print $1}')
$(setprop persist.vendor.radio.firmwaremd5 $md5img)
ctx=$(</vendor/etc/tt_img/flash_version)
$(setprop persist.vendor.radio.flash_version $ctx)
$(setprop persist.vendor.radio.flash_completed 0)
$(setprop persist.vendor.radio.boot_ok 0)

isflash=`getprop persist.vendor.radio.isflash`
if [ "$isflash" == "1" ];then
   $(setprop persist.vendor.radio.isflash 0)
fi
log -p i -t "tt_flash.sh" "md5img = $md5img"
log -p i -t "tt_flash.sh" "new_version = $ctx"

factory=`getprop persist.odm.radio.factorybuild`
region=`getprop ro.miui.build.region`
device=`getprop ro.product.device`
isroot=`getprop ro.debuggable`
isuser=`getprop ro.build.type`
hwc=`getprop ro.boot.hwc`
hwlevel=`getprop ro.boot.hwlevel`
$(setprop persist.vendor.radio.hwc $hwc)
$(setprop persist.vendor.radio.hwlevel $hwlevel)
log -p i -t "tt_flash.sh" "factory = $factory"
log -p i -t "tt_flash.sh" "region = $region"
log -p i -t "tt_flash.sh" "isroot = $isroot"
log -p i -t "tt_flash.sh" "isuser = $isuser"
log -p i -t "tt_flash.sh" "hwc = $hwc"
log -p i -t "tt_flash.sh" "hwlevel = $hwlevel"

#for factory
if [ "$factory" == "1" -a "$device" == "xuanyuan" ];then
   if [ -e "/mnt/vendor/persist/tt_md5sum/md5sum" ];then
       log -p i -t "tt_flash.sh" "persist md5sum exist,remove it!"
       `rm /mnt/vendor/persist/tt_md5sum/md5sum`
   fi
   #add fac_flash_log(storage factory flash log)
   if [ ! -e "/data/vendor/tt_md5sum/fac_flash_log" ];then
       log -p i -t "tt_flash.sh" "fac_flash_log no exist,create it!"
       `touch /data/vendor/tt_md5sum/fac_flash_log`
   fi
fi

#for factory and hyperos
if [ ! -e "/mnt/vendor/persist/tt_md5sum/s_version" ];then
    log -p i -t "tt_flash.sh" "persist s_version do not exist,create it!"
    `touch /mnt/vendor/persist/tt_md5sum/s_version`
    `touch /mnt/vendor/persist/tt_md5sum/flashstate`
fi

#for hyperos
if [ "$factory" != "1" -a "$region" == "cn" -a "$device" == "xuanyuan" ];then

   #remove fac_flash_log(storage factory flash log)
   if [ -e "/data/vendor/tt_md5sum/fac_flash_log" ];then
        log -p i -t "tt_flash.sh" "fac_flash_log exist,remove it!"
        `rm /data/vendor/tt_md5sum/fac_flash_log`
   fi

   if [ ! -e "/mnt/vendor/persist/tt_md5sum/md5sum" ];then
       log -p i -t "tt_flash.sh" "persist md5sum do not exist,create it!"
       `touch /mnt/vendor/persist/tt_md5sum/md5sum`
       #for userroot version debug
       if [ "$isroot" != "1" -a "$isuser" == "user" ];then
          log -p i -t "tt_flash.sh" "echo persist md5sum, success!"
          `echo $md5img > /mnt/vendor/persist/tt_md5sum/md5sum`
       fi
   fi

   if [ ! -e "/data/vendor/tt_md5sum/md5sum" ];then
       log -p i -t "tt_flash.sh" "data md5sum do not exist,create it!"
       `touch /data/vendor/tt_md5sum/md5sum`
       `touch /data/vendor/tt_md5sum/flash_log`
       a=$(</mnt/vendor/persist/tt_md5sum/flashstate)
       b=$(</mnt/vendor/persist/tt_md5sum/s_version)
       $(setprop persist.vendor.radio.flashstate $a)
       $(setprop persist.vendor.radio.s_version $b)

   fi
fi

aa=$(</mnt/vendor/persist/tt_md5sum/flashstate)
bb=$(</mnt/vendor/persist/tt_md5sum/s_version)
cc=$(</mnt/vendor/persist/tt_md5sum/md5sum)
if [ "$cc" == "" ];then
   $(setprop persist.vendor.radio.historymd5 0)
fi

if [ "$cc" != "" ];then
   $(setprop persist.vendor.radio.historymd5 $cc)
fi
log -p i -t "tt_flash.sh" "flashstate = $aa"
log -p i -t "tt_flash.sh" "curr_version = $bb"
log -p i -t "tt_flash.sh" "historymd5 = $cc"