# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# All rights reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.

rev=`cat /sys/devices/soc0/revision`

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

	# Disable Core control for silver
	echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable
	# Disable Core control for gold
	echo 0 > /sys/devices/system/cpu/cpu2/core_ctl/enable
	# Disable Core control for titanium
	echo 0 > /sys/devices/system/cpu/cpu5/core_ctl/enable

	# Configure Single Boost Thread
	echo 0 > /proc/sys/walt/sched_sbt_delay_windows
	echo 0x60 > /proc/sys/walt/sched_sbt_pause_cpus

	# Setting b.L scheduler parameters
	echo 95 95 > /proc/sys/walt/sched_upmigrate
	echo 85 85 > /proc/sys/walt/sched_downmigrate
	echo 80 > /proc/sys/walt/sched_group_downmigrate
	echo 90 > /proc/sys/walt/sched_group_upmigrate
	echo 1 > /proc/sys/walt/sched_walt_rotate_big_tasks
	echo 400000000 > /proc/sys/walt/sched_coloc_downmigrate_ns
	echo 16000000 16000000 16000000 16000000 16000000 16000000 16000000 > /proc/sys/walt/sched_coloc_busy_hyst_cpu_ns
	echo 120 > /proc/sys/walt/sched_coloc_busy_hysteresis_enable_cpus
	echo 10 10 10 10 10 10 10 > /proc/sys/walt/sched_coloc_busy_hyst_cpu_busy_pct
	echo 8500000 8500000 8500000 8500000 8500000 8500000 8500000 > /proc/sys/walt/sched_util_busy_hyst_cpu_ns
	echo 127 > /proc/sys/walt/sched_util_busy_hysteresis_enable_cpus
	echo 1 1 1 1 1 1 1 > /proc/sys/walt/sched_util_busy_hyst_cpu_util
	echo 40 > /proc/sys/walt/sched_cluster_util_thres_pct
	echo 30 > /proc/sys/walt/sched_idle_enough
	echo 10 > /proc/sys/walt/sched_ed_boost

	#Set early upmigrate tunables
	freq_to_migrate=1248000
	silver_fmax=`cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq`
	silver_early_upmigrate=`expr 1024 \* $silver_fmax / $freq_to_migrate`
	silver_early_downmigrate=`expr \( 1024 \* $silver_fmax \) / \( \( \( 10 \* $freq_to_migrate \) - $silver_fmax \) \/ 10 \)`
	sched_upmigrate=`cat /proc/sys/walt/sched_upmigrate`
	sched_downmigrate=`cat /proc/sys/walt/sched_downmigrate`
	sched_upmigrate=${sched_upmigrate:0:2}
	sched_downmigrate=${sched_downmigrate:0:2}
	gold_early_upmigrate=`expr \( 1024 \* 100 \) \/ $sched_upmigrate`
	gold_early_downmigrate=`expr \( 1024 \* 100 \) \/ $sched_downmigrate`
	echo $silver_early_downmigrate $gold_early_downmigrate $gold_early_downmigrate > /proc/sys/walt/sched_early_downmigrate
	echo $silver_early_upmigrate $gold_early_upmigrate $gold_early_upmigrate > /proc/sys/walt/sched_early_upmigrate

	# Enable Gold CPUs for pipeline
	echo 28 > /proc/sys/walt/sched_pipeline_cpus

	# set the threshold for low latency task boost feature which prioritize
	# binder activity tasks
	echo 325 > /proc/sys/walt/walt_low_latency_task_threshold

	# configure maximum frequency of silver cluster when load is not detected and ensure that
	# other clusters' fmax remains uncapped by setting the frequency to S32_MAX

	echo 0 1804800 6 1804800 7 1804800 8 1804800> /proc/sys/walt/cluster0/smart_freq/legacy_freq_levels
	echo 0 2707200 6 2707200 7 2707200 8 2707200> /proc/sys/walt/cluster1/smart_freq/legacy_freq_levels
	echo 0 2707200 6 2707200 7 2707200 8 2707200> /proc/sys/walt/cluster2/smart_freq/legacy_freq_levels
	echo 0 2956800 6 2956800 7 2956800 8 2956800> /proc/sys/walt/cluster3/smart_freq/legacy_freq_levels

	# Turn off scheduler boost at the end
	echo 0 > /proc/sys/walt/sched_boost

	# configure input boost settings

	echo 1075200 0 0 0 0 0 0 0 > /proc/sys/walt/input_boost/input_boost_freq

	echo 100 > /proc/sys/walt/input_boost/input_boost_ms

	echo "walt" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
	echo "walt" > /sys/devices/system/cpu/cpufreq/policy2/scaling_governor
	echo "walt" > /sys/devices/system/cpu/cpufreq/policy5/scaling_governor

	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/up_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy2/walt/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy2/walt/up_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy5/walt/down_rate_limit_us
	echo 0 > /sys/devices/system/cpu/cpufreq/policy5/walt/up_rate_limit_us

	echo 1 > /sys/devices/system/cpu/cpufreq/policy0/walt/pl
	echo 1 > /sys/devices/system/cpu/cpufreq/policy2/walt/pl
	echo 1 > /sys/devices/system/cpu/cpufreq/policy5/walt/pl

	echo 614400 > /sys/devices/system/cpu/cpufreq/policy0/walt/rtg_boost_freq
	echo 787200 > /sys/devices/system/cpu/cpufreq/policy2/walt/rtg_boost_freq
	echo 787200 > /sys/devices/system/cpu/cpufreq/policy5/walt/rtg_boost_freq

	echo 1075200 > /sys/devices/system/cpu/cpufreq/policy0/walt/hispeed_freq
	echo 1190400 > /sys/devices/system/cpu/cpufreq/policy2/walt/hispeed_freq
	echo 1190400 > /sys/devices/system/cpu/cpufreq/policy5/walt/hispeed_freq

