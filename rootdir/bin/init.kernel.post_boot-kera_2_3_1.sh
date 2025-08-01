#=============================================================================
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# All rights reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#=============================================================================

ddr_type=`od -An -tx /proc/device-tree/memory/ddr_device_type`
ddr_type4="07"
ddr_type5="08"
# Configure RT parameters:
# Long running RT task detection is confined to consolidated builds.
# Set RT throttle runtime to 50ms more than long running RT
# task detection time.
# Set RT throttle period to 100ms more than RT throttle runtime.
long_running_rt_task_ms=1200
sched_rt_runtime_ms=`expr $long_running_rt_task_ms + 50`
sched_rt_runtime_us=`expr $sched_rt_runtime_ms \* 1000`
sched_rt_period_ms=`expr $sched_rt_runtime_ms + 100`
sched_rt_period_us=`expr $sched_rt_period_ms \* 1000`
echo $sched_rt_period_us > /proc/sys/kernel/sched_rt_period_us
echo $sched_rt_runtime_us > /proc/sys/kernel/sched_rt_runtime_us

if [ -d /proc/sys/walt ]; then
	# configure maximum frequency when CPUs are partially halted
	echo 1190400 > /proc/sys/walt/sched_max_freq_partial_halt

	# Disable core control for silvers
	echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable

	# Disable core control for golds
	echo 0 > /sys/devices/system/cpu/cpu2/core_ctl/enable

	# Disable core control for prime
	echo 0 > /sys/devices/system/cpu/cpu5/core_ctl/enable

	# Setting b.L scheduler parameters
	echo 71 95 > /proc/sys/walt/sched_upmigrate
	echo 65 85 > /proc/sys/walt/sched_downmigrate
	echo 85 > /proc/sys/walt/sched_group_downmigrate
	echo 100 > /proc/sys/walt/sched_group_upmigrate
	echo 1 > /proc/sys/walt/sched_walt_rotate_big_tasks
	echo 51 > /proc/sys/walt/sched_min_task_util_for_boost
	echo 35 > /proc/sys/walt/sched_min_task_util_for_colocation
	echo 0 > /proc/sys/walt/sched_coloc_busy_hysteresis_enable_cpus
	echo 8500000 8500000 5000000 5000000 2000000 > /proc/sys/walt/sched_util_busy_hyst_cpu_ns
	echo 255 > /proc/sys/walt/sched_util_busy_hysteresis_enable_cpus
	echo 1 1 15 15 15 > /proc/sys/walt/sched_util_busy_hyst_cpu_util
	echo 40 > /proc/sys/walt/sched_cluster_util_thres_pct
	echo 30 > /proc/sys/walt/sched_idle_enough

	# Enable Gold CPUs for pipeline
	echo 120 > /proc/sys/walt/sched_pipeline_cpus

	# set the threshold for low latency task boost feature which prioritize
	# binder activity tasks
	echo 325 > /proc/sys/walt/walt_low_latency_task_threshold

	# configure maximum frequency of silver cluster when load is not detected and ensure that
	# other clusters' fmax remains uncapped by setting the frequency to S32_MAX
	echo 2147483647 2147483647 2147483647 > /proc/sys/walt/sched_fmax_cap

	# Turn off scheduler boost at the end
	echo 0 > /proc/sys/walt/sched_boost

	# configure input boost settings
	echo 1113600 0 0 0 0 > /proc/sys/walt/input_boost/input_boost_freq
	echo 120 > /proc/sys/walt/input_boost/input_boost_ms

	echo "walt" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
	echo "walt" > /sys/devices/system/cpu/cpufreq/policy2/scaling_governor
	echo "walt" > /sys/devices/system/cpu/cpufreq/policy5/scaling_governor

	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/up_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy2/walt/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy2/walt/up_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy5/walt/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy5/walt/up_rate_limit_us

	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/pl
	echo 0 > /sys/devices/system/cpu/cpufreq/policy2/walt/pl
	echo 0 > /sys/devices/system/cpu/cpufreq/policy5/walt/pl
	echo 1 > /proc/sys/walt/sched_conservative_pl

	echo 595200 > /sys/devices/system/cpu/cpufreq/policy0/walt/rtg_boost_freq
	echo 0 > /sys/devices/system/cpu/cpufreq/policy2/walt/rtg_boost_freq
	echo 0 > /sys/devices/system/cpu/cpufreq/policy5/walt/rtg_boost_freq

	echo 1113600 > /sys/devices/system/cpu/cpufreq/policy0/walt/hispeed_freq
	echo 1190400 > /sys/devices/system/cpu/cpufreq/policy2/walt/hispeed_freq
	echo 1459200 > /sys/devices/system/cpu/cpufreq/policy5/walt/hispeed_freq

	echo 85 > /sys/devices/system/cpu/cpufreq/policy2/walt/hispeed_load
	echo 85 > /sys/devices/system/cpu/cpufreq/policy5/walt/hispeed_load

