#=============================================================================
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#=============================================================================

create_instance()
{
    local instance_dir=$1
    if [ ! -d $instance_dir ]
    then
        mkdir $instance_dir
    fi
}

enable_core_events()
{
    local instance=/sys/kernel/tracing

    echo > $instance/trace
    echo > $instance/set_event

    enable_sched_events
    enable_timer_events
    enable_power_events
    enable_misc_events

    echo 1 > $instance/tracing_on
}

enable_sched_events()
{
    echo 1 > $instance/events/sched/sched_migrate_task/enable
    echo 1 > $instance/events/sched/sched_pi_setprio/enable
    echo 1 > $instance/events/sched/sched_switch/enable
    echo 1 > $instance/events/sched/sched_wakeup/enable
    echo 1 > $instance/events/sched/sched_wakeup_new/enable
    echo 1 > $instance/events/schedwalt/halt_cpus/enable
    echo 1 > $instance/events/schedwalt/halt_cpus_start/enable
}

enable_timer_events()
{
    echo 1 > $instance/events/timer/timer_expire_entry/enable
    echo 1 > $instance/events/timer/timer_expire_exit/enable
    echo 1 > $instance/events/timer/hrtimer_cancel/enable
    echo 1 > $instance/events/timer/hrtimer_expire_entry/enable
    echo 1 > $instance/events/timer/hrtimer_expire_exit/enable
    echo 1 > $instance/events/timer/hrtimer_init/enable
    echo 1 > $instance/events/timer/hrtimer_start/enable
}

enable_power_events()
{
    echo 1 > $instance/events/power/clock_set_rate/enable
    echo 1 > $instance/events/power/clock_enable/enable
    echo 1 > $instance/events/power/clock_disable/enable
    echo 1 > $instance/events/power/cpu_frequency/enable
}

enable_misc_events()
{
    echo 1 > $instance/events/irq/enable
    echo 1 > $instance/events/workqueue/enable

    # hot-plug
    echo 1 > $instance/events/cpuhp/enable

    # fastrpc
    #echo 1 > $instance/events/fastrpc/enable

    #EMMC
    #echo 1 > $instance/events/mmc/enable

}

enable_rproc_events()
{
    local instance=/sys/kernel/tracing/instances/rproc_qcom

    create_instance $instance
    echo > $instance/trace
    echo > $instance/set_event

    # enable rproc events as soon as available
    /vendor/bin/init.qti.write.sh $instance/events/rproc_qcom/enable 1

    echo 1 > $instance/tracing_on
}

# Suspend events are also noisy when going into suspend/resume
enable_suspend_events()
{
    local instance=/sys/kernel/tracing/instances/suspend

    create_instance $instance
    echo > $instance/trace
    echo > $instance/set_event

    echo 1 > $instance/events/power/suspend_resume/enable
    echo 1 > $instance/events/power/device_pm_callback_start/enable
    echo 1 > $instance/events/power/device_pm_callback_end/enable

    echo 1 > $instance/tracing_on
}

enable_clock_reg_events()
{
    local instance=/sys/kernel/tracing/instances/clock_reg

    create_instance $instance
    echo > $instance/trace
    echo > $instance/set_event

    # clock
    echo 1 > $instance/events/clk/enable
    echo 1 > $instance/events/clk_qcom/enable

    # interconnect
    echo 1 > $instance/events/interconnect/enable

    # regulator
    echo 1 > $instance/events/regulator/enable

    # rpmh
    echo 1 > $instance/events/rpmh/enable

    echo 1 > $instance/tracing_on
}

enable_memory_events()
{
    local instance=/sys/kernel/tracing/instances/memory

    create_instance $instance
    echo > $instance/trace
    echo > $instance/set_event

    #memory pressure events/oom
    #echo 1 > $instance/events/psi/psi_event/enable
    #echo 1 > $instance/events/psi/psi_window_vmstat/enable

    echo 1 > $instance/events/arm_smmu/enable

    echo 1 > $instance/tracing_on
}

# binder tracing can be noisy
enable_binder_events()
{
    local instance=/sys/kernel/tracing/instances/binder

    create_instance $instance
    echo > $instance/trace
    echo > $instance/set_event

    echo 1 > $instance/events/binder/enable

    echo 1 > $instance/tracing_on
}

enable_rwmmio_events()
{
    if [ ! -d /sys/kernel/tracing/events/rwmmio ]
    then
        return
    fi

    local instance=/sys/kernel/tracing/instances/rwmmio

    create_instance $instance
    echo > $instance/trace
    echo > $instance/set_event

    echo 1 > $instance/events/rwmmio/rwmmio_read/enable
    echo 1 > $instance/events/rwmmio/rwmmio_write/enable

    echo 1 > $instance/tracing_on
}

find_build_type()
{
    linux_banner=`cat /proc/version`
    if [[ "$linux_banner" == *"-debug"* ]]
    then
        debug_build=true
    fi
}

ftrace_disable=`getprop persist.debug.ftrace_events_disable`
debug_build=false
enable_tracing_events()
{
    # bail out if its perf config
    find_build_type
    if [ "$debug_build" = false ]; then
        return
    fi

    # bail out if ftrace events aren't present
    if [ ! -d /sys/kernel/tracing/events ]; then
        return
    fi

    # bail out if ftrace_events_disable is set
    if [ "$ftrace_disable" = "Yes" ]; then
        return
    fi

    enable_core_events
    #enable_rproc_events
    enable_suspend_events
    enable_binder_events
    enable_clock_reg_events
    enable_memory_events
    enable_rwmmio_events
}

enable_tracing_events