else
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy2/scaling_governor
	echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy5/scaling_governor
	echo 1 > /proc/sys/kernel/sched_pelt_multiplier
fi

echo 441600 > /sys/devices/system/cpu/cpufreq/policy0/walt/scaling_min_freq
echo 633600 > /sys/devices/system/cpu/cpufreq/policy2/walt/scaling_min_freq
echo 480000 > /sys/devices/system/cpu/cpufreq/policy5/walt/scaling_min_freq
echo "0:441600 2:633600 5:480000" > /data/vendor/perfd/default_scaling_min_freq

# Reset the RT boost, which is 1024 (max) by default.
echo 0 > /proc/sys/kernel/sched_util_clamp_min_rt_default

# cpuset parameters
echo 0-1 5-6 > /dev/cpuset/background/cpus
echo 0-1 5-6 > /dev/cpuset/system-background/cpus

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
	echo "2086 5161 5931 6515 7980 10437 12157 14060 16113 18161" > $ddrbw/mbps_zones
	echo 4 > $ddrbw/sample_ms
	echo 80 > $ddrbw/io_percent
	echo 20 > $ddrbw/hist_memory
	echo 1 > $ddrbw/idle_length
	echo 30 > $ddrbw/down_thres
	echo 0 > $ddrbw/guard_band_mbps
	echo 250 > $ddrbw/up_scale
	echo 1600 > $ddrbw/idle_mbps
	echo 40 > $ddrbw/window_ms
done

for latfloor in $bus_dcvs/*/*latfloor
do
	echo 25000 > $latfloor/ipm_ceil
done

for l3gold in $bus_dcvs/L3/*gold
do
	echo 4000 > $l3gold/ipm_ceil
done

for l3prime in $bus_dcvs/L3/*prime
do
	echo 20000 > $l3prime/ipm_ceil
done

for qosgold in $bus_dcvs/DDRQOS/*gold
do
	echo 50 > $qosgold/ipm_ceil
done

for qosprime in $bus_dcvs/DDRQOS/*prime
do
	echo 100 > $qosprime/ipm_ceil
done

for ddrprime in $bus_dcvs/DDR/*prime
do
	echo 25 > $ddrprime/freq_scale_pct
	echo 1500 > $ddrprime/freq_scale_floor_mhz
	echo 2726 > $ddrprime/freq_scale_ceil_mhz
done

echo s2idle > /sys/power/mem_sleep
echo N > /sys/devices/system/cpu/qcom_lpm/parameters/sleep_disabled

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

setprop vendor.post_boot.parsed 1