else
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy2/scaling_governor
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy5/scaling_governor
	echo 1 > /proc/sys/kernel/sched_pelt_multiplier
fi

echo 595200 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
echo 633600 > /sys/devices/system/cpu/cpufreq/policy2/scaling_min_freq
echo 633600 > /sys/devices/system/cpu/cpufreq/policy5/scaling_min_freq
echo "0:595200 2:633600 4:633600" > /data/vendor/perfd/default_scaling_min_freq

# Reset the RT boost, which is 1024 (max) by default.
echo 0 > /proc/sys/kernel/sched_util_clamp_min_rt_default

# cpuset parameters
echo 0-1 > /dev/cpuset/background/cpus
echo 0-1 > /dev/cpuset/system-background/cpus

# configure bus-dcvs
bus_dcvs="/sys/devices/system/cpu/bus_dcvs"

for device in $bus_dcvs/*
do
	cat $device/hw_min_freq > $device/boost_freq
done

for llccbw in $bus_dcvs/LLCC/*bwmon-llcc
do
	echo "5340 8132 9155 12298 14236 16265 18478" > $llccbw/mbps_zones
	echo 4 > $llccbw/sample_ms
	echo 80 > $llccbw/io_percent
	echo 20 > $llccbw/hist_memory
	echo 1 > $llccbw/idle_length
	echo 30 > $llccbw/down_thres
	echo 0 > $llccbw/guard_band_mbps
	echo 250 > $llccbw/up_scale
	echo 1600 > $llccbw/idle_mbps
	echo 40 > $llccbw/window_ms
done

for ddrbw in $bus_dcvs/DDR/*bwmon-ddr
do
	if [ ${ddr_type:4:2} == $ddr_type4 ]; then
		echo "1144 1720 2086 2929 3879 5161 5931 6515 8136" > $ddrbw/mbps_zones
	elif [ ${ddr_type:4:2} == $ddr_type5 ]; then
		echo "1720 2086 2929 3879 5931 6515 7980 12191" > $ddrbw/mbps_zones
	fi
	echo 4 > $ddrbw/sample_ms
	echo 68 > $ddrbw/io_percent
	echo 20 > $ddrbw/hist_memory
	echo 80 > $ddrbw/down_thres
	echo 0 > $ddrbw/guard_band_mbps
	echo 250 > $ddrbw/up_scale
	echo 1600 > $ddrbw/idle_mbps
	echo 48 > $ddrbw/window_ms
done

for l3gold in $bus_dcvs/L3/*gold
do
	echo 4000 > $l3gold/ipm_ceil
	echo 60 > $l3gold/wb_pct_thres
done

for qosgold in $bus_dcvs/DDRQOS/*gold
do
	echo 4000 > $qosgold/ipm_ceil
done

#set s2idle as default suspend mode
echo s2idle > /sys/power/mem_sleep

# Enable LPM
echo N > /sys/devices/system/cpu/qcom_lpm/parameters/sleep_disabled

# Let kernel know our image version/variant/crm_version
if [ -f /sys/devices/soc0/select_image ]; then
	image_version="10:"
	image_version+=`getprop ro.build.id`
	image_version+=":"
	image_version+=`getprop ro.build.version.incremental`
	image_variant=`getprop ro.product.name`
	image_variant+="-"
	image_variant+=`getprop ro.build.type`
	oem_version=`getprop ro.build.version.codename`
	echo 10 > /sys/devices/soc0/select_image
	echo $image_version > /sys/devices/soc0/image_version
	echo $image_variant > /sys/devices/soc0/image_variant
	echo $oem_version > /sys/devices/soc0/image_crm_version
fi

rev=`cat /sys/devices/soc0/revision`

echo 4 > /proc/sys/kernel/printk

# Change console log level as per console config property
console_config=`getprop persist.vendor.console.silent.config`
case "$console_config" in
	"1")
		echo "Enable console config to $console_config"
		echo 0 > /proc/sys/kernel/printk
	;;
	*)
		echo "Enable console config to $console_config"
	;;
esac
