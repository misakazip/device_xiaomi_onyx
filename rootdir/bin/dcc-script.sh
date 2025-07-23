#=============================================================================
# Copyright (c) 2020-2024 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#
# Copyright (c) 2014-2017, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

create_instance()
{
    local instance_dir=$1
    if [ ! -d $instance_dir ]
    then
        mkdir $instance_dir
    fi
}

enable_extra_ftrace_events()
{
    if [ "$debug_build" = false ]; then
        return
    fi

    local instance=/sys/kernel/tracing
	# fastrpc
    if [ -d $instance/events/fastrpc/ ]; then
      echo 1 > $instance/events/fastrpc/enable
    fi
    echo 1 > $instance/events/regulator/enable
    echo 1 > /sys/kernel/tracing/tracing_on

}

# function to disable SF tracing on perf config
sf_tracing_disablement()
{
    # disable SF tracing if its perf config
    if [ "$debug_build" = false ]
    then
        setprop debug.sf.enable_transaction_tracing 0
    fi
}

enable_buses_and_interconnect_tracefs_debug()
{
    tracefs=/sys/kernel/tracing

    # enable tracing for consolidate/debug builds, where debug_build is set true
    if [ "$debug_build" = true ]
    then
        setprop persist.vendor.tracing.enabled 1
    fi

    if [ -d $tracefs ] && [ "$(getprop persist.vendor.tracing.enabled)" -eq "1" ]; then
        create_instance $tracefs/instances/hsuart
        #UART
        echo 800 > $tracefs/instances/hsuart/buffer_size_kb
        echo 1 > $tracefs/instances/hsuart/events/serial/enable
        echo 1 > $tracefs/instances/hsuart/tracing_on

        #SPI
        create_instance $tracefs/instances/spi_qup
        echo 20 > $tracefs/instances/spi_qup/buffer_size_kb
        echo 1 > $tracefs/instances/spi_qup/events/qup_spi_trace/enable
        echo 1 > $tracefs/instances/spi_qup/tracing_on

        #Q2SPI
        create_instance $tracefs/instances/q2spi
        echo 800 > $tracefs/instances/q2spi/buffer_size_kb
        echo 1 > $tracefs/instances/q2spi/events/q2spi_trace/enable
        echo 1 > $tracefs/instances/q2spi/tracing_on

        #I2C
        create_instance $tracefs/instances/i2c_qup
        echo 20 > $tracefs/instances/i2c_qup/buffer_size_kb
        echo 1 > $tracefs/instances/i2c_qup/events/qup_i2c_trace/enable
        echo 1 > $tracefs/instances/i2c_qup/tracing_on

        #I3C
        create_instance $tracefs/instances/i3c_qup
        echo 20 > $tracefs/instances/i3c_qup/buffer_size_kb
        echo 1 > $tracefs/instances/i3c_qup/events/qup_i3c_trace/enable
        echo 1 > $tracefs/instances/i3c_qup/tracing_on

        #SLIMBUS
        create_instance $tracefs/instances/slimbus
        echo 1 > $tracefs/instances/slimbus/events/slimbus/slimbus_dbg/enable
        echo 1 > $tracefs/instances/slimbus/tracing_on
    fi
}

config_dcc_timer()
{
    echo 0x16801000 2 > $DCC_PATH/config
}

config_dcc_core()
{
    # NCC0_NCC_NCC_ARCH reg
    echo 0x18880258 10 > $DCC_PATH/config
    echo 0x18880288 6 > $DCC_PATH/config
    echo 0x188802a8 10 > $DCC_PATH/config
    echo 0x18880328 6 > $DCC_PATH/config
    echo 0x188803d8 10 > $DCC_PATH/config
    echo 0x18880408 2 > $DCC_PATH/config

    # NCC1_NCC_NCC_ARCH reg
    echo 0x19880258 10 > $DCC_PATH/config
    echo 0x19880288 6 > $DCC_PATH/config
    echo 0x198802a8 10 > $DCC_PATH/config
    echo 0x19880328 6 > $DCC_PATH/config
    echo 0x198803d8 10 > $DCC_PATH/config
    echo 0x19880408 2 > $DCC_PATH/config

    #NCC0_NCC_DVFS0
    echo 0x188b0000 4 > $DCC_PATH/config
    echo 0x188b0050 2 > $DCC_PATH/config
    echo 0x188b00e8 36 > $DCC_PATH/config
    echo 0x188b0788 2 > $DCC_PATH/config
    echo 0x188b0c18 2 > $DCC_PATH/config

    #NCC1_NCC_DVFS0
    echo 0x198b0000 4 > $DCC_PATH/config
    echo 0x198b0050 2 > $DCC_PATH/config
    echo 0x198b00e8 36 > $DCC_PATH/config
    echo 0x198b0788 2 > $DCC_PATH/config
    echo 0x198b0c18 2 > $DCC_PATH/config

    #APSS_CPUCP_BE
    echo 0x17988814 2 > $DCC_PATH/config
    echo 0x17998814 2 > $DCC_PATH/config
    #APSS_CPUCP_CL_LPM
    echo 0x179d2000 3 > $DCC_PATH/config
    echo 0x179d2020 3 > $DCC_PATH/config
    echo 0x179d2040 2 > $DCC_PATH/config
    echo 0x179d2060 2 > $DCC_PATH/config
    echo 0x179d2080 2 > $DCC_PATH/config
    echo 0x179d20a0 > $DCC_PATH/config
    echo 0x179d20b0 > $DCC_PATH/config
    echo 0x179d20c0 > $DCC_PATH/config
    echo 0x179d2200 2 > $DCC_PATH/config
    echo 0x179d2220 2 > $DCC_PATH/config
    echo 0x179d2280 2 > $DCC_PATH/config
    echo 0x179d22f0 > $DCC_PATH/config
    echo 0x179d2304 > $DCC_PATH/config
    echo 0x179d2310 > $DCC_PATH/config
    echo 0x179d2400 4 > $DCC_PATH/config
    echo 0x179d2420 > $DCC_PATH/config
    echo 0x179d2428 2 > $DCC_PATH/config
    echo 0x179d2440 2 > $DCC_PATH/config
    echo 0x179d2520 2 > $DCC_PATH/config
    echo 0x179d2600 2 > $DCC_PATH/config
    echo 0x179d2710 2 > $DCC_PATH/config
    echo 0x179d2720 2 > $DCC_PATH/config
    echo 0x179d2740 2 > $DCC_PATH/config
    echo 0x179d3080 2 > $DCC_PATH/config

    #APSS_CPUCP
    echo 0x17846018 2 > $DCC_PATH/config
    echo 0x17846060 > $DCC_PATH/config
    echo 0x17846100 2 > $DCC_PATH/config
    echo 0x17846110 > $DCC_PATH/config
    echo 0x17847030 2 > $DCC_PATH/config
    echo 0x17847040 2 > $DCC_PATH/config
    echo 0x17847050 2 > $DCC_PATH/config
    echo 0x17847060 2 > $DCC_PATH/config
    echo 0x17847070 2 > $DCC_PATH/config
    echo 0x17847080 2 > $DCC_PATH/config
    echo 0x17847090 2 > $DCC_PATH/config
    echo 0x178470a0 2 > $DCC_PATH/config
    echo 0x178470b0 2 > $DCC_PATH/config
    echo 0x178470c0 2 > $DCC_PATH/config
    echo 0x17850000 2 > $DCC_PATH/config
    echo 0x17850010 2 > $DCC_PATH/config
    echo 0x17850030 2 > $DCC_PATH/config
    echo 0x17850040 > $DCC_PATH/config
    echo 0x17854000 > $DCC_PATH/config
    echo 0x17854008 4 > $DCC_PATH/config
    echo 0x179c8814 2 > $DCC_PATH/config
    echo 0x179d0104 > $DCC_PATH/config
    echo 0x179d0118 2 > $DCC_PATH/config
    echo 0x179d0148 2 > $DCC_PATH/config
    echo 0x179d1600 > $DCC_PATH/config
    echo 0x179d1678 > $DCC_PATH/config
    echo 0x179d1688 2 > $DCC_PATH/config
    echo 0x179d1694 3 > $DCC_PATH/config
    echo 0x179d1820 3 > $DCC_PATH/config
    echo 0x17b70000 > $DCC_PATH/config
    echo 0x17b70008 2 > $DCC_PATH/config
    echo 0x17b71000 > $DCC_PATH/config
    echo 0x17b71008 2 > $DCC_PATH/config

    #APSS_CPUCX
    echo 0x164807f8 > $DCC_PATH/config
    echo 0x16480810 3 > $DCC_PATH/config
    echo 0x16483000 40 > $DCC_PATH/config
    echo 0x16483a00 2 > $DCC_PATH/config
    echo 0x16488908 > $DCC_PATH/config
    echo 0x16488C18 > $DCC_PATH/config
    echo 0x164A8908 > $DCC_PATH/config
    echo 0x164A8C18 > $DCC_PATH/config
    echo 0x164a07f8 > $DCC_PATH/config
    echo 0x164a0810 3 > $DCC_PATH/config
    echo 0x164a3000 40 > $DCC_PATH/config
    echo 0x164a3a00 2 > $DCC_PATH/config

    #APSS_CPUMX
    echo 0x16493000 40 > $DCC_PATH/config
    echo 0x16493a00 2 > $DCC_PATH/config
    echo 0x16498C18 > $DCC_PATH/config
    echo 0x164B8C18 > $DCC_PATH/config
    echo 0x164b3a00 2 > $DCC_PATH/config

    #APSS_INTU
    # echo 0x16440000 2 > $DCC_PATH/config
    # echo 0x16440020 3 > $DCC_PATH/config
    # echo 0x16440030 > $DCC_PATH/config
    # echo 0x1644003c > $DCC_PATH/config
    # echo 0x16440044 3 > $DCC_PATH/config
    # echo 0x16440438 > $DCC_PATH/config
    # echo 0x16440500 5 > $DCC_PATH/config
    echo 0x16562000 2 > $DCC_PATH/config
    echo 0x16565004 > $DCC_PATH/config

    #APSS_NSINW
    echo 0x17000BD0 > $DCC_PATH/config
    echo 0x170404A0 > $DCC_PATH/config
    echo 0x170A0590 > $DCC_PATH/config
    echo 0x170C0330 > $DCC_PATH/config
    echo 0x170C0338 > $DCC_PATH/config
    echo 0x170C0340 > $DCC_PATH/config
    echo 0x170C0518 > $DCC_PATH/config
    echo 0x170C0528 > $DCC_PATH/config
    echo 0x170C0538 > $DCC_PATH/config
    echo 0x170C0560 4 > $DCC_PATH/config
    echo 0x17200BD0 > $DCC_PATH/config
    echo 0x172404A0 > $DCC_PATH/config
    echo 0x172A0590 > $DCC_PATH/config
    echo 0x172C0330 > $DCC_PATH/config
    echo 0x172C0338 > $DCC_PATH/config
    echo 0x172C0340 > $DCC_PATH/config
    echo 0x172C0518 > $DCC_PATH/config
    echo 0x172C0528 > $DCC_PATH/config
    echo 0x172C0538 > $DCC_PATH/config
    echo 0x172C0560 4 > $DCC_PATH/config

    #APSS_WDOG_STATUS
    echo 0x1641000C > $DCC_PATH/config
    # echo 0x1641400C > $DCC_PATH/config

    #NCC_GBL_WDOG_THRESHOLD
    echo 0x18830320 2 > $DCC_PATH/config
    echo 0x19830320 2 > $DCC_PATH/config

    #NCC0_CORE0_NCC_RAS/URAS
    echo 0x18040010 6 > $DCC_PATH/config
    echo 0x18040040 10 > $DCC_PATH/config
    echo 0x18040090 6 > $DCC_PATH/config
    echo 0x18850020 2 > $DCC_PATH/config
    echo 0x18850060 2 > $DCC_PATH/config
    echo 0x188500A0 2 > $DCC_PATH/config
    echo 0x188500E0 2 > $DCC_PATH/config
    echo 0x18850120 2 > $DCC_PATH/config
    echo 0x18850160 2 > $DCC_PATH/config
    echo 0x189C1000 > $DCC_PATH/config
    echo 0x199C1000 > $DCC_PATH/config

    #NCC PLL
    echo 0x18A30000 9 > $DCC_PATH/config
    echo 0x18A30030 > $DCC_PATH/config
    echo 0x18A3003C 2 > $DCC_PATH/config
    echo 0x19A30000 9 > $DCC_PATH/config
    echo 0x19A30030 > $DCC_PATH/config
    echo 0x19A3003C 2 > $DCC_PATH/config
}

gemnoc_dump()
{
    # gem_noc_fault_sbm
    echo 0x24201040 1 > $DCC_PATH/config
    echo 0x24201048 1 > $DCC_PATH/config

    #; gem_noc_qns_llcc_even_poc_err
    echo 0x24100010 1 > $DCC_PATH/config
    echo 0x24100020 6 > $DCC_PATH/config
    #; gem_noc_qns_llcc_odd_poc_err
    echo 0x24180010 1 > $DCC_PATH/config
    echo 0x24180020 6 > $DCC_PATH/config

    #; gem_noc_qns_cnoc_poc_err
    echo 0x24200010 1 > $DCC_PATH/config
    echo 0x24200020 6 > $DCC_PATH/config
    #; gem_noc_qns_pcie_poc_err
    echo 0x24200410 1 > $DCC_PATH/config
    echo 0x24200420 6 > $DCC_PATH/config

    #; gem_noc_qns_llcc_even_poc_dbg
    echo 0x24102010 1 > $DCC_PATH/config
    echo 0x24102038 1 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102038 1 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102038 1 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102038 1 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102008 2 > $DCC_PATH/config

    #; gem_noc_qns_llcc_odd_poc_dbg
    echo 0x24181010 1 > $DCC_PATH/config
    echo 0x24181038 1 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181038 1 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181038 1 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181038 1 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181008 2 > $DCC_PATH/config

    #; gem_noc_qns_cnoc_poc_dbg
    echo 0x24203010 1 > $DCC_PATH/config
    echo 0x24203038 1 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203038 1 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203038 1 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203038 1 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203030 2 > $DCC_PATH/config
    echo 0x24203008 2 > $DCC_PATH/config
    #; gem_noc_qns_pcie_poc_dbg
    echo 0x24203410 1 > $DCC_PATH/config
    echo 0x24203438 1 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203438 1 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203438 1 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203438 1 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203430 2 > $DCC_PATH/config
    echo 0x24203408 2 > $DCC_PATH/config

    #; Coherent_even_chain
    echo 0x24104018 1 > $DCC_PATH/config
    echo 0x24104008 1 > $DCC_PATH/config
    echo 0x24104010 2 > $DCC_PATH/config
    echo 0x24104010 2 > $DCC_PATH/config
    echo 0x24104010 2 > $DCC_PATH/config
    echo 0x24104010 2 > $DCC_PATH/config
    #; NonCoherent_even_chain
    echo 0x24104098 1 > $DCC_PATH/config
    echo 0x24104088 1 > $DCC_PATH/config
    echo 0x24104090 2 > $DCC_PATH/config
    echo 0x24104090 2 > $DCC_PATH/config
    echo 0x24104090 2 > $DCC_PATH/config
    echo 0x24104090 2 > $DCC_PATH/config
    echo 0x24104090 2 > $DCC_PATH/config
    #; Coherent_odd_chain
    echo 0x24182018 1 > $DCC_PATH/config
    echo 0x24182008 1 > $DCC_PATH/config
    echo 0x24182010 2 > $DCC_PATH/config
    echo 0x24182010 2 > $DCC_PATH/config
    echo 0x24182010 2 > $DCC_PATH/config
    echo 0x24182010 2 > $DCC_PATH/config
    #; NonCoherent_odd_chain
    echo 0x24182098 1 > $DCC_PATH/config
    echo 0x24182088 1 > $DCC_PATH/config
    echo 0x24182090 2 > $DCC_PATH/config
    echo 0x24182090 2 > $DCC_PATH/config
    echo 0x24182090 2 > $DCC_PATH/config
    echo 0x24182090 2 > $DCC_PATH/config
    echo 0x24182090 2 > $DCC_PATH/config
    #; Coherent_sys_chain
    echo 0x24204018 1 > $DCC_PATH/config
    echo 0x24204008 1 > $DCC_PATH/config
    echo 0x24204010 2 > $DCC_PATH/config
    echo 0x24204010 2 > $DCC_PATH/config
    echo 0x24204010 2 > $DCC_PATH/config
    #; NonCoherent_sys_chain
    echo 0x24204098 1 > $DCC_PATH/config
    echo 0x24204088 1 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
    echo 0x24204090 2 > $DCC_PATH/config
}

gemnoc_dump_full_cxt()
{
    # gem_noc_qns_llcc_even_poc_dbg
    echo 0x24102028 0x2 > $DCC_PATH/config_write
    echo 0x40 > $DCC_PATH/loop
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x24102030 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    echo 0x24102028 0x1 > $DCC_PATH/config_write

    # gem_noc_qns_llcc_odd_poc_dbg
    echo 0x24181028 0x2 > $DCC_PATH/config_write
    echo 0x40 > $DCC_PATH/loop
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x24181030 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    echo 0x24181028 0x1 > $DCC_PATH/config_write

}

dc_noc_dump()
{
    #; dc_noc_dch_erl
    echo 0x240e0010 1 > $DCC_PATH/config
    echo 0x240e0020 8 > $DCC_PATH/config
    echo 0x240e0248 1 > $DCC_PATH/config
    #; dc_noc_ch_hm02_erl
    # echo 0x245f0010 1 > $DCC_PATH/config
    # echo 0x245f0020 8 > $DCC_PATH/config
    # echo 0x245f0248 1 > $DCC_PATH/config
    #; dc_noc_ch_hm13_erl
    # echo 0x247f0010 1 > $DCC_PATH/config
    # echo 0x247f0020 8 > $DCC_PATH/config
    # echo 0x247f0248 1 > $DCC_PATH/config
    #; llclpi_noc_erl
    echo 0x24330010 1 > $DCC_PATH/config
    echo 0x24330020 8 > $DCC_PATH/config
    echo 0x24330248 1 > $DCC_PATH/config

    #; dch/DebugChain
    echo 0x240e1018 1 > $DCC_PATH/config
    echo 0x240e1008 1 > $DCC_PATH/config
    echo 0x9  > $DCC_PATH/loop
    echo 0x240e1010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; ch_hm02/DebugChain
    # echo 0x245f2018 1 > $DCC_PATH/config
    # echo 0x245f2008 1 > $DCC_PATH/config
    # echo 0x3  > $DCC_PATH/loop
    # echo 0x245f2010 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
    #; ch_hm13/DebugChain
    # echo 0x247f2018 1 > $DCC_PATH/config
    # echo 0x247f2008 1 > $DCC_PATH/config
    # echo 0x3  > $DCC_PATH/loop
    # echo 0x247f2010 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
    #; llclpi_noc/DebugChain
    echo 0x24331018 1 > $DCC_PATH/config
    echo 0x24331008 1 > $DCC_PATH/config
    echo 0x8  > $DCC_PATH/loop
    echo 0x24331010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

mmss_noc_dump()
{
    #; mmss_noc_erl
    echo 0x01780010 1 > $DCC_PATH/config
    echo 0x01780020 8 > $DCC_PATH/config
    echo 0x01780248 1 > $DCC_PATH/config
    #; mmss_noc/DebugChain
    # echo 0x01782018 1 > $DCC_PATH/config
    # echo 0x01782008 1 > $DCC_PATH/config
    # echo 0xc  > $DCC_PATH/loop
    # echo 0x01782010 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
    #; mmss_noc_QTB500/DebugChain
    # echo 0x01783018 1 > $DCC_PATH/config
    # echo 0x01783008 1 > $DCC_PATH/config
    # echo 0x11  > $DCC_PATH/loop
    # echo 0x01783010 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
}

system_noc_dump()
{
    #; system_noc_erl
    echo 0x01680010 1 > $DCC_PATH/config
    echo 0x01680020 8 > $DCC_PATH/config
    echo 0x01681048 1 > $DCC_PATH/config
    #; system_noc/DebugChain
    echo 0x01682018 1 > $DCC_PATH/config
    echo 0x01682008 1 > $DCC_PATH/config
    echo 0x6  > $DCC_PATH/loop
    echo 0x01682010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

aggre_noc_dump()
{
    #; a1_noc_aggre_noc_erl
    echo 0x016e0010 1 > $DCC_PATH/config
    echo 0x016e0020 8 > $DCC_PATH/config
    echo 0x016e0248 1 > $DCC_PATH/config
    #; a1_noc_aggre_noc_south/DebugChain
    # echo 0x016e1018 1 > $DCC_PATH/config
    # echo 0x016e1008 1 > $DCC_PATH/config
    # echo 0x4  > $DCC_PATH/loop
    # echo 0x016e1010 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
    #; a1_noc_aggre_noc_ANOC_NIU/DebugChain
    # echo 0x016e1098 1 > $DCC_PATH/config
    # echo 0x016e1088 1 > $DCC_PATH/config
    # echo 0x3  > $DCC_PATH/loop
    # echo 0x016e1090 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
    #; a1_noc_aggre_noc_ANOC_QTB/DebugChain
    # echo 0x016e1118 1 > $DCC_PATH/config
    # echo 0x016e1108 1 > $DCC_PATH/config
    # echo 0x7  > $DCC_PATH/loop
    # echo 0x016e1110 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop

    # aggre_noc/DebugChain_QTB_PCIe
    # echo 0x16C3018 1 > $DCC_PATH/config
    # echo 0x16C3008 1 > $DCC_PATH/config
    # echo 0x4  > $DCC_PATH/loop
    # echo 0x16C3010 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop

    # aggre_noc/DebugChain_pcie
    # echo 0x16C2018 1 > $DCC_PATH/config
    # echo 0x16C2008 1 > $DCC_PATH/config
    # echo 0x4  > $DCC_PATH/loop
    # echo 0x16C2010 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop

    #; a2_noc_aggre_noc_erl
    echo 0x01700010 1 > $DCC_PATH/config
    echo 0x01700020 8 > $DCC_PATH/config
    echo 0x01700248 1 > $DCC_PATH/config
    #; a2_noc_aggre_noc_center/DebugChain
    # echo 0x1702018 1 > $DCC_PATH/config
    # echo 0x1702008 1 > $DCC_PATH/config
    # echo 0x4  > $DCC_PATH/loop
    # echo 0x1702010 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
    #; a2_noc_aggre_noc_east/DebugChain
    # echo 0x1702218 1 > $DCC_PATH/config
    # echo 0x1702208 1 > $DCC_PATH/config
    # echo 0x2  > $DCC_PATH/loop
    # echo 0x1702210 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
    #; a2_noc_aggre_noc_north/DebugChain
    # echo 0x1702118 1 > $DCC_PATH/config
    # echo 0x1702108 1 > $DCC_PATH/config
    # echo 0x3  > $DCC_PATH/loop
    # echo 0x1702110 2 > $DCC_PATH/config
    # echo 0x1 > $DCC_PATH/loop
}

config_noc_dump()
{
    #; cnoc_cfg_erl
    echo 0x01600010 1 > $DCC_PATH/config
    echo 0x01600020 8 > $DCC_PATH/config
    echo 0x01600248 2 > $DCC_PATH/config
    echo 0x01600258 1 > $DCC_PATH/config
    #; cnoc_cfg_center/DebugChain
    echo 0x01602018 1 > $DCC_PATH/config
    echo 0x01602008 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01602010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_west/DebugChain
    echo 0x01602098 1 > $DCC_PATH/config
    echo 0x01602088 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01602090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_mmnoc/DebugChain
    echo 0x01602118 1 > $DCC_PATH/config
    echo 0x01602108 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x01602110 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_north/DebugChain
    echo 0x01602198 1 > $DCC_PATH/config
    echo 0x01602188 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x01602190 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_south/DebugChain
    echo 0x01602218 1 > $DCC_PATH/config
    echo 0x01602208 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01602210 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_east/DebugChain
    echo 0x1602098 1 > $DCC_PATH/config
    echo 0x1602088 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x1602090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; cnoc_main_erl
    echo 0x01500010 1 > $DCC_PATH/config
    echo 0x01500020 8 > $DCC_PATH/config
    echo 0x01500248 1 > $DCC_PATH/config
    echo 0x01500448 1 > $DCC_PATH/config
    #; cnoc_main_center/DebugChain
    echo 0x01502018 1 > $DCC_PATH/config
    echo 0x01502008 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01502010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_main_north/DebugChain
    echo 0x01502098 1 > $DCC_PATH/config
    echo 0x01502088 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01502090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

apss_noc_dump()
{
    # apps noc
    echo 0x16E00010 1 > $DCC_PATH/config
    echo 0x16E00020 8 > $DCC_PATH/config
    echo 0x16E00248 1 > $DCC_PATH/config
    echo 0x16E01018 1 > $DCC_PATH/config
    echo 0x16E01008 1 > $DCC_PATH/config
    echo 0x6  > $DCC_PATH/loop
    echo 0x16E01010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #apss_nsinoc
    echo 0x1B600010 1 > $DCC_PATH/config
    echo 0x1B600020 8 > $DCC_PATH/config
    echo 0x1B600248 1 > $DCC_PATH/config
    echo 0x1B601018 1 > $DCC_PATH/config
    echo 0x1B601008 1 > $DCC_PATH/config
    echo 0x6  > $DCC_PATH/loop
    echo 0x1B601010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

config_dcc_gic()
{
    echo 0x16000104 30 > $DCC_PATH/config
    echo 0x16000204 29 > $DCC_PATH/config
    echo 0x16000384 30 > $DCC_PATH/config
}

config_dcc_rpmh()
{
    # echo 0xB291024 > $DCC_PATH/config
    #CX/MX/DDRAUX_SEQ
    echo 0xC201244 > $DCC_PATH/config
    echo 0xC202244 > $DCC_PATH/config
    echo 0xBDE1034 > $DCC_PATH/config
    echo 0xBDE1038 > $DCC_PATH/config

    #RPMH_PDC_APSS
    echo 0xB201020 2 > $DCC_PATH/config
    echo 0xB211020 2 > $DCC_PATH/config
    # echo 0xB221020 2 > $DCC_PATH/config
    # echo 0xB231020 2 > $DCC_PATH/config
    echo 0xB204520 > $DCC_PATH/config
    echo 0xB200000 1 > $DCC_PATH/config
    echo 0xB210000 1 > $DCC_PATH/config
    # echo 0xB220000 1 > $DCC_PATH/config
    # echo 0xB230000 1 > $DCC_PATH/config
}

config_dcc_apss_rscc()
{
    #APSS_RSCC_RSC register
    echo 0x16500010 > $DCC_PATH/config
    echo 0x16510010 > $DCC_PATH/config
    echo 0x16520010 > $DCC_PATH/config
    echo 0x16530010 > $DCC_PATH/config
    echo 0x16500030 > $DCC_PATH/config
    echo 0x16510030 > $DCC_PATH/config
    echo 0x16520030 > $DCC_PATH/config
    echo 0x16530030 > $DCC_PATH/config
    echo 0x16500038 > $DCC_PATH/config
    echo 0x16510038 > $DCC_PATH/config
    echo 0x16520038 > $DCC_PATH/config
    echo 0x16530038 > $DCC_PATH/config
    echo 0x16500040 > $DCC_PATH/config
    echo 0x16510040 > $DCC_PATH/config
    echo 0x16520040 > $DCC_PATH/config
    echo 0x16530040 > $DCC_PATH/config
    echo 0x16500048 > $DCC_PATH/config
    echo 0x16500400 3 > $DCC_PATH/config
    echo 0x16510400 3 > $DCC_PATH/config
    echo 0x16520400 3 > $DCC_PATH/config
    echo 0x16530400 3 > $DCC_PATH/config
    echo 0x16510d3c  > $DCC_PATH/config
    echo 0x16510d54  > $DCC_PATH/config
    echo 0x16510d6c  > $DCC_PATH/config
    echo 0x16510d84  > $DCC_PATH/config
    echo 0x16510d9c  > $DCC_PATH/config
    echo 0x16510db4  > $DCC_PATH/config
    echo 0x16510dcc  > $DCC_PATH/config
    echo 0x16510de4  > $DCC_PATH/config
    echo 0x16510dfc  > $DCC_PATH/config
    echo 0x16510e14  > $DCC_PATH/config
    echo 0x16510e2c  > $DCC_PATH/config
    echo 0x16510e44  > $DCC_PATH/config
    echo 0x16510e5c  > $DCC_PATH/config
    echo 0x16510e74  > $DCC_PATH/config
    echo 0x16510e8c  > $DCC_PATH/config
    echo 0x16510ea4  > $DCC_PATH/config
    echo 0x16510fdc  > $DCC_PATH/config
    echo 0x16510ff4  > $DCC_PATH/config
    echo 0x1651100c  > $DCC_PATH/config
    echo 0x16511024  > $DCC_PATH/config
    echo 0x1651103c  > $DCC_PATH/config
    echo 0x16511054  > $DCC_PATH/config
    echo 0x1651106c  > $DCC_PATH/config
    echo 0x16511084  > $DCC_PATH/config
    echo 0x1651109c  > $DCC_PATH/config
    echo 0x165110b4  > $DCC_PATH/config
    echo 0x165110cc  > $DCC_PATH/config
    echo 0x165110e4  > $DCC_PATH/config
    echo 0x165110fc  > $DCC_PATH/config
    echo 0x16511114  > $DCC_PATH/config
    echo 0x1651112c  > $DCC_PATH/config
    echo 0x16511144  > $DCC_PATH/config
    echo 0x1651127c  > $DCC_PATH/config
    echo 0x16511294  > $DCC_PATH/config
    echo 0x165112ac  > $DCC_PATH/config
    echo 0x165112c4  > $DCC_PATH/config
    echo 0x165112dc  > $DCC_PATH/config
    echo 0x165112f4  > $DCC_PATH/config
    echo 0x1651130c  > $DCC_PATH/config
    echo 0x16511324  > $DCC_PATH/config
    echo 0x1651133c  > $DCC_PATH/config
    echo 0x16511354  > $DCC_PATH/config
    echo 0x1651136c  > $DCC_PATH/config
    echo 0x16511384  > $DCC_PATH/config
    echo 0x1651139c  > $DCC_PATH/config
    echo 0x165113b4  > $DCC_PATH/config
    echo 0x165113cc  > $DCC_PATH/config
    echo 0x165113e4  > $DCC_PATH/config
    echo 0x1651151c  > $DCC_PATH/config
    echo 0x16511534  > $DCC_PATH/config
    echo 0x1651154c  > $DCC_PATH/config
    echo 0x16511564  > $DCC_PATH/config
    echo 0x1651157c  > $DCC_PATH/config
    echo 0x16511594  > $DCC_PATH/config
    echo 0x165115ac  > $DCC_PATH/config
    echo 0x165115c4  > $DCC_PATH/config
    echo 0x165115dc  > $DCC_PATH/config
    echo 0x165115f4  > $DCC_PATH/config
    echo 0x1651160c  > $DCC_PATH/config
    echo 0x16511624  > $DCC_PATH/config
    echo 0x1651163c  > $DCC_PATH/config
    echo 0x16511654  > $DCC_PATH/config
    echo 0x1651166c  > $DCC_PATH/config
    echo 0x16511684  > $DCC_PATH/config
}

config_dcc_anoc_pcie()
{
    echo 0x110004 2 > $DCC_PATH/config
    echo 0x11003C 3 > $DCC_PATH/config
    #RPMH_SYS_NOC_CMD_DFSR
    echo 0x176040 1 > $DCC_PATH/config
}

config_dcc_rng()
{
    # echo 0x10C0000 4  > $DCC_PATH/config
    echo 0x10C1000 2  > $DCC_PATH/config
    echo 0x10C1010 7  > $DCC_PATH/config
    echo 0x10C1100 3  > $DCC_PATH/config
    echo 0x10C1110 5  > $DCC_PATH/config
    echo 0x10C1130 2  > $DCC_PATH/config
    echo 0x10C113C 2  > $DCC_PATH/config
    echo 0x10C1148 3  > $DCC_PATH/config
    echo 0x10C1800 11 > $DCC_PATH/config
    echo 0x10C2000 1  > $DCC_PATH/config
    echo 0x10CF004 1  > $DCC_PATH/config
}

lpass_cesta_dump()
{
    #; HW client_VCDq_perf_ol_status
    echo 0x07210010 1 > $DCC_PATH/config
    echo 0x07210024 1 > $DCC_PATH/config
    echo 0x07210038 1 > $DCC_PATH/config
    echo 0x0721004C 1 > $DCC_PATH/config
    echo 0x07210060 1 > $DCC_PATH/config
    echo 0x07211010 1 > $DCC_PATH/config
    echo 0x07211024 1 > $DCC_PATH/config
    echo 0x07211038 1 > $DCC_PATH/config
    echo 0x0721104C 1 > $DCC_PATH/config
    echo 0x07211060 1 > $DCC_PATH/config
    echo 0x07212010 1 > $DCC_PATH/config
    echo 0x07212024 1 > $DCC_PATH/config
    echo 0x07212038 1 > $DCC_PATH/config
    echo 0x0721204C 1 > $DCC_PATH/config
    echo 0x07212060 1 > $DCC_PATH/config

    #; HW client_BW_perf_ol_status
    echo 0x07210074 1 > $DCC_PATH/config
    echo 0x07210088 1 > $DCC_PATH/config
    echo 0x0721009C 1 > $DCC_PATH/config
    echo 0x072100b0 1 > $DCC_PATH/config
    echo 0x07211074 1 > $DCC_PATH/config
    echo 0x07211088 1 > $DCC_PATH/config
    echo 0x0721109C 1 > $DCC_PATH/config
    echo 0x072110b0 1 > $DCC_PATH/config
    echo 0x07212074 1 > $DCC_PATH/config
    echo 0x07212088 1 > $DCC_PATH/config
    echo 0x0721209C 1 > $DCC_PATH/config
    echo 0x072120b0 1 > $DCC_PATH/config

    #; HW client_channel busy status
    echo 0x072101f4 1 > $DCC_PATH/config
    echo 0x072111f4 1 > $DCC_PATH/config
    echo 0x072121f4 1 > $DCC_PATH/config

    #; HW client_channel power index status
    echo 0x07210200 1 > $DCC_PATH/config
    echo 0x07211200 1 > $DCC_PATH/config
    echo 0x07212200 1 > $DCC_PATH/config

    #; SW client_channel power index status
    echo 0x07210234 32 > $DCC_PATH/config
    echo 0x0721043C 1 > $DCC_PATH/config
    echo 0x07210534 1 > $DCC_PATH/config

    #; CRMC VCD status
    echo 0x07213870 1 > $DCC_PATH/config
    echo 0x07213a54 1 > $DCC_PATH/config
    echo 0x07213c38 1 > $DCC_PATH/config
    echo 0x07213e1c 1 > $DCC_PATH/config
    echo 0x07214000 1 > $DCC_PATH/config
    echo 0x072141e4 1 > $DCC_PATH/config
    echo 0x072143c8 1 > $DCC_PATH/config
}

config_dcc_tsens()
{
    echo 0x0C222004 1 > $DCC_PATH/config
    echo 0x0C228014 1 > $DCC_PATH/config
    echo 0x0C2280E0 1 > $DCC_PATH/config
    echo 0x0C2280EC 1 > $DCC_PATH/config
    echo 0x0C2280A0 16 > $DCC_PATH/config
    echo 0x0C2280E8 1 > $DCC_PATH/config
    echo 0x0C22813C 1 > $DCC_PATH/config
    echo 0x0C228144 1 > $DCC_PATH/config
    echo 0x0C22814C 1 > $DCC_PATH/config
    echo 0x0C228150 1 > $DCC_PATH/config
    echo 0x0C223004 1 > $DCC_PATH/config
    echo 0x0C229014 1 > $DCC_PATH/config
    echo 0x0C2290E0 1 > $DCC_PATH/config
    echo 0x0C2290EC 1 > $DCC_PATH/config
    echo 0x0C2290A0 16 > $DCC_PATH/config
    echo 0x0C2290E8 1 > $DCC_PATH/config
    echo 0x0C22913C 1 > $DCC_PATH/config
    echo 0x0C229144 1 > $DCC_PATH/config
    echo 0x0C22914C 1 > $DCC_PATH/config
    echo 0x0C229150 1 > $DCC_PATH/config
    echo 0x0C224004 1 > $DCC_PATH/config
    echo 0x0C22A014 1 > $DCC_PATH/config
    echo 0x0C22A0E0 1 > $DCC_PATH/config
    echo 0x0C22A0EC 1 > $DCC_PATH/config
    echo 0x0C22A0A0 16 > $DCC_PATH/config
    echo 0x0C22A0E8 1 > $DCC_PATH/config
    echo 0x0C22A13C 1 > $DCC_PATH/config
    echo 0x0C22A144 1 > $DCC_PATH/config
    echo 0x0C22A14C 1 > $DCC_PATH/config
    echo 0x0C22A150 1 > $DCC_PATH/config
    echo 0x0C225004 1 > $DCC_PATH/config
    echo 0x0C22B014 1 > $DCC_PATH/config
    echo 0x0C22B0E0 1 > $DCC_PATH/config
    echo 0x0C22B0EC 1 > $DCC_PATH/config
    echo 0x0C22B0A0 16 > $DCC_PATH/config
    echo 0x0C22B0E8 1 > $DCC_PATH/config
    echo 0x0C22B13C 1 > $DCC_PATH/config
    echo 0x0C22B144 1 > $DCC_PATH/config
    echo 0x0C22B14C 1 > $DCC_PATH/config
    echo 0x0C22B150 1 > $DCC_PATH/config
}

config_dcc_gpu_aon()
{
    echo 0x3d40004  > $DCC_PATH/config
    echo 0x3d4000c  > $DCC_PATH/config
    echo 0x3d41004  > $DCC_PATH/config
    echo 0x3d4100c  > $DCC_PATH/config
    echo 0x3d42004  > $DCC_PATH/config
    echo 0x3d4200c  > $DCC_PATH/config
    echo 0x3d43004  > $DCC_PATH/config
    echo 0x3d4300c  > $DCC_PATH/config
    echo 0x3d44004  > $DCC_PATH/config
    echo 0x3d4400c  > $DCC_PATH/config
    echo 0x3d45004  > $DCC_PATH/config
    echo 0x3d4500c  > $DCC_PATH/config
    echo 0x3d46004  > $DCC_PATH/config
    echo 0x3d4600c  > $DCC_PATH/config
    echo 0x3d47004  > $DCC_PATH/config
    echo 0x3d4700c  > $DCC_PATH/config
    echo 0x3d50000 21 > $DCC_PATH/config
    echo 0x3d500d0  > $DCC_PATH/config
    echo 0x3d500d8  > $DCC_PATH/config
    echo 0x3d50100 3 > $DCC_PATH/config
    echo 0x3d50110 2 > $DCC_PATH/config
    echo 0x3d5011c  > $DCC_PATH/config
    echo 0x3d50200 5 > $DCC_PATH/config
    echo 0x3d50400 5 > $DCC_PATH/config
    echo 0x3d50450  > $DCC_PATH/config
    echo 0x3d50460 2 > $DCC_PATH/config
    echo 0x3d50490 12 > $DCC_PATH/config
    echo 0x3d50550  > $DCC_PATH/config
    echo 0x3d50d00 2 > $DCC_PATH/config
    echo 0x3d50d10  > $DCC_PATH/config
    echo 0x3d50d18 13 > $DCC_PATH/config
    echo 0x3d50fe0  > $DCC_PATH/config
    echo 0x3d50ff8  > $DCC_PATH/config
    echo 0x3d51010  > $DCC_PATH/config
    echo 0x3d51028  > $DCC_PATH/config
    echo 0x3d51280  > $DCC_PATH/config
    echo 0x3d51520  > $DCC_PATH/config
    echo 0x3d51538  > $DCC_PATH/config
    echo 0x3d51550  > $DCC_PATH/config
    echo 0x3d517c0  > $DCC_PATH/config
    echo 0x3d51a60  > $DCC_PATH/config
    echo 0x3d51a78  > $DCC_PATH/config
    echo 0x3d51a90  > $DCC_PATH/config
    echo 0x3d51aa8  > $DCC_PATH/config
    echo 0x3d51d00  > $DCC_PATH/config
    echo 0x3d51fa0  > $DCC_PATH/config
    echo 0x3d51fb8  > $DCC_PATH/config
    echo 0x3d52240  > $DCC_PATH/config
    echo 0x3d52258  > $DCC_PATH/config
    echo 0x3d524e0  > $DCC_PATH/config
    echo 0x3d8e100 8 > $DCC_PATH/config
    echo 0x3d8ec00 2 > $DCC_PATH/config
    echo 0x3d8ec0c  > $DCC_PATH/config
    echo 0x3d8ec14 10 > $DCC_PATH/config
    echo 0x3d8ec40 4 > $DCC_PATH/config
    echo 0x3d8ec54 2 > $DCC_PATH/config
    echo 0x3d8eca0  > $DCC_PATH/config
    echo 0x3d8ecc0  > $DCC_PATH/config
    echo 0x3d9200c 3 > $DCC_PATH/config
    echo 0x3d93000  > $DCC_PATH/config
    echo 0x3d94000 3 > $DCC_PATH/config
    echo 0x3d95000 5 > $DCC_PATH/config
    echo 0x3d96000 5 > $DCC_PATH/config
    echo 0x3d97000 5 > $DCC_PATH/config
    echo 0x3d98000 5 > $DCC_PATH/config
    echo 0x3d99000 7 > $DCC_PATH/config
    echo 0x3d99054 9 > $DCC_PATH/config
    echo 0x3d9907c 34 > $DCC_PATH/config
    echo 0x3d9910c 2 > $DCC_PATH/config
    echo 0x3d991e0 3 > $DCC_PATH/config
    echo 0x3d99224 2 > $DCC_PATH/config
    echo 0x3d99270 3 > $DCC_PATH/config
    echo 0x3d99280 2 > $DCC_PATH/config
    echo 0x3d99314 3 > $DCC_PATH/config
    echo 0x3d993a0 3 > $DCC_PATH/config
    echo 0x3d993e4 4 > $DCC_PATH/config
    echo 0x3d9942c  > $DCC_PATH/config
    echo 0x3d99470 3 > $DCC_PATH/config
    echo 0x3d99500 12 > $DCC_PATH/config
    echo 0x3d99550 3 > $DCC_PATH/config
    echo 0x3d99560 5 > $DCC_PATH/config
    echo 0x3d99578 2 > $DCC_PATH/config
    echo 0x3d9958c  > $DCC_PATH/config
    echo 0x3d995b4 7 > $DCC_PATH/config
    echo 0x3d995d8  > $DCC_PATH/config
    echo 0x3d995e0 3 > $DCC_PATH/config
    echo 0x3d9e000  > $DCC_PATH/config
    echo 0x3d9e040 5 > $DCC_PATH/config
    echo 0x3d9e080 5 > $DCC_PATH/config
    echo 0x3d9e0a0 3 > $DCC_PATH/config
    echo 0x3d9e0c8 11 > $DCC_PATH/config
    echo 0x3d9e0f8 26 > $DCC_PATH/config
    echo 0x3d9e200 4 > $DCC_PATH/config
    echo 0x3d9f000 2 > $DCC_PATH/config
}

config_dcc_gpu_gmu()
{
    echo 0x3d7d000 12 > $DCC_PATH/config
    echo 0x3d7d03c 3 > $DCC_PATH/config
    echo 0x3d7d400  > $DCC_PATH/config
    echo 0x3d7d41c  > $DCC_PATH/config
    echo 0x3d7d424 3 > $DCC_PATH/config
    echo 0x3d7dc58  > $DCC_PATH/config
    echo 0x3d7dc94  > $DCC_PATH/config
    echo 0x3d7dca4  > $DCC_PATH/config
    echo 0x3d7dd58 2 > $DCC_PATH/config
    echo 0x3d7df80 2 > $DCC_PATH/config
    echo 0x3d7df90 2 > $DCC_PATH/config
    echo 0x3d7dfa0 2 > $DCC_PATH/config
    echo 0x3d7dfb0 2 > $DCC_PATH/config
    echo 0x3d7e000 5 > $DCC_PATH/config
    echo 0x3d7e01c 2 > $DCC_PATH/config
    echo 0x3d7e02c 2 > $DCC_PATH/config
    echo 0x3d7e03c  > $DCC_PATH/config
    echo 0x3d7e044  > $DCC_PATH/config
    echo 0x3d7e04c 5 > $DCC_PATH/config
    echo 0x3d7e064 4 > $DCC_PATH/config
    echo 0x3d7e090 13 > $DCC_PATH/config
    echo 0x3d7e100 2 > $DCC_PATH/config
    echo 0x3d7e130  > $DCC_PATH/config
    echo 0x3d7e140  > $DCC_PATH/config
    echo 0x3d7e500 2 > $DCC_PATH/config
    echo 0x3d7e50c  > $DCC_PATH/config
    echo 0x3d7e520  > $DCC_PATH/config
    echo 0x3d7e53c  > $DCC_PATH/config
    echo 0x3d7e550 2 > $DCC_PATH/config
    echo 0x3d7e574  > $DCC_PATH/config
    echo 0x3d7e5c0  > $DCC_PATH/config
    echo 0x3d7e5f0 3 > $DCC_PATH/config
    echo 0x3d7e600 2 > $DCC_PATH/config
    echo 0x3d7e610 3 > $DCC_PATH/config
    echo 0x3d7e648 2 > $DCC_PATH/config
    echo 0x3d7e658 9 > $DCC_PATH/config
    echo 0x3d7e700 16 > $DCC_PATH/config
    echo 0x3d7e7c4  > $DCC_PATH/config
    echo 0x3d7e7e0 3 > $DCC_PATH/config
    echo 0x3d7e7f0  > $DCC_PATH/config
    echo 0x3d7e800 4 > $DCC_PATH/config
    echo 0x3d7f050  > $DCC_PATH/config
    echo 0x3d7f060 2 > $DCC_PATH/config
    echo 0x3d7f080  > $DCC_PATH/config
    echo 0x3d7f090 3 > $DCC_PATH/config
    echo 0x3d80080  > $DCC_PATH/config
    echo 0x3d800d0 3 > $DCC_PATH/config
    echo 0x3d80c80 3 > $DCC_PATH/config
    echo 0x3d80c90 3 > $DCC_PATH/config
    echo 0x3d80ca0 3 > $DCC_PATH/config
    echo 0x3d80d40  > $DCC_PATH/config
}

config_dcc_gpu_gcc()
{
    echo 0x129000  > $DCC_PATH/config
    echo 0x12903c  > $DCC_PATH/config
    echo 0x171004  > $DCC_PATH/config
    echo 0x17100c 5 > $DCC_PATH/config
    echo 0x171150  > $DCC_PATH/config
    echo 0x17b000  > $DCC_PATH/config
    echo 0x17b03c  > $DCC_PATH/config
    echo 0x17c000  > $DCC_PATH/config
    echo 0x17c03c  > $DCC_PATH/config
    echo 0x17d000  > $DCC_PATH/config
    echo 0x17d03c  > $DCC_PATH/config
    echo 0x17e000  > $DCC_PATH/config
    echo 0x17e03c  > $DCC_PATH/config
    echo 0x186000  > $DCC_PATH/config
    echo 0x18603c  > $DCC_PATH/config
}

config_dcc_gpu_gbif()
{
    echo 0x3d0f000 12 > $DCC_PATH/config
    echo 0x3d0f100 3 > $DCC_PATH/config
    echo 0x3d0f114 3 > $DCC_PATH/config
    echo 0x3d0f124 6 > $DCC_PATH/config
}

config_dcc_gpu_cp()
{
    echo 0x3d00000  > $DCC_PATH/config
    echo 0x3d00008  > $DCC_PATH/config
    echo 0x3d00020 6 > $DCC_PATH/config
    echo 0x3d00040 4 > $DCC_PATH/config
    echo 0x3d00054 2 > $DCC_PATH/config
    echo 0x3d00060  > $DCC_PATH/config
    echo 0x3d00068  > $DCC_PATH/config
    echo 0x3d00070  > $DCC_PATH/config
    echo 0x3d000a0 4 > $DCC_PATH/config
    echo 0x3d000b4 13 > $DCC_PATH/config
    echo 0x3d00100 20 > $DCC_PATH/config
    echo 0x3d00188 5 > $DCC_PATH/config
    echo 0x3d001a4 6 > $DCC_PATH/config
    echo 0x3d001c4 2 > $DCC_PATH/config
    echo 0x3d001d0  > $DCC_PATH/config
    echo 0x3d001d8 2 > $DCC_PATH/config
    echo 0x3d001fc 28 > $DCC_PATH/config
    echo 0x3d00274 19 > $DCC_PATH/config
    echo 0x3d002c8 35 > $DCC_PATH/config
    echo 0x3d0035c 12 > $DCC_PATH/config
    echo 0x3d00394 2 > $DCC_PATH/config
    echo 0x3d003a4 9 > $DCC_PATH/config
    echo 0x3d003d0 3 > $DCC_PATH/config
    echo 0x3d003e4 16 > $DCC_PATH/config
    echo 0x3d0042c 4 > $DCC_PATH/config
    echo 0x3d00444  > $DCC_PATH/config
    echo 0x3d00450 9 > $DCC_PATH/config
    echo 0x3d0047c 3 > $DCC_PATH/config
    echo 0x3d00494  > $DCC_PATH/config
    echo 0x3d0049c  > $DCC_PATH/config
    echo 0x3d004a4  > $DCC_PATH/config
    echo 0x3d004ac 7 > $DCC_PATH/config
    echo 0x3d004d0 5 > $DCC_PATH/config
    echo 0x3d004e8  > $DCC_PATH/config
    echo 0x3d004f0 4 > $DCC_PATH/config
    echo 0x3d00508 15 > $DCC_PATH/config
    echo 0x3d0054c 3 > $DCC_PATH/config
    echo 0x3d00560 2 > $DCC_PATH/config
    echo 0x3d00570  > $DCC_PATH/config
    echo 0x3d00598 20 > $DCC_PATH/config
    echo 0x3d00680  > $DCC_PATH/config
    echo 0x3d00f80  > $DCC_PATH/config
    echo 0x3d00fc0  > $DCC_PATH/config
    echo 0x3d01100  > $DCC_PATH/config
    echo 0x3d02000 31 > $DCC_PATH/config
    echo 0x3d02080 14 > $DCC_PATH/config
    echo 0x3d020d8 9 > $DCC_PATH/config
    echo 0x3d02100 8 > $DCC_PATH/config
    echo 0x3d0212c 5 > $DCC_PATH/config
    echo 0x3d022c0 12 > $DCC_PATH/config
    echo 0x3d02300 12 > $DCC_PATH/config
    echo 0x3d0239c 5 > $DCC_PATH/config
    echo 0x3d3c000 3 > $DCC_PATH/config
    echo 0x3d3d000  > $DCC_PATH/config
    echo 0x3d3e000 4 > $DCC_PATH/config
    echo 0x3d3f000 2 > $DCC_PATH/config
    echo 0x3d64000 14 > $DCC_PATH/config
    echo 0x3d66000 6 > $DCC_PATH/config
    echo 0x3d67000  > $DCC_PATH/config
    echo 0x3d68000 5 > $DCC_PATH/config
    echo 0x3d68020 13 > $DCC_PATH/config
    echo 0x3d6805c  > $DCC_PATH/config
    echo 0x3d68064  > $DCC_PATH/config
    echo 0x3d68088  > $DCC_PATH/config
    echo 0x3d68090 6 > $DCC_PATH/config
    echo 0x3d680fc 31 > $DCC_PATH/config
    echo 0x3d68180 4 > $DCC_PATH/config
    echo 0x3d68194 2 > $DCC_PATH/config
    echo 0x3d681a0 15 > $DCC_PATH/config
    echo 0x3d681e0 4 > $DCC_PATH/config
    echo 0x3d69000 23 > $DCC_PATH/config
    echo 0x3d69080 14 > $DCC_PATH/config
    echo 0x3d690c0 2 > $DCC_PATH/config
    echo 0x3d690d4  > $DCC_PATH/config
    echo 0x3d690dc  > $DCC_PATH/config
    echo 0x3d690e8  > $DCC_PATH/config
    echo 0x3d69108 10 > $DCC_PATH/config
    echo 0x3d69138 6 > $DCC_PATH/config
    echo 0x3d69158 3 > $DCC_PATH/config
    echo 0x3d6916c 3 > $DCC_PATH/config
    echo 0x3d6917c 4 > $DCC_PATH/config
}

config_dcc_gpu_fuse_controller()
{
    echo 0x221c2134 1 > $DCC_PATH/config
    # echo 0x221c8478 1 > $DCC_PATH/config
    # echo 0x221c8138 1 > $DCC_PATH/config
    # echo 0x221c8470 1 > $DCC_PATH/config
    # echo 0x221c88e8 1 > $DCC_PATH/config
    echo 0x221c0134 1 > $DCC_PATH/config
    echo 0x221c0418 1 > $DCC_PATH/config
    echo 0x221c01b8 1 > $DCC_PATH/config
    echo 0x221c0410 1 > $DCC_PATH/config
}

config_dcc_gpu()
{
    config_dcc_gpu_aon
    config_dcc_gpu_gcc
    config_dcc_gpu_gmu
    config_dcc_gpu_gbif
    config_dcc_gpu_cp
    config_dcc_gpu_fuse_controller
}

config_dcc_ddr()
{
    echo 0x240760A4  > $DCC_PATH/config
    echo 0x24076950  > $DCC_PATH/config
    echo 0x240A0008 2 > $DCC_PATH/config
    echo 0x240A1008 2 > $DCC_PATH/config
    echo 0x240A801C 2 > $DCC_PATH/config
    echo 0x240A8038 3 > $DCC_PATH/config
    echo 0x240A8058 5 > $DCC_PATH/config
    echo 0x240A8074 4 > $DCC_PATH/config
    echo 0x240A80A8  > $DCC_PATH/config
    echo 0x240A80B8  > $DCC_PATH/config
    echo 0x240A80EC 5 > $DCC_PATH/config
    echo 0x240A8140  > $DCC_PATH/config
    echo 0x240A8164 2 > $DCC_PATH/config
    echo 0x240A81C4 2 > $DCC_PATH/config
    echo 0x240A81DC 2 > $DCC_PATH/config
    echo 0x240A844C  > $DCC_PATH/config
    echo 0x240A845C  > $DCC_PATH/config
    echo 0x240A84C8 27 > $DCC_PATH/config
    echo 0x240A9000 2 > $DCC_PATH/config
    echo 0x240A9010 2 > $DCC_PATH/config
    echo 0x240A9020 3 > $DCC_PATH/config
    echo 0x240A9034 2 > $DCC_PATH/config
    echo 0x240A9130 3 > $DCC_PATH/config
    echo 0x240A9140 18 > $DCC_PATH/config
    echo 0x240A91AC 6 > $DCC_PATH/config
    echo 0x240A91C8  > $DCC_PATH/config
    echo 0x240A920C  > $DCC_PATH/config
    echo 0x240A9220 2 > $DCC_PATH/config
    echo 0x240A9264  > $DCC_PATH/config
    echo 0x240A9294 7 > $DCC_PATH/config
    echo 0x240A92B8  > $DCC_PATH/config
    echo 0x240A92F8  > $DCC_PATH/config
    echo 0x2487C000  > $DCC_PATH/config
    echo 0x2487C01C 3 > $DCC_PATH/config
    echo 0x2487C030 8 > $DCC_PATH/config
    echo 0x2487C054 2 > $DCC_PATH/config
    echo 0x2487C078  > $DCC_PATH/config
    echo 0x2487C108 9 > $DCC_PATH/config
    echo 0x2487C20C 3 > $DCC_PATH/config
    echo 0x248E1010  > $DCC_PATH/config
    echo 0x248E1060 3 > $DCC_PATH/config
    echo 0x248E1070  > $DCC_PATH/config
    echo 0x248E1084 3 > $DCC_PATH/config
    echo 0x248E3004  > $DCC_PATH/config
    echo 0x248E300C  > $DCC_PATH/config
    echo 0x248E4004  > $DCC_PATH/config
    echo 0x248E4010 2 > $DCC_PATH/config
    echo 0x248E4024 2 > $DCC_PATH/config
    echo 0x248E4038 2 > $DCC_PATH/config
    echo 0x248E9004  > $DCC_PATH/config
    echo 0x248E9010 3 > $DCC_PATH/config
    echo 0x248E9020 3 > $DCC_PATH/config
    echo 0x248E9030 3 > $DCC_PATH/config
    echo 0x248E9040 3 > $DCC_PATH/config
    echo 0x248E9050 3 > $DCC_PATH/config
    echo 0x248F001C  > $DCC_PATH/config
    echo 0x248F0050  > $DCC_PATH/config
    echo 0x248F0058  > $DCC_PATH/config
    echo 0x24BC0610 11 > $DCC_PATH/config
    echo 0x24BC0640 2 > $DCC_PATH/config
    echo 0x24BC06A0  > $DCC_PATH/config
    echo 0x24C7C000  > $DCC_PATH/config
    echo 0x24C7C01C 3 > $DCC_PATH/config
    echo 0x24C7C030 8 > $DCC_PATH/config
    echo 0x24C7C054 2 > $DCC_PATH/config
    echo 0x24C7C078  > $DCC_PATH/config
    echo 0x24C7C108 9 > $DCC_PATH/config
    echo 0x24C7C20C 3 > $DCC_PATH/config
    echo 0x24CE1010  > $DCC_PATH/config
    echo 0x24CE1060 3 > $DCC_PATH/config
    echo 0x24CE1070  > $DCC_PATH/config
    echo 0x24CE1084 3 > $DCC_PATH/config
    echo 0x24CE3004  > $DCC_PATH/config
    echo 0x24CE300C  > $DCC_PATH/config
    echo 0x24CE4004  > $DCC_PATH/config
    echo 0x24CE4010 2 > $DCC_PATH/config
    echo 0x24CE4024 2 > $DCC_PATH/config
    echo 0x24CE4038 2 > $DCC_PATH/config
    echo 0x24CE9004  > $DCC_PATH/config
    echo 0x24CE9010 3 > $DCC_PATH/config
    echo 0x24CE9020 3 > $DCC_PATH/config
    echo 0x24CE9030 3 > $DCC_PATH/config
    echo 0x24CE9040 3 > $DCC_PATH/config
    echo 0x24CE9050 3 > $DCC_PATH/config
    echo 0x24CF001C  > $DCC_PATH/config
    echo 0x24CF0050  > $DCC_PATH/config
    echo 0x24CF0058  > $DCC_PATH/config
    echo 0x24FC0610 11 > $DCC_PATH/config
    echo 0x24FC0640 2 > $DCC_PATH/config
    echo 0x24FC06A0  > $DCC_PATH/config
    echo 0x2587C000  > $DCC_PATH/config
    echo 0x2587C01C 3 > $DCC_PATH/config
    echo 0x2587C030 8 > $DCC_PATH/config
    echo 0x2587C054 2 > $DCC_PATH/config
    echo 0x2587C078  > $DCC_PATH/config
    echo 0x2587C108 9 > $DCC_PATH/config
    echo 0x2587C20C 3 > $DCC_PATH/config
    echo 0x258E1010  > $DCC_PATH/config
    echo 0x258E1060 3 > $DCC_PATH/config
    echo 0x258E1070  > $DCC_PATH/config
    echo 0x258E1084 3 > $DCC_PATH/config
    echo 0x258E3004  > $DCC_PATH/config
    echo 0x258E300C  > $DCC_PATH/config
    echo 0x258E4004  > $DCC_PATH/config
    echo 0x258E4010 2 > $DCC_PATH/config
    echo 0x258E4024 2 > $DCC_PATH/config
    echo 0x258E4038 2 > $DCC_PATH/config
    echo 0x258E9004  > $DCC_PATH/config
    echo 0x258E9010 3 > $DCC_PATH/config
    echo 0x258E9020 3 > $DCC_PATH/config
    echo 0x258E9030 3 > $DCC_PATH/config
    echo 0x258E9040 3 > $DCC_PATH/config
    echo 0x258E9050 3 > $DCC_PATH/config
    echo 0x258F001C  > $DCC_PATH/config
    echo 0x258F0050  > $DCC_PATH/config
    echo 0x258F0058  > $DCC_PATH/config
    echo 0x25BC0610 11 > $DCC_PATH/config
    echo 0x25BC0640 2 > $DCC_PATH/config
    echo 0x25BC06A0  > $DCC_PATH/config
    echo 0x25C7C000  > $DCC_PATH/config
    echo 0x25C7C01C 3 > $DCC_PATH/config
    echo 0x25C7C030 8 > $DCC_PATH/config
    echo 0x25C7C054 2 > $DCC_PATH/config
    echo 0x25C7C078  > $DCC_PATH/config
    echo 0x25C7C108 9 > $DCC_PATH/config
    echo 0x25C7C20C 3 > $DCC_PATH/config
    echo 0x25CE1010  > $DCC_PATH/config
    echo 0x25CE1060 3 > $DCC_PATH/config
    echo 0x25CE1070  > $DCC_PATH/config
    echo 0x25CE1084 3 > $DCC_PATH/config
    echo 0x25CE3004  > $DCC_PATH/config
    echo 0x25CE300C  > $DCC_PATH/config
    echo 0x25CE4004  > $DCC_PATH/config
    echo 0x25CE4010 2 > $DCC_PATH/config
    echo 0x25CE4024 2 > $DCC_PATH/config
    echo 0x25CE4038 2 > $DCC_PATH/config
    echo 0x25CE9004  > $DCC_PATH/config
    echo 0x25CE9010 3 > $DCC_PATH/config
    echo 0x25CE9020 3 > $DCC_PATH/config
    echo 0x25CE9030 3 > $DCC_PATH/config
    echo 0x25CE9040 3 > $DCC_PATH/config
    echo 0x25CE9050 3 > $DCC_PATH/config
    echo 0x25CF001C  > $DCC_PATH/config
    echo 0x25CF0050  > $DCC_PATH/config
    echo 0x25CF0058  > $DCC_PATH/config
    echo 0x25FC0610 11 > $DCC_PATH/config
    echo 0x25FC0640 2 > $DCC_PATH/config
    echo 0x25FC06A0  > $DCC_PATH/config
    echo 0x24076B00  2 > $DCC_PATH/config
    echo 0x24076B0C  2 > $DCC_PATH/config
    echo 0x24076B18  2 > $DCC_PATH/config
    echo 0x24076B24  2 > $DCC_PATH/config
    echo 0x24076B30  2 > $DCC_PATH/config
    echo 0x24076B3C  2 > $DCC_PATH/config
    echo 0x24076B48  2 > $DCC_PATH/config
    echo 0x24076B54  2 > $DCC_PATH/config
    echo 0x24076B60  2 > $DCC_PATH/config
    echo 0x24076B6C  2 > $DCC_PATH/config
    echo 0x24076B78  2 > $DCC_PATH/config
    echo 0x24076B84  2 > $DCC_PATH/config
    echo 0x24076B90  2 > $DCC_PATH/config
    echo 0x24076B9C  2 > $DCC_PATH/config
    echo 0x24076BA8  2 > $DCC_PATH/config
    echo 0x24076BB4  2 > $DCC_PATH/config
    echo 0x24076BC0  2 > $DCC_PATH/config
    echo 0x24076BCC  2 > $DCC_PATH/config
    echo 0x24076BD8  2 > $DCC_PATH/config
    echo 0x24076BE4  2 > $DCC_PATH/config
    echo 0x24076BF0  2 > $DCC_PATH/config
    echo 0x24076BFC  2 > $DCC_PATH/config
    echo 0x24076C08  2 > $DCC_PATH/config
    echo 0x24076C14  2 > $DCC_PATH/config
    echo 0x24076C20  2 > $DCC_PATH/config
    echo 0x24076C2C  2 > $DCC_PATH/config
    echo 0x24076C38  2 > $DCC_PATH/config
    echo 0x24076C44  2 > $DCC_PATH/config
    echo 0x24076C50  2 > $DCC_PATH/config
    echo 0x24076C5C  2 > $DCC_PATH/config
    echo 0x24076C68  2 > $DCC_PATH/config
    echo 0x24076C74  2 > $DCC_PATH/config
}

config_dcc_ddr_orig()
{
    #; DDRSS block registers
    # echo 0x240BA000 1 > $DCC_PATH/config
    # echo 0x240BA050 1 > $DCC_PATH/config
    # echo 0x240BA164 1 > $DCC_PATH/config
    # echo 0x240BA280 1 > $DCC_PATH/config
    # echo 0x240BA288 1 > $DCC_PATH/config
    # echo 0x240BA28C 1 > $DCC_PATH/config
    # echo 0x240BA290 1 > $DCC_PATH/config
    # echo 0x240BA294 1 > $DCC_PATH/config
    # echo 0x240BA298 1 > $DCC_PATH/config
    # echo 0x240BA29C 1 > $DCC_PATH/config
    # echo 0x240BA2A0 1 > $DCC_PATH/config
    # echo 0x240BA2A4 1 > $DCC_PATH/config
    # echo 0x240BA2C0 1 > $DCC_PATH/config
    # echo 0x240BA2C4 1 > $DCC_PATH/config
    echo 0x240A801C 2 > $DCC_PATH/config
    echo 0x240A8038 3 > $DCC_PATH/config
    echo 0x240A8058 5 > $DCC_PATH/config
    echo 0x240A8074 4 > $DCC_PATH/config
    echo 0x240A80A8  > $DCC_PATH/config
    echo 0x240A80B8  > $DCC_PATH/config
    echo 0x240A80EC 5 > $DCC_PATH/config
    echo 0x240A8140  > $DCC_PATH/config
    echo 0x240A8164 2 > $DCC_PATH/config
    echo 0x240A81C4 2 > $DCC_PATH/config
    echo 0x240A81DC 2 > $DCC_PATH/config
    echo 0x240A844C  > $DCC_PATH/config
    echo 0x240A845C  > $DCC_PATH/config
    echo 0x240A84C8 27 > $DCC_PATH/config
    echo 0x240A9000 2 > $DCC_PATH/config
    echo 0x240A9010 2 > $DCC_PATH/config
    echo 0x240A9020 3 > $DCC_PATH/config
    echo 0x240A9034 2 > $DCC_PATH/config
    echo 0x240A9130 3 > $DCC_PATH/config
    echo 0x240A9140 18 > $DCC_PATH/config
    echo 0x240A91AC 6 > $DCC_PATH/config
    echo 0x240A91C8  > $DCC_PATH/config
    echo 0x240A920C  > $DCC_PATH/config
    echo 0x240A9220 2 > $DCC_PATH/config
    echo 0x240A9264  > $DCC_PATH/config
    echo 0x240A9294 7 > $DCC_PATH/config
    echo 0x240A92B8  > $DCC_PATH/config
    echo 0x240A92F8  > $DCC_PATH/config
    # echo 0x24800004  > $DCC_PATH/config
    # echo 0x24801004  > $DCC_PATH/config
    # echo 0x24802004  > $DCC_PATH/config
    # echo 0x24803004  > $DCC_PATH/config
    # echo 0x24804004  > $DCC_PATH/config
    # echo 0x24805004  > $DCC_PATH/config
    # echo 0x24806004  > $DCC_PATH/config
    # echo 0x24807004  > $DCC_PATH/config
    # echo 0x24808004  > $DCC_PATH/config
    # echo 0x24809004  > $DCC_PATH/config
    # echo 0x2480a004  > $DCC_PATH/config
    # echo 0x2480b004  > $DCC_PATH/config
    # echo 0x2480c004  > $DCC_PATH/config
    # echo 0x2480d004  > $DCC_PATH/config
    # echo 0x2480e004  > $DCC_PATH/config
    # echo 0x2480f004  > $DCC_PATH/config
    # echo 0x24810004  > $DCC_PATH/config
    # echo 0x24811004  > $DCC_PATH/config
    # echo 0x24812004  > $DCC_PATH/config
    # echo 0x24813004  > $DCC_PATH/config
    # echo 0x24814004  > $DCC_PATH/config
    # echo 0x24815004  > $DCC_PATH/config
    # echo 0x24816004  > $DCC_PATH/config
    # echo 0x24817004  > $DCC_PATH/config
    # echo 0x24818004  > $DCC_PATH/config
    # echo 0x24819004  > $DCC_PATH/config
    # echo 0x2481a004  > $DCC_PATH/config
    # echo 0x2481b004  > $DCC_PATH/config
    # echo 0x2481c004  > $DCC_PATH/config
    # echo 0x2481d004  > $DCC_PATH/config
    # echo 0x2481e004  > $DCC_PATH/config
    # echo 0x2481f004  > $DCC_PATH/config
    # echo 0x24820004  > $DCC_PATH/config
    # echo 0x24821004  > $DCC_PATH/config
    # echo 0x24822004  > $DCC_PATH/config
    # echo 0x24823004  > $DCC_PATH/config
    echo 0x24BC0610 11 > $DCC_PATH/config
    echo 0x24BC0640 2 > $DCC_PATH/config
    echo 0x24BC06A0  > $DCC_PATH/config
    echo 0x24FC0610 11 > $DCC_PATH/config
    echo 0x24FC0640 2 > $DCC_PATH/config
    echo 0x24FC06A0  > $DCC_PATH/config
    echo 0x25BC0610 11 > $DCC_PATH/config
    echo 0x25BC0640 2 > $DCC_PATH/config
    echo 0x25BC06A0  > $DCC_PATH/config
    echo 0x25FC0610 11 > $DCC_PATH/config
    echo 0x25FC0640 2 > $DCC_PATH/config
    echo 0x25FC06A0  > $DCC_PATH/config
    # echo 0x24843350 1 > $DCC_PATH/config
    # echo 0x24843354 1 > $DCC_PATH/config
    # echo 0x248433F4 1 > $DCC_PATH/config
    # echo 0x248433F8 1 > $DCC_PATH/config
    # echo 0x248433FC 1 > $DCC_PATH/config
    # echo 0x24843400 1 > $DCC_PATH/config
    # echo 0x24843404 1 > $DCC_PATH/config
    # echo 0x24843408 1 > $DCC_PATH/config
    # echo 0x2484340C 1 > $DCC_PATH/config
    # echo 0x24843410 1 > $DCC_PATH/config
    # echo 0x24843414 1 > $DCC_PATH/config
    # echo 0x24843418 1 > $DCC_PATH/config
    # echo 0x2484341C 1 > $DCC_PATH/config
    # echo 0x248434C0 1 > $DCC_PATH/config
    # echo 0x248434C4 1 > $DCC_PATH/config
    # echo 0x248434C8 1 > $DCC_PATH/config
    # echo 0x248434CC 1 > $DCC_PATH/config
    # echo 0x248434D0 1 > $DCC_PATH/config
    # echo 0x248434D4 1 > $DCC_PATH/config
    # echo 0x24843600 1 > $DCC_PATH/config
    # echo 0x2484360C 1 > $DCC_PATH/config
    # echo 0x24845040 1 > $DCC_PATH/config
    # echo 0x24845048 1 > $DCC_PATH/config
    # echo 0x24845050 1 > $DCC_PATH/config
    # echo 0x24845058 1 > $DCC_PATH/config
    # echo 0x24845060 1 > $DCC_PATH/config
    # echo 0x24845068 1 > $DCC_PATH/config
    # echo 0x24845070 1 > $DCC_PATH/config
    # echo 0x24845074 1 > $DCC_PATH/config
    # echo 0x24845078 1 > $DCC_PATH/config
    # echo 0x2484507C 1 > $DCC_PATH/config
    # echo 0x24845090 1 > $DCC_PATH/config
    # echo 0x24845094 1 > $DCC_PATH/config
    # echo 0x24845098 1 > $DCC_PATH/config
    # echo 0x2484509C 1 > $DCC_PATH/config
    # echo 0x248450A0 1 > $DCC_PATH/config
    # echo 0x248450A4 1 > $DCC_PATH/config
    # echo 0x248450A8 1 > $DCC_PATH/config
    # echo 0x248450AC 1 > $DCC_PATH/config
    # echo 0x248450B0 1 > $DCC_PATH/config
    # echo 0x248450B4 1 > $DCC_PATH/config
    # echo 0x248450B8 1 > $DCC_PATH/config
    # echo 0x248450BC 1 > $DCC_PATH/config
    # echo 0x248450C0 1 > $DCC_PATH/config
    # echo 0x248450C4 1 > $DCC_PATH/config
    # echo 0x248450CC 1 > $DCC_PATH/config
    # echo 0x248450D0 1 > $DCC_PATH/config
    # echo 0x24845240 1 > $DCC_PATH/config
    # echo 0x248452A0 1 > $DCC_PATH/config
    # echo 0x24845300 1 > $DCC_PATH/config
    # echo 0x24845310 1 > $DCC_PATH/config
    # echo 0x24845320 1 > $DCC_PATH/config
    # echo 0x24845330 1 > $DCC_PATH/config
    # echo 0x24845334 1 > $DCC_PATH/config
    # echo 0x24845338 1 > $DCC_PATH/config
    # echo 0x24847404 1 > $DCC_PATH/config
    # echo 0x2484740C 1 > $DCC_PATH/config
    # echo 0x24847410 1 > $DCC_PATH/config
    # echo 0x24847414 1 > $DCC_PATH/config
    # echo 0x24847448 1 > $DCC_PATH/config
    # echo 0x24847450 1 > $DCC_PATH/config
    # echo 0x24847458 1 > $DCC_PATH/config
    # echo 0x2484745C 1 > $DCC_PATH/config
    # echo 0x24847600 1 > $DCC_PATH/config
    # echo 0x24849000 1 > $DCC_PATH/config
    # echo 0x24849010 1 > $DCC_PATH/config
    echo 0x2487C000 1 > $DCC_PATH/config
    # echo 0x2487C01C 1 > $DCC_PATH/config
    # echo 0x2487C020 1 > $DCC_PATH/config
    # echo 0x2487C024 1 > $DCC_PATH/config
    # echo 0x2487C030 1 > $DCC_PATH/config
    # echo 0x2487C034 1 > $DCC_PATH/config
    # echo 0x2487C038 1 > $DCC_PATH/config
    # echo 0x2487C03C 1 > $DCC_PATH/config
    # echo 0x2487C040 1 > $DCC_PATH/config
    # echo 0x2487C044 1 > $DCC_PATH/config
    # echo 0x2487C048 1 > $DCC_PATH/config
    # echo 0x2487C04C 1 > $DCC_PATH/config
    # echo 0x2487C054 1 > $DCC_PATH/config
    # echo 0x2487C058 1 > $DCC_PATH/config
    # echo 0x2487C078 1 > $DCC_PATH/config
    # echo 0x2487C108 1 > $DCC_PATH/config
    # echo 0x2487C10C 1 > $DCC_PATH/config
    # echo 0x2487C110 1 > $DCC_PATH/config
    # echo 0x2487C114 1 > $DCC_PATH/config
    # echo 0x2487C118 1 > $DCC_PATH/config
    # echo 0x2487C11C 1 > $DCC_PATH/config
    # echo 0x2487C120 1 > $DCC_PATH/config
    # echo 0x2487C124 1 > $DCC_PATH/config
    # echo 0x2487C128 1 > $DCC_PATH/config
    # echo 0x2487C20C 1 > $DCC_PATH/config
    # echo 0x2487C210 1 > $DCC_PATH/config
    # echo 0x2487C214 1 > $DCC_PATH/config
    # echo 0x248A600C 1 > $DCC_PATH/config
    # echo 0x248A6010 1 > $DCC_PATH/config
    # echo 0x248A6014 1 > $DCC_PATH/config
    # echo 0x248A6018 1 > $DCC_PATH/config
    # echo 0x248A6020 1 > $DCC_PATH/config
    # echo 0x248A6024 1 > $DCC_PATH/config
    # echo 0x248A6028 1 > $DCC_PATH/config
    # echo 0x248A6034 1 > $DCC_PATH/config
    # echo 0x248A6038 1 > $DCC_PATH/config
    # echo 0x248A6040 1 > $DCC_PATH/config
    # echo 0x248A6050 1 > $DCC_PATH/config
    # echo 0x248A6058 1 > $DCC_PATH/config
    # echo 0x248A6060 1 > $DCC_PATH/config
    # echo 0x248A6064 1 > $DCC_PATH/config
    # echo 0x248A6068 1 > $DCC_PATH/config
    # echo 0x248A606C 1 > $DCC_PATH/config
    # echo 0x248A7020 1 > $DCC_PATH/config
    # echo 0x248A7030 1 > $DCC_PATH/config
    # echo 0x248A7034 1 > $DCC_PATH/config
    # echo 0x248A7078 1 > $DCC_PATH/config
    # echo 0x248A707C 1 > $DCC_PATH/config
    # echo 0x248a7080 1 > $DCC_PATH/config
    # echo 0x248A7084 1 > $DCC_PATH/config
    # echo 0x248a708c 1 > $DCC_PATH/config
    # echo 0x248A7090 1 > $DCC_PATH/config
    # echo 0x248A7094 1 > $DCC_PATH/config
    # echo 0x248A7098 1 > $DCC_PATH/config
    # echo 0x248A709C 1 > $DCC_PATH/config
    # echo 0x248A70A0 1 > $DCC_PATH/config
    # echo 0x248E002C 1 > $DCC_PATH/config
    # echo 0x248E009C 1 > $DCC_PATH/config
    # echo 0x248E00A0 1 > $DCC_PATH/config
    # echo 0x248E00A8 1 > $DCC_PATH/config
    # echo 0x248E00AC 1 > $DCC_PATH/config
    # echo 0x248E00B0 1 > $DCC_PATH/config
    # echo 0x248E00B8 1 > $DCC_PATH/config
    # echo 0x248E00C0 1 > $DCC_PATH/config
    # echo 0x248E00C4 1 > $DCC_PATH/config
    # echo 0x248E00C8 1 > $DCC_PATH/config
    # echo 0x248E00CC 1 > $DCC_PATH/config
    # echo 0x248E00D0 1 > $DCC_PATH/config
    # echo 0x248E00D4 1 > $DCC_PATH/config
    # echo 0x248E00D8 1 > $DCC_PATH/config
    # echo 0x248E00E0 1 > $DCC_PATH/config
    # echo 0x248E00E8 1 > $DCC_PATH/config
    # echo 0x248E00F0 1 > $DCC_PATH/config
    # echo 0x248E00F8 1 > $DCC_PATH/config
    # echo 0x248E0100 1 > $DCC_PATH/config
    # echo 0x248E0108 1 > $DCC_PATH/config
    # echo 0x248E0110 1 > $DCC_PATH/config
    # echo 0x248E0118 1 > $DCC_PATH/config
    # echo 0x248E0120 1 > $DCC_PATH/config
    # echo 0x248E0128 1 > $DCC_PATH/config
    # echo 0x248E0150 1 > $DCC_PATH/config
    # echo 0x248E0154 1 > $DCC_PATH/config
    # echo 0x248E0158 1 > $DCC_PATH/config
    # echo 0x248E015C 1 > $DCC_PATH/config
    # echo 0x248E0164 1 > $DCC_PATH/config
    # echo 0x248E01E8 1 > $DCC_PATH/config
    # echo 0x248E1010 1 > $DCC_PATH/config
    # echo 0x248E1060 1 > $DCC_PATH/config
    # echo 0x248E1064 1 > $DCC_PATH/config
    # echo 0x248E1068 1 > $DCC_PATH/config
    # echo 0x248E1070 1 > $DCC_PATH/config
    # echo 0x248E1084 1 > $DCC_PATH/config
    # echo 0x248E1088 1 > $DCC_PATH/config
    # echo 0x248E108C 1 > $DCC_PATH/config
    # echo 0x248E3004 1 > $DCC_PATH/config
    # echo 0x248E300C 1 > $DCC_PATH/config
    # echo 0x248E4004 1 > $DCC_PATH/config
    # echo 0x248E4010 1 > $DCC_PATH/config
    # echo 0x248E4014 1 > $DCC_PATH/config
    # echo 0x248E4024 1 > $DCC_PATH/config
    # echo 0x248E4028 1 > $DCC_PATH/config
    # echo 0x248E4038 1 > $DCC_PATH/config
    # echo 0x248E403C 1 > $DCC_PATH/config
    # echo 0x248E600C 1 > $DCC_PATH/config
    # echo 0x248E6010 1 > $DCC_PATH/config
    # echo 0x248E6014 1 > $DCC_PATH/config
    # echo 0x248E6018 1 > $DCC_PATH/config
    # echo 0x248E601C 1 > $DCC_PATH/config
    # echo 0x248E700C 1 > $DCC_PATH/config
    # echo 0x248E7010 1 > $DCC_PATH/config
    # echo 0x248E7014 1 > $DCC_PATH/config
    # echo 0x248E7018 1 > $DCC_PATH/config
    # echo 0x248E701C 1 > $DCC_PATH/config
    # echo 0x248E9004 1 > $DCC_PATH/config
    # echo 0x248E9010 1 > $DCC_PATH/config
    # echo 0x248E9014 1 > $DCC_PATH/config
    # echo 0x248E9018 1 > $DCC_PATH/config
    # echo 0x248E9020 1 > $DCC_PATH/config
    # echo 0x248E9024 1 > $DCC_PATH/config
    # echo 0x248E9028 1 > $DCC_PATH/config
    # echo 0x248E9030 1 > $DCC_PATH/config
    # echo 0x248E9034 1 > $DCC_PATH/config
    # echo 0x248E9038 1 > $DCC_PATH/config
    # echo 0x248E9040 1 > $DCC_PATH/config
    # echo 0x248E9044 1 > $DCC_PATH/config
    # echo 0x248E9048 1 > $DCC_PATH/config
    # echo 0x248E9050 1 > $DCC_PATH/config
    # echo 0x248E9054 1 > $DCC_PATH/config
    # echo 0x248E9058 1 > $DCC_PATH/config
    # echo 0x248EA004 1 > $DCC_PATH/config
    # echo 0x248EA010 1 > $DCC_PATH/config
    # echo 0x248EA014 1 > $DCC_PATH/config
    # echo 0x248EA018 1 > $DCC_PATH/config
    # echo 0x248EA020 1 > $DCC_PATH/config
    # echo 0x248EA024 1 > $DCC_PATH/config
    # echo 0x248EA028 1 > $DCC_PATH/config
    # echo 0x248EA030 1 > $DCC_PATH/config
    # echo 0x248EA034 1 > $DCC_PATH/config
    # echo 0x248EA038 1 > $DCC_PATH/config
    # echo 0x248EA040 1 > $DCC_PATH/config
    # echo 0x248EA044 1 > $DCC_PATH/config
    # echo 0x248EA048 1 > $DCC_PATH/config
    # echo 0x248EA050 1 > $DCC_PATH/config
    # echo 0x248EA054 1 > $DCC_PATH/config
    # echo 0x248EA058 1 > $DCC_PATH/config
    echo 0x248F001C 1 > $DCC_PATH/config
    echo 0x248F0050 1 > $DCC_PATH/config
    echo 0x248F0058 1 > $DCC_PATH/config
    # echo 0x24c00004 1 > $DCC_PATH/config
    # echo 0x24c01004 1 > $DCC_PATH/config
    # echo 0x24c02004 1 > $DCC_PATH/config
    # echo 0x24c03004 1 > $DCC_PATH/config
    # echo 0x24c04004 1 > $DCC_PATH/config
    # echo 0x24c05004 1 > $DCC_PATH/config
    # echo 0x24c06004 1 > $DCC_PATH/config
    # echo 0x24c07004 1 > $DCC_PATH/config
    # echo 0x24c08004 1 > $DCC_PATH/config
    # echo 0x24c09004 1 > $DCC_PATH/config
    # echo 0x24c0a004 1 > $DCC_PATH/config
    # echo 0x24c0b004 1 > $DCC_PATH/config
    # echo 0x24c0c004 1 > $DCC_PATH/config
    # echo 0x24c0d004 1 > $DCC_PATH/config
    # echo 0x24c0e004 1 > $DCC_PATH/config
    # echo 0x24c0f004 1 > $DCC_PATH/config
    # echo 0x24c10004 1 > $DCC_PATH/config
    # echo 0x24c11004 1 > $DCC_PATH/config
    # echo 0x24c12004 1 > $DCC_PATH/config
    # echo 0x24c13004 1 > $DCC_PATH/config
    # echo 0x24c14004 1 > $DCC_PATH/config
    # echo 0x24c15004 1 > $DCC_PATH/config
    # echo 0x24c16004 1 > $DCC_PATH/config
    # echo 0x24c17004 1 > $DCC_PATH/config
    # echo 0x24c18004 1 > $DCC_PATH/config
    # echo 0x24c19004 1 > $DCC_PATH/config
    # echo 0x24c1a004 1 > $DCC_PATH/config
    # echo 0x24c1b004 1 > $DCC_PATH/config
    # echo 0x24c1c004 1 > $DCC_PATH/config
    # echo 0x24c1d004 1 > $DCC_PATH/config
    # echo 0x24c1e004 1 > $DCC_PATH/config
    # echo 0x24c1f004 1 > $DCC_PATH/config
    # echo 0x24c20004 1 > $DCC_PATH/config
    # echo 0x24c21004 1 > $DCC_PATH/config
    # echo 0x24c22004 1 > $DCC_PATH/config
    # echo 0x24c23004 1 > $DCC_PATH/config
    # echo 0x24C43350 1 > $DCC_PATH/config
    # echo 0x24C43354 1 > $DCC_PATH/config
    # echo 0x24C433F4 1 > $DCC_PATH/config
    # echo 0x24C433F8 1 > $DCC_PATH/config
    # echo 0x24C433FC 1 > $DCC_PATH/config
    # echo 0x24C43400 1 > $DCC_PATH/config
    # echo 0x24C43404 1 > $DCC_PATH/config
    # echo 0x24C43408 1 > $DCC_PATH/config
    # echo 0x24C4340C 1 > $DCC_PATH/config
    # echo 0x24C43410 1 > $DCC_PATH/config
    # echo 0x24C43414 1 > $DCC_PATH/config
    # echo 0x24C43418 1 > $DCC_PATH/config
    # echo 0x24C4341C 1 > $DCC_PATH/config
    # echo 0x24C434C0 1 > $DCC_PATH/config
    # echo 0x24C434C4 1 > $DCC_PATH/config
    # echo 0x24C434C8 1 > $DCC_PATH/config
    # echo 0x24C434CC 1 > $DCC_PATH/config
    # echo 0x24C434D0 1 > $DCC_PATH/config
    # echo 0x24C434D4 1 > $DCC_PATH/config
    # echo 0x24C43600 1 > $DCC_PATH/config
    # echo 0x24C4360C 1 > $DCC_PATH/config
    # echo 0x24C45040 1 > $DCC_PATH/config
    # echo 0x24C45048 1 > $DCC_PATH/config
    # echo 0x24C45050 1 > $DCC_PATH/config
    # echo 0x24C45058 1 > $DCC_PATH/config
    # echo 0x24C45060 1 > $DCC_PATH/config
    # echo 0x24C45068 1 > $DCC_PATH/config
    # echo 0x24C45070 1 > $DCC_PATH/config
    # echo 0x24C45074 1 > $DCC_PATH/config
    # echo 0x24C45078 1 > $DCC_PATH/config
    # echo 0x24C4507C 1 > $DCC_PATH/config
    # echo 0x24C45090 1 > $DCC_PATH/config
    # echo 0x24C45094 1 > $DCC_PATH/config
    # echo 0x24C45098 1 > $DCC_PATH/config
    # echo 0x24C4509C 1 > $DCC_PATH/config
    # echo 0x24C450A0 1 > $DCC_PATH/config
    # echo 0x24C450A4 1 > $DCC_PATH/config
    # echo 0x24C450A8 1 > $DCC_PATH/config
    # echo 0x24C450AC 1 > $DCC_PATH/config
    # echo 0x24C450B0 1 > $DCC_PATH/config
    # echo 0x24C450B4 1 > $DCC_PATH/config
    # echo 0x24C450B8 1 > $DCC_PATH/config
    # echo 0x24C450BC 1 > $DCC_PATH/config
    # echo 0x24C450C0 1 > $DCC_PATH/config
    # echo 0x24C450C4 1 > $DCC_PATH/config
    # echo 0x24C450CC 1 > $DCC_PATH/config
    # echo 0x24C450D0 1 > $DCC_PATH/config
    # echo 0x24C45240 1 > $DCC_PATH/config
    # echo 0x24C452A0 1 > $DCC_PATH/config
    # echo 0x24C45300 1 > $DCC_PATH/config
    # echo 0x24C45310 1 > $DCC_PATH/config
    # echo 0x24C45320 1 > $DCC_PATH/config
    # echo 0x24C45330 1 > $DCC_PATH/config
    # echo 0x24C45334 1 > $DCC_PATH/config
    # echo 0x24C45338 1 > $DCC_PATH/config
    # echo 0x24C47404 1 > $DCC_PATH/config
    # echo 0x24C4740C 1 > $DCC_PATH/config
    # echo 0x24C47410 1 > $DCC_PATH/config
    # echo 0x24C47414 1 > $DCC_PATH/config
    # echo 0x24C47448 1 > $DCC_PATH/config
    # echo 0x24C47450 1 > $DCC_PATH/config
    # echo 0x24C47458 1 > $DCC_PATH/config
    # echo 0x24C4745C 1 > $DCC_PATH/config
    # echo 0x24C47600 1 > $DCC_PATH/config
    # echo 0x24C49000 1 > $DCC_PATH/config
    # echo 0x24C49010 1 > $DCC_PATH/config
    echo 0x24C7C000  > $DCC_PATH/config
    echo 0x24C7C01C 3 > $DCC_PATH/config
    echo 0x24C7C030 8 > $DCC_PATH/config
    echo 0x24C7C054 2 > $DCC_PATH/config
    echo 0x24C7C078  > $DCC_PATH/config
    echo 0x24C7C108 9 > $DCC_PATH/config
    echo 0x24C7C20C 3 > $DCC_PATH/config
    # echo 0x24CA600C 1 > $DCC_PATH/config
    # echo 0x24CA6010 1 > $DCC_PATH/config
    # echo 0x24CA6014 1 > $DCC_PATH/config
    # echo 0x24CA6018 1 > $DCC_PATH/config
    # echo 0x24CA6020 1 > $DCC_PATH/config
    # echo 0x24CA6024 1 > $DCC_PATH/config
    # echo 0x24CA6028 1 > $DCC_PATH/config
    # echo 0x24CA6034 1 > $DCC_PATH/config
    # echo 0x24CA6038 1 > $DCC_PATH/config
    # echo 0x24CA6040 1 > $DCC_PATH/config
    # echo 0x24CA6050 1 > $DCC_PATH/config
    # echo 0x24CA6058 1 > $DCC_PATH/config
    # echo 0x24CA6060 1 > $DCC_PATH/config
    # echo 0x24CA6064 1 > $DCC_PATH/config
    # echo 0x24CA6068 1 > $DCC_PATH/config
    # echo 0x24CA606C 1 > $DCC_PATH/config
    # echo 0x24CA7020 1 > $DCC_PATH/config
    # echo 0x24CA7030 1 > $DCC_PATH/config
    # echo 0x24CA7034 1 > $DCC_PATH/config
    # echo 0x24CA7078 1 > $DCC_PATH/config
    # echo 0x24CA707C 1 > $DCC_PATH/config
    # echo 0x24ca7080 1 > $DCC_PATH/config
    # echo 0x24CA7084 1 > $DCC_PATH/config
    # echo 0x24ca708c 1 > $DCC_PATH/config
    # echo 0x24CA7090 1 > $DCC_PATH/config
    # echo 0x24CA7094 1 > $DCC_PATH/config
    # echo 0x24CA7098 1 > $DCC_PATH/config
    # echo 0x24CA709C 1 > $DCC_PATH/config
    # echo 0x24CA70A0 1 > $DCC_PATH/config
    # echo 0x24CE002C 1 > $DCC_PATH/config
    # echo 0x24CE009C 1 > $DCC_PATH/config
    # echo 0x24CE00A0 1 > $DCC_PATH/config
    # echo 0x24CE00A8 1 > $DCC_PATH/config
    # echo 0x24CE00AC 1 > $DCC_PATH/config
    # echo 0x24CE00B0 1 > $DCC_PATH/config
    # echo 0x24CE00B8 1 > $DCC_PATH/config
    # echo 0x24CE00C0 1 > $DCC_PATH/config
    # echo 0x24CE00C4 1 > $DCC_PATH/config
    # echo 0x24CE00C8 1 > $DCC_PATH/config
    # echo 0x24CE00CC 1 > $DCC_PATH/config
    # echo 0x24CE00D0 1 > $DCC_PATH/config
    # echo 0x24CE00D4 1 > $DCC_PATH/config
    # echo 0x24CE00D8 1 > $DCC_PATH/config
    # echo 0x24CE00E0 1 > $DCC_PATH/config
    # echo 0x24CE00E8 1 > $DCC_PATH/config
    # echo 0x24CE00F0 1 > $DCC_PATH/config
    # echo 0x24CE00F8 1 > $DCC_PATH/config
    # echo 0x24CE0100 1 > $DCC_PATH/config
    # echo 0x24CE0108 1 > $DCC_PATH/config
    # echo 0x24CE0110 1 > $DCC_PATH/config
    # echo 0x24CE0118 1 > $DCC_PATH/config
    # echo 0x24CE0120 1 > $DCC_PATH/config
    # echo 0x24CE0128 1 > $DCC_PATH/config
    # echo 0x24CE0150 1 > $DCC_PATH/config
    # echo 0x24CE0154 1 > $DCC_PATH/config
    # echo 0x24CE0158 1 > $DCC_PATH/config
    # echo 0x24CE015C 1 > $DCC_PATH/config
    # echo 0x24CE0164 1 > $DCC_PATH/config
    # echo 0x24CE01E8 1 > $DCC_PATH/config
    echo 0x24CE1010  > $DCC_PATH/config
    echo 0x24CE1060 3 > $DCC_PATH/config
    echo 0x24CE1070  > $DCC_PATH/config
    echo 0x24CE1084 3 > $DCC_PATH/config
    echo 0x24CE3004  > $DCC_PATH/config
    echo 0x24CE300C  > $DCC_PATH/config
    echo 0x24CE4004  > $DCC_PATH/config
    echo 0x24CE4010 2 > $DCC_PATH/config
    echo 0x24CE4024 2 > $DCC_PATH/config
    echo 0x24CE4038 2 > $DCC_PATH/config
    # echo 0x24CE600C 1 > $DCC_PATH/config
    # echo 0x24CE6010 1 > $DCC_PATH/config
    # echo 0x24CE6014 1 > $DCC_PATH/config
    # echo 0x24CE6018 1 > $DCC_PATH/config
    # echo 0x24CE601C 1 > $DCC_PATH/config
    # echo 0x24CE700C 1 > $DCC_PATH/config
    # echo 0x24CE7010 1 > $DCC_PATH/config
    # echo 0x24CE7014 1 > $DCC_PATH/config
    # echo 0x24CE7018 1 > $DCC_PATH/config
    # echo 0x24CE701C 1 > $DCC_PATH/config
    echo 0x24CE9004  > $DCC_PATH/config
    echo 0x24CE9010 3 > $DCC_PATH/config
    echo 0x24CE9020 3 > $DCC_PATH/config
    echo 0x24CE9030 3 > $DCC_PATH/config
    echo 0x24CE9040 3 > $DCC_PATH/config
    echo 0x24CE9050 3 > $DCC_PATH/config
    # echo 0x24CEA004 1 > $DCC_PATH/config
    # echo 0x24CEA010 1 > $DCC_PATH/config
    # echo 0x24CEA014 1 > $DCC_PATH/config
    # echo 0x24CEA018 1 > $DCC_PATH/config
    # echo 0x24CEA020 1 > $DCC_PATH/config
    # echo 0x24CEA024 1 > $DCC_PATH/config
    # echo 0x24CEA028 1 > $DCC_PATH/config
    # echo 0x24CEA030 1 > $DCC_PATH/config
    # echo 0x24CEA034 1 > $DCC_PATH/config
    # echo 0x24CEA038 1 > $DCC_PATH/config
    # echo 0x24CEA040 1 > $DCC_PATH/config
    # echo 0x24CEA044 1 > $DCC_PATH/config
    # echo 0x24CEA048 1 > $DCC_PATH/config
    # echo 0x24CEA050 1 > $DCC_PATH/config
    # echo 0x24CEA054 1 > $DCC_PATH/config
    # echo 0x24CEA058 1 > $DCC_PATH/config
    # echo 0x24CF001C 1 > $DCC_PATH/config
    # echo 0x24CF0050 1 > $DCC_PATH/config
    # echo 0x24CF0058 1 > $DCC_PATH/config
    # echo 0x25800004 1 > $DCC_PATH/config
    # echo 0x25801004 1 > $DCC_PATH/config
    # echo 0x25802004 1 > $DCC_PATH/config
    # echo 0x25803004 1 > $DCC_PATH/config
    # echo 0x25804004 1 > $DCC_PATH/config
    # echo 0x25805004 1 > $DCC_PATH/config
    # echo 0x25806004 1 > $DCC_PATH/config
    # echo 0x25807004 1 > $DCC_PATH/config
    # echo 0x25808004 1 > $DCC_PATH/config
    # echo 0x25809004 1 > $DCC_PATH/config
    # echo 0x2580a004 1 > $DCC_PATH/config
    # echo 0x2580b004 1 > $DCC_PATH/config
    # echo 0x2580c004 1 > $DCC_PATH/config
    # echo 0x2580d004 1 > $DCC_PATH/config
    # echo 0x2580e004 1 > $DCC_PATH/config
    # echo 0x2580f004 1 > $DCC_PATH/config
    # echo 0x25810004 1 > $DCC_PATH/config
    # echo 0x25811004 1 > $DCC_PATH/config
    # echo 0x25812004 1 > $DCC_PATH/config
    # echo 0x25813004 1 > $DCC_PATH/config
    # echo 0x25814004 1 > $DCC_PATH/config
    # echo 0x25815004 1 > $DCC_PATH/config
    # echo 0x25816004 1 > $DCC_PATH/config
    # echo 0x25817004 1 > $DCC_PATH/config
    # echo 0x25818004 1 > $DCC_PATH/config
    # echo 0x25819004 1 > $DCC_PATH/config
    # echo 0x2581a004 1 > $DCC_PATH/config
    # echo 0x2581b004 1 > $DCC_PATH/config
    # echo 0x2581c004 1 > $DCC_PATH/config
    # echo 0x2581d004 1 > $DCC_PATH/config
    # echo 0x2581e004 1 > $DCC_PATH/config
    # echo 0x2581f004 1 > $DCC_PATH/config
    # echo 0x25820004 1 > $DCC_PATH/config
    # echo 0x25821004 1 > $DCC_PATH/config
    # echo 0x25822004 1 > $DCC_PATH/config
    # echo 0x25823004 1 > $DCC_PATH/config
    # echo 0x25843350 1 > $DCC_PATH/config
    # echo 0x25843354 1 > $DCC_PATH/config
    # echo 0x258433F4 1 > $DCC_PATH/config
    # echo 0x258433F8 1 > $DCC_PATH/config
    # echo 0x258433FC 1 > $DCC_PATH/config
    # echo 0x25843400 1 > $DCC_PATH/config
    # echo 0x25843404 1 > $DCC_PATH/config
    # echo 0x25843408 1 > $DCC_PATH/config
    # echo 0x2584340C 1 > $DCC_PATH/config
    # echo 0x25843410 1 > $DCC_PATH/config
    # echo 0x25843414 1 > $DCC_PATH/config
    # echo 0x25843418 1 > $DCC_PATH/config
    # echo 0x2584341C 1 > $DCC_PATH/config
    # echo 0x258434C0 1 > $DCC_PATH/config
    # echo 0x258434C4 1 > $DCC_PATH/config
    # echo 0x258434C8 1 > $DCC_PATH/config
    # echo 0x258434CC 1 > $DCC_PATH/config
    # echo 0x258434D0 1 > $DCC_PATH/config
    # echo 0x258434D4 1 > $DCC_PATH/config
    # echo 0x25843600 1 > $DCC_PATH/config
    # echo 0x2584360C 1 > $DCC_PATH/config
    # echo 0x25845040 1 > $DCC_PATH/config
    # echo 0x25845048 1 > $DCC_PATH/config
    # echo 0x25845050 1 > $DCC_PATH/config
    # echo 0x25845058 1 > $DCC_PATH/config
    # echo 0x25845060 1 > $DCC_PATH/config
    # echo 0x25845068 1 > $DCC_PATH/config
    # echo 0x25845070 1 > $DCC_PATH/config
    # echo 0x25845074 1 > $DCC_PATH/config
    # echo 0x25845078 1 > $DCC_PATH/config
    # echo 0x2584507C 1 > $DCC_PATH/config
    # echo 0x25845090 1 > $DCC_PATH/config
    # echo 0x25845094 1 > $DCC_PATH/config
    # echo 0x25845098 1 > $DCC_PATH/config
    # echo 0x2584509C 1 > $DCC_PATH/config
    # echo 0x258450A0 1 > $DCC_PATH/config
    # echo 0x258450A4 1 > $DCC_PATH/config
    # echo 0x258450A8 1 > $DCC_PATH/config
    # echo 0x258450AC 1 > $DCC_PATH/config
    # echo 0x258450B0 1 > $DCC_PATH/config
    # echo 0x258450B4 1 > $DCC_PATH/config
    # echo 0x258450B8 1 > $DCC_PATH/config
    # echo 0x258450BC 1 > $DCC_PATH/config
    # echo 0x258450C0 1 > $DCC_PATH/config
    # echo 0x258450C4 1 > $DCC_PATH/config
    # echo 0x258450CC 1 > $DCC_PATH/config
    # echo 0x258450D0 1 > $DCC_PATH/config
    # echo 0x25845240 1 > $DCC_PATH/config
    # echo 0x258452A0 1 > $DCC_PATH/config
    # echo 0x25845300 1 > $DCC_PATH/config
    # echo 0x25845310 1 > $DCC_PATH/config
    # echo 0x25845320 1 > $DCC_PATH/config
    # echo 0x25845330 1 > $DCC_PATH/config
    # echo 0x25845334 1 > $DCC_PATH/config
    # echo 0x25845338 1 > $DCC_PATH/config
    # echo 0x25847404 1 > $DCC_PATH/config
    # echo 0x2584740C 1 > $DCC_PATH/config
    # echo 0x25847410 1 > $DCC_PATH/config
    # echo 0x25847414 1 > $DCC_PATH/config
    # echo 0x25847448 1 > $DCC_PATH/config
    # echo 0x25847450 1 > $DCC_PATH/config
    # echo 0x25847458 1 > $DCC_PATH/config
    # echo 0x2584745C 1 > $DCC_PATH/config
    # echo 0x25847600 1 > $DCC_PATH/config
    # echo 0x25849000 1 > $DCC_PATH/config
    # echo 0x25849010 1 > $DCC_PATH/config
    echo 0x2587C000  > $DCC_PATH/config
    echo 0x2587C01C 3 > $DCC_PATH/config
    echo 0x2587C030 8 > $DCC_PATH/config
    echo 0x2587C054 2 > $DCC_PATH/config
    echo 0x2587C078  > $DCC_PATH/config
    echo 0x2587C108 9 > $DCC_PATH/config
    echo 0x2587C20C 3 > $DCC_PATH/config
    # echo 0x258A600C 1 > $DCC_PATH/config
    # echo 0x258A6010 1 > $DCC_PATH/config
    # echo 0x258A6014 1 > $DCC_PATH/config
    # echo 0x258A6018 1 > $DCC_PATH/config
    # echo 0x258A6020 1 > $DCC_PATH/config
    # echo 0x258A6024 1 > $DCC_PATH/config
    # echo 0x258A6028 1 > $DCC_PATH/config
    # echo 0x258A6034 1 > $DCC_PATH/config
    # echo 0x258A6038 1 > $DCC_PATH/config
    # echo 0x258A6040 1 > $DCC_PATH/config
    # echo 0x258A6050 1 > $DCC_PATH/config
    # echo 0x258A6058 1 > $DCC_PATH/config
    # echo 0x258A6060 1 > $DCC_PATH/config
    # echo 0x258A6064 1 > $DCC_PATH/config
    # echo 0x258A6068 1 > $DCC_PATH/config
    # echo 0x258A606C 1 > $DCC_PATH/config
    # echo 0x258A7020 1 > $DCC_PATH/config
    # echo 0x258A7030 1 > $DCC_PATH/config
    # echo 0x258A7034 1 > $DCC_PATH/config
    # echo 0x258A7078 1 > $DCC_PATH/config
    # echo 0x258A707C 1 > $DCC_PATH/config
    # echo 0x258a7080 1 > $DCC_PATH/config
    # echo 0x258A7084 1 > $DCC_PATH/config
    # echo 0x258a708c 1 > $DCC_PATH/config
    # echo 0x258A7090 1 > $DCC_PATH/config
    # echo 0x258A7094 1 > $DCC_PATH/config
    # echo 0x258A7098 1 > $DCC_PATH/config
    # echo 0x258A709C 1 > $DCC_PATH/config
    # echo 0x258A70A0 1 > $DCC_PATH/config
    # echo 0x258E002C 1 > $DCC_PATH/config
    # echo 0x258E009C 1 > $DCC_PATH/config
    # echo 0x258E00A0 1 > $DCC_PATH/config
    # echo 0x258E00A8 1 > $DCC_PATH/config
    # echo 0x258E00AC 1 > $DCC_PATH/config
    # echo 0x258E00B0 1 > $DCC_PATH/config
    # echo 0x258E00B8 1 > $DCC_PATH/config
    # echo 0x258E00C0 1 > $DCC_PATH/config
    # echo 0x258E00C4 1 > $DCC_PATH/config
    # echo 0x258E00C8 1 > $DCC_PATH/config
    # echo 0x258E00CC 1 > $DCC_PATH/config
    # echo 0x258E00D0 1 > $DCC_PATH/config
    # echo 0x258E00D4 1 > $DCC_PATH/config
    # echo 0x258E00D8 1 > $DCC_PATH/config
    # echo 0x258E00E0 1 > $DCC_PATH/config
    # echo 0x258E00E8 1 > $DCC_PATH/config
    # echo 0x258E00F0 1 > $DCC_PATH/config
    # echo 0x258E00F8 1 > $DCC_PATH/config
    # echo 0x258E0100 1 > $DCC_PATH/config
    # echo 0x258E0108 1 > $DCC_PATH/config
    # echo 0x258E0110 1 > $DCC_PATH/config
    # echo 0x258E0118 1 > $DCC_PATH/config
    # echo 0x258E0120 1 > $DCC_PATH/config
    # echo 0x258E0128 1 > $DCC_PATH/config
    # echo 0x258E0150 1 > $DCC_PATH/config
    # echo 0x258E0154 1 > $DCC_PATH/config
    # echo 0x258E0158 1 > $DCC_PATH/config
    # echo 0x258E015C 1 > $DCC_PATH/config
    # echo 0x258E0164 1 > $DCC_PATH/config
    # echo 0x258E01E8 1 > $DCC_PATH/config
    echo 0x258E1010  > $DCC_PATH/config
    echo 0x258E1060 3 > $DCC_PATH/config
    echo 0x258E1070  > $DCC_PATH/config
    echo 0x258E1084 3 > $DCC_PATH/config
    echo 0x258E3004  > $DCC_PATH/config
    echo 0x258E300C  > $DCC_PATH/config
    echo 0x258E4004  > $DCC_PATH/config
    echo 0x258E4010 2 > $DCC_PATH/config
    echo 0x258E4024 2 > $DCC_PATH/config
    echo 0x258E4038 2 > $DCC_PATH/config
    # echo 0x258E600C 1 > $DCC_PATH/config
    # echo 0x258E6010 1 > $DCC_PATH/config
    # echo 0x258E6014 1 > $DCC_PATH/config
    # echo 0x258E6018 1 > $DCC_PATH/config
    # echo 0x258E601C 1 > $DCC_PATH/config
    # echo 0x258E700C 1 > $DCC_PATH/config
    # echo 0x258E7010 1 > $DCC_PATH/config
    # echo 0x258E7014 1 > $DCC_PATH/config
    # echo 0x258E7018 1 > $DCC_PATH/config
    # echo 0x258E701C 1 > $DCC_PATH/config
    echo 0x258E9004  > $DCC_PATH/config
    echo 0x258E9010 3 > $DCC_PATH/config
    echo 0x258E9020 3 > $DCC_PATH/config
    echo 0x258E9030 3 > $DCC_PATH/config
    echo 0x258E9040 3 > $DCC_PATH/config
    echo 0x258E9050 3 > $DCC_PATH/config
    # echo 0x258EA004 1 > $DCC_PATH/config
    # echo 0x258EA010 1 > $DCC_PATH/config
    # echo 0x258EA014 1 > $DCC_PATH/config
    # echo 0x258EA018 1 > $DCC_PATH/config
    # echo 0x258EA020 1 > $DCC_PATH/config
    # echo 0x258EA024 1 > $DCC_PATH/config
    # echo 0x258EA028 1 > $DCC_PATH/config
    # echo 0x258EA030 1 > $DCC_PATH/config
    # echo 0x258EA034 1 > $DCC_PATH/config
    # echo 0x258EA038 1 > $DCC_PATH/config
    # echo 0x258EA040 1 > $DCC_PATH/config
    # echo 0x258EA044 1 > $DCC_PATH/config
    # echo 0x258EA048 1 > $DCC_PATH/config
    # echo 0x258EA050 1 > $DCC_PATH/config
    # echo 0x258EA054 1 > $DCC_PATH/config
    # echo 0x258EA058 1 > $DCC_PATH/config
    # echo 0x258F001C 1 > $DCC_PATH/config
    # echo 0x258F0050 1 > $DCC_PATH/config
    # echo 0x258F0058 1 > $DCC_PATH/config
    # echo 0x25c00004 1 > $DCC_PATH/config
    # echo 0x25c01004 1 > $DCC_PATH/config
    # echo 0x25c02004 1 > $DCC_PATH/config
    # echo 0x25c03004 1 > $DCC_PATH/config
    # echo 0x25c04004 1 > $DCC_PATH/config
    # echo 0x25c05004 1 > $DCC_PATH/config
    # echo 0x25c06004 1 > $DCC_PATH/config
    # echo 0x25c07004 1 > $DCC_PATH/config
    # echo 0x25c08004 1 > $DCC_PATH/config
    # echo 0x25c09004 1 > $DCC_PATH/config
    # echo 0x25c0a004 1 > $DCC_PATH/config
    # echo 0x25c0b004 1 > $DCC_PATH/config
    # echo 0x25c0c004 1 > $DCC_PATH/config
    # echo 0x25c0d004 1 > $DCC_PATH/config
    # echo 0x25c0e004 1 > $DCC_PATH/config
    # echo 0x25c0f004 1 > $DCC_PATH/config
    # echo 0x25c10004 1 > $DCC_PATH/config
    # echo 0x25c11004 1 > $DCC_PATH/config
    # echo 0x25c12004 1 > $DCC_PATH/config
    # echo 0x25c13004 1 > $DCC_PATH/config
    # echo 0x25c14004 1 > $DCC_PATH/config
    # echo 0x25c15004 1 > $DCC_PATH/config
    # echo 0x25c16004 1 > $DCC_PATH/config
    # echo 0x25c17004 1 > $DCC_PATH/config
    # echo 0x25c18004 1 > $DCC_PATH/config
    # echo 0x25c19004 1 > $DCC_PATH/config
    # echo 0x25c1a004 1 > $DCC_PATH/config
    # echo 0x25c1b004 1 > $DCC_PATH/config
    # echo 0x25c1c004 1 > $DCC_PATH/config
    # echo 0x25c1d004 1 > $DCC_PATH/config
    # echo 0x25c1e004 1 > $DCC_PATH/config
    # echo 0x25c1f004 1 > $DCC_PATH/config
    # echo 0x25c20004 1 > $DCC_PATH/config
    # echo 0x25c21004 1 > $DCC_PATH/config
    # echo 0x25c22004 1 > $DCC_PATH/config
    # echo 0x25c23004 1 > $DCC_PATH/config
    # echo 0x25C43350 1 > $DCC_PATH/config
    # echo 0x25C43354 1 > $DCC_PATH/config
    # echo 0x25C433F4 1 > $DCC_PATH/config
    # echo 0x25C433F8 1 > $DCC_PATH/config
    # echo 0x25C433FC 1 > $DCC_PATH/config
    # echo 0x25C43400 1 > $DCC_PATH/config
    # echo 0x25C43404 1 > $DCC_PATH/config
    # echo 0x25C43408 1 > $DCC_PATH/config
    # echo 0x25C4340C 1 > $DCC_PATH/config
    # echo 0x25C43410 1 > $DCC_PATH/config
    # echo 0x25C43414 1 > $DCC_PATH/config
    # echo 0x25C43418 1 > $DCC_PATH/config
    # echo 0x25C4341C 1 > $DCC_PATH/config
    # echo 0x25C434C0 1 > $DCC_PATH/config
    # echo 0x25C434C4 1 > $DCC_PATH/config
    # echo 0x25C434C8 1 > $DCC_PATH/config
    # echo 0x25C434CC 1 > $DCC_PATH/config
    # echo 0x25C434D0 1 > $DCC_PATH/config
    # echo 0x25C434D4 1 > $DCC_PATH/config
    # echo 0x25C43600 1 > $DCC_PATH/config
    # echo 0x25C4360C 1 > $DCC_PATH/config
    # echo 0x25C45040 1 > $DCC_PATH/config
    # echo 0x25C45048 1 > $DCC_PATH/config
    # echo 0x25C45050 1 > $DCC_PATH/config
    # echo 0x25C45058 1 > $DCC_PATH/config
    # echo 0x25C45060 1 > $DCC_PATH/config
    # echo 0x25C45068 1 > $DCC_PATH/config
    # echo 0x25C45070 1 > $DCC_PATH/config
    # echo 0x25C45074 1 > $DCC_PATH/config
    # echo 0x25C45078 1 > $DCC_PATH/config
    # echo 0x25C4507C 1 > $DCC_PATH/config
    # echo 0x25C45090 1 > $DCC_PATH/config
    # echo 0x25C45094 1 > $DCC_PATH/config
    # echo 0x25C45098 1 > $DCC_PATH/config
    # echo 0x25C4509C 1 > $DCC_PATH/config
    # echo 0x25C450A0 1 > $DCC_PATH/config
    # echo 0x25C450A4 1 > $DCC_PATH/config
    # echo 0x25C450A8 1 > $DCC_PATH/config
    # echo 0x25C450AC 1 > $DCC_PATH/config
    # echo 0x25C450B0 1 > $DCC_PATH/config
    # echo 0x25C450B4 1 > $DCC_PATH/config
    # echo 0x25C450B8 1 > $DCC_PATH/config
    # echo 0x25C450BC 1 > $DCC_PATH/config
    # echo 0x25C450C0 1 > $DCC_PATH/config
    # echo 0x25C450C4 1 > $DCC_PATH/config
    # echo 0x25C450CC 1 > $DCC_PATH/config
    # echo 0x25C450D0 1 > $DCC_PATH/config
    # echo 0x25C45240 1 > $DCC_PATH/config
    # echo 0x25C452A0 1 > $DCC_PATH/config
    # echo 0x25C45300 1 > $DCC_PATH/config
    # echo 0x25C45310 1 > $DCC_PATH/config
    # echo 0x25C45320 1 > $DCC_PATH/config
    # echo 0x25C45330 1 > $DCC_PATH/config
    # echo 0x25C45334 1 > $DCC_PATH/config
    # echo 0x25C45338 1 > $DCC_PATH/config
    # echo 0x25C47404 1 > $DCC_PATH/config
    # echo 0x25C4740C 1 > $DCC_PATH/config
    # echo 0x25C47410 1 > $DCC_PATH/config
    # echo 0x25C47414 1 > $DCC_PATH/config
    # echo 0x25C47448 1 > $DCC_PATH/config
    # echo 0x25C47450 1 > $DCC_PATH/config
    # echo 0x25C47458 1 > $DCC_PATH/config
    # echo 0x25C4745C 1 > $DCC_PATH/config
    # echo 0x25C47600 1 > $DCC_PATH/config
    # echo 0x25C49000 1 > $DCC_PATH/config
    # echo 0x25C49010 1 > $DCC_PATH/config
    echo 0x25C7C000  > $DCC_PATH/config
    echo 0x25C7C01C 3 > $DCC_PATH/config
    echo 0x25C7C030 8 > $DCC_PATH/config
    echo 0x25C7C054 2 > $DCC_PATH/config
    echo 0x25C7C078  > $DCC_PATH/config
    echo 0x25C7C108 9 > $DCC_PATH/config
    echo 0x25C7C20C 3 > $DCC_PATH/config
    # echo 0x25CA600C 1 > $DCC_PATH/config
    # echo 0x25CA6010 1 > $DCC_PATH/config
    # echo 0x25CA6014 1 > $DCC_PATH/config
    # echo 0x25CA6018 1 > $DCC_PATH/config
    # echo 0x25CA6020 1 > $DCC_PATH/config
    # echo 0x25CA6024 1 > $DCC_PATH/config
    # echo 0x25CA6028 1 > $DCC_PATH/config
    # echo 0x25CA6034 1 > $DCC_PATH/config
    # echo 0x25CA6038 1 > $DCC_PATH/config
    # echo 0x25CA6040 1 > $DCC_PATH/config
    # echo 0x25CA6050 1 > $DCC_PATH/config
    # echo 0x25CA6058 1 > $DCC_PATH/config
    # echo 0x25CA6060 1 > $DCC_PATH/config
    # echo 0x25CA6064 1 > $DCC_PATH/config
    # echo 0x25CA6068 1 > $DCC_PATH/config
    # echo 0x25CA606C 1 > $DCC_PATH/config
    # echo 0x25CA7020 1 > $DCC_PATH/config
    # echo 0x25CA7030 1 > $DCC_PATH/config
    # echo 0x25CA7034 1 > $DCC_PATH/config
    # echo 0x25CA7078 1 > $DCC_PATH/config
    # echo 0x25CA707C 1 > $DCC_PATH/config
    # echo 0x25ca7080 1 > $DCC_PATH/config
    # echo 0x25CA7084 1 > $DCC_PATH/config
    # echo 0x25ca708c 1 > $DCC_PATH/config
    # echo 0x25CA7090 1 > $DCC_PATH/config
    # echo 0x25CA7094 1 > $DCC_PATH/config
    # echo 0x25CA7098 1 > $DCC_PATH/config
    # echo 0x25CA709C 1 > $DCC_PATH/config
    # echo 0x25CA70A0 1 > $DCC_PATH/config
    # echo 0x25CE002C 1 > $DCC_PATH/config
    # echo 0x25CE009C 1 > $DCC_PATH/config
    # echo 0x25CE00A0 1 > $DCC_PATH/config
    # echo 0x25CE00A8 1 > $DCC_PATH/config
    # echo 0x25CE00AC 1 > $DCC_PATH/config
    # echo 0x25CE00B0 1 > $DCC_PATH/config
    # echo 0x25CE00B8 1 > $DCC_PATH/config
    # echo 0x25CE00C0 1 > $DCC_PATH/config
    # echo 0x25CE00C4 1 > $DCC_PATH/config
    # echo 0x25CE00C8 1 > $DCC_PATH/config
    # echo 0x25CE00CC 1 > $DCC_PATH/config
    # echo 0x25CE00D0 1 > $DCC_PATH/config
    # echo 0x25CE00D4 1 > $DCC_PATH/config
    # echo 0x25CE00D8 1 > $DCC_PATH/config
    # echo 0x25CE00E0 1 > $DCC_PATH/config
    # echo 0x25CE00E8 1 > $DCC_PATH/config
    # echo 0x25CE00F0 1 > $DCC_PATH/config
    # echo 0x25CE00F8 1 > $DCC_PATH/config
    # echo 0x25CE0100 1 > $DCC_PATH/config
    # echo 0x25CE0108 1 > $DCC_PATH/config
    # echo 0x25CE0110 1 > $DCC_PATH/config
    # echo 0x25CE0118 1 > $DCC_PATH/config
    # echo 0x25CE0120 1 > $DCC_PATH/config
    # echo 0x25CE0128 1 > $DCC_PATH/config
    # echo 0x25CE0150 1 > $DCC_PATH/config
    # echo 0x25CE0154 1 > $DCC_PATH/config
    # echo 0x25CE0158 1 > $DCC_PATH/config
    # echo 0x25CE015C 1 > $DCC_PATH/config
    # echo 0x25CE0164 1 > $DCC_PATH/config
    # echo 0x25CE01E8 1 > $DCC_PATH/config
    echo 0x25CE1010  > $DCC_PATH/config
    echo 0x25CE1060 3 > $DCC_PATH/config
    echo 0x25CE1070  > $DCC_PATH/config
    echo 0x25CE1084 3 > $DCC_PATH/config
    echo 0x25CE3004  > $DCC_PATH/config
    echo 0x25CE300C  > $DCC_PATH/config
    echo 0x25CE4004  > $DCC_PATH/config
    echo 0x25CE4010 2 > $DCC_PATH/config
    echo 0x25CE4024 2 > $DCC_PATH/config
    echo 0x25CE4038 2 > $DCC_PATH/config
    # echo 0x25CE600C 1 > $DCC_PATH/config
    # echo 0x25CE6010 1 > $DCC_PATH/config
    # echo 0x25CE6014 1 > $DCC_PATH/config
    # echo 0x25CE6018 1 > $DCC_PATH/config
    # echo 0x25CE601C 1 > $DCC_PATH/config
    # echo 0x25CE700C 1 > $DCC_PATH/config
    # echo 0x25CE7010 1 > $DCC_PATH/config
    # echo 0x25CE7014 1 > $DCC_PATH/config
    # echo 0x25CE7018 1 > $DCC_PATH/config
    # echo 0x25CE701C 1 > $DCC_PATH/config
    echo 0x25CE9004  > $DCC_PATH/config
    echo 0x25CE9010 3 > $DCC_PATH/config
    echo 0x25CE9020 3 > $DCC_PATH/config
    echo 0x25CE9030 3 > $DCC_PATH/config
    echo 0x25CE9040 3 > $DCC_PATH/config
    echo 0x25CE9050 3 > $DCC_PATH/config
    # echo 0x25CEA004 1 > $DCC_PATH/config
    # echo 0x25CEA010 1 > $DCC_PATH/config
    # echo 0x25CEA014 1 > $DCC_PATH/config
    # echo 0x25CEA018 1 > $DCC_PATH/config
    # echo 0x25CEA020 1 > $DCC_PATH/config
    # echo 0x25CEA024 1 > $DCC_PATH/config
    # echo 0x25CEA028 1 > $DCC_PATH/config
    # echo 0x25CEA030 1 > $DCC_PATH/config
    # echo 0x25CEA034 1 > $DCC_PATH/config
    # echo 0x25CEA038 1 > $DCC_PATH/config
    # echo 0x25CEA040 1 > $DCC_PATH/config
    # echo 0x25CEA044 1 > $DCC_PATH/config
    # echo 0x25CEA048 1 > $DCC_PATH/config
    # echo 0x25CEA050 1 > $DCC_PATH/config
    # echo 0x25CEA054 1 > $DCC_PATH/config
    # echo 0x25CEA058 1 > $DCC_PATH/config
    # echo 0x25CF001C 1 > $DCC_PATH/config
    # echo 0x25CF0050 1 > $DCC_PATH/config
    # echo 0x25CF0058 1 > $DCC_PATH/config
    echo 0x240A0008 1 > $DCC_PATH/config
    echo 0x240A000C 1 > $DCC_PATH/config
    echo 0x240A1008 1 > $DCC_PATH/config
    echo 0x240A100C 1 > $DCC_PATH/config
    echo 0x221c2ca4 1 > $DCC_PATH/config
    echo 0x221c2cec 1 > $DCC_PATH/config
    # echo 0x248e0070 1 > $DCC_PATH/config
    # echo 0x248e0074 1 > $DCC_PATH/config
    # echo 0x248e0078 1 > $DCC_PATH/config
    # echo 0x248e007c 1 > $DCC_PATH/config
    # echo 0x248e0080 1 > $DCC_PATH/config
    # echo 0x248e0084 1 > $DCC_PATH/config
    # echo 0x248e0088 1 > $DCC_PATH/config
    # echo 0x248e0094 1 > $DCC_PATH/config
    # echo 0x248e0098 1 > $DCC_PATH/config
    # echo 0x248e012c 1 > $DCC_PATH/config
    # echo 0x248e0130 1 > $DCC_PATH/config
    # echo 0x248e0134 1 > $DCC_PATH/config
    # echo 0x248e0138 1 > $DCC_PATH/config
    # echo 0x248e013c 1 > $DCC_PATH/config
    # echo 0x248e0140 1 > $DCC_PATH/config
    # echo 0x248e0144 1 > $DCC_PATH/config
    # echo 0x248e0148 1 > $DCC_PATH/config
    # echo 0x248e014c 1 > $DCC_PATH/config
    # echo 0x248e0160 1 > $DCC_PATH/config
    # echo 0x248e0364 1 > $DCC_PATH/config
    # echo 0x248e0368 1 > $DCC_PATH/config
    # echo 0x24ce0070 1 > $DCC_PATH/config
    # echo 0x24ce0074 1 > $DCC_PATH/config
    # echo 0x24ce0078 1 > $DCC_PATH/config
    # echo 0x24ce007c 1 > $DCC_PATH/config
    # echo 0x24ce0080 1 > $DCC_PATH/config
    # echo 0x24ce0084 1 > $DCC_PATH/config
    # echo 0x24ce0088 1 > $DCC_PATH/config
    # echo 0x24ce0094 1 > $DCC_PATH/config
    # echo 0x24ce0098 1 > $DCC_PATH/config
    # echo 0x24ce012c 1 > $DCC_PATH/config
    # echo 0x24ce0130 1 > $DCC_PATH/config
    # echo 0x24ce0134 1 > $DCC_PATH/config
    # echo 0x24ce0138 1 > $DCC_PATH/config
    # echo 0x24ce013c 1 > $DCC_PATH/config
    # echo 0x24ce0140 1 > $DCC_PATH/config
    # echo 0x24ce0144 1 > $DCC_PATH/config
    # echo 0x24ce0148 1 > $DCC_PATH/config
    # echo 0x24ce014c 1 > $DCC_PATH/config
    # echo 0x24ce0160 1 > $DCC_PATH/config
    # echo 0x24ce0364 1 > $DCC_PATH/config
    # echo 0x24ce0368 1 > $DCC_PATH/config
    # echo 0x258e0070 1 > $DCC_PATH/config
    # echo 0x258e0074 1 > $DCC_PATH/config
    # echo 0x258e0078 1 > $DCC_PATH/config
    # echo 0x258e007c 1 > $DCC_PATH/config
    # echo 0x258e0080 1 > $DCC_PATH/config
    # echo 0x258e0084 1 > $DCC_PATH/config
    # echo 0x258e0088 1 > $DCC_PATH/config
    # echo 0x258e0094 1 > $DCC_PATH/config
    # echo 0x258e0098 1 > $DCC_PATH/config
    # echo 0x258e012c 1 > $DCC_PATH/config
    # echo 0x258e0130 1 > $DCC_PATH/config
    # echo 0x258e0134 1 > $DCC_PATH/config
    # echo 0x258e0138 1 > $DCC_PATH/config
    # echo 0x258e013c 1 > $DCC_PATH/config
    # echo 0x258e0140 1 > $DCC_PATH/config
    # echo 0x258e0144 1 > $DCC_PATH/config
    # echo 0x258e0148 1 > $DCC_PATH/config
    # echo 0x258e014c 1 > $DCC_PATH/config
    # echo 0x258e0160 1 > $DCC_PATH/config
    # echo 0x258e0364 1 > $DCC_PATH/config
    # echo 0x258e0368 1 > $DCC_PATH/config
    # echo 0x25ce0070 1 > $DCC_PATH/config
    # echo 0x25ce0074 1 > $DCC_PATH/config
    # echo 0x25ce0078 1 > $DCC_PATH/config
    # echo 0x25ce007c 1 > $DCC_PATH/config
    # echo 0x25ce0080 1 > $DCC_PATH/config
    # echo 0x25ce0084 1 > $DCC_PATH/config
    # echo 0x25ce0088 1 > $DCC_PATH/config
    # echo 0x25ce0094 1 > $DCC_PATH/config
    # echo 0x25ce0098 1 > $DCC_PATH/config
    # echo 0x25ce012c 1 > $DCC_PATH/config
    # echo 0x25ce0130 1 > $DCC_PATH/config
    # echo 0x25ce0134 1 > $DCC_PATH/config
    # echo 0x25ce0138 1 > $DCC_PATH/config
    # echo 0x25ce013c 1 > $DCC_PATH/config
    # echo 0x25ce0140 1 > $DCC_PATH/config
    # echo 0x25ce0144 1 > $DCC_PATH/config
    # echo 0x25ce0148 1 > $DCC_PATH/config
    # echo 0x25ce014c 1 > $DCC_PATH/config
    # echo 0x25ce0160 1 > $DCC_PATH/config
    # echo 0x25ce0364 1 > $DCC_PATH/config
    # echo 0x25ce0368 1 > $DCC_PATH/config
    # echo 0x248e0358 1 > $DCC_PATH/config
    # echo 0x24ce0358 1 > $DCC_PATH/config
    # echo 0x258e0358 1 > $DCC_PATH/config
    # echo 0x25ce0358 1 > $DCC_PATH/config
    # echo 0x248e0008 1 > $DCC_PATH/config
    # echo 0x24ce0008 1 > $DCC_PATH/config
    # echo 0x258e0008 1 > $DCC_PATH/config
    # echo 0x25ce0008 1 > $DCC_PATH/config
    #SHRM2_CSR_SHRM_RCI_LOGGER_n_INFO and SHRM__LOGGER_n_TIMESTAMP_LOWER
    echo 0x24076B00  2 > $DCC_PATH/config
    echo 0x24076B0C  2 > $DCC_PATH/config
    echo 0x24076B18  2 > $DCC_PATH/config
    echo 0x24076B24  2 > $DCC_PATH/config
    echo 0x24076B30  2 > $DCC_PATH/config
    echo 0x24076B3C  2 > $DCC_PATH/config
    echo 0x24076B48  2 > $DCC_PATH/config
    echo 0x24076B54  2 > $DCC_PATH/config
    echo 0x24076B60  2 > $DCC_PATH/config
    echo 0x24076B6C  2 > $DCC_PATH/config
    echo 0x24076B78  2 > $DCC_PATH/config
    echo 0x24076B84  2 > $DCC_PATH/config
    echo 0x24076B90  2 > $DCC_PATH/config
    echo 0x24076B9C  2 > $DCC_PATH/config
    echo 0x24076BA8  2 > $DCC_PATH/config
    echo 0x24076BB4  2 > $DCC_PATH/config
    echo 0x24076BC0  2 > $DCC_PATH/config
    echo 0x24076BCC  2 > $DCC_PATH/config
    echo 0x24076BD8  2 > $DCC_PATH/config
    echo 0x24076BE4  2 > $DCC_PATH/config
    echo 0x24076BF0  2 > $DCC_PATH/config
    echo 0x24076BFC  2 > $DCC_PATH/config
    echo 0x24076C08  2 > $DCC_PATH/config
    echo 0x24076C14  2 > $DCC_PATH/config
    echo 0x24076C20  2 > $DCC_PATH/config
    echo 0x24076C2C  2 > $DCC_PATH/config
    echo 0x24076C38  2 > $DCC_PATH/config
    echo 0x24076C44  2 > $DCC_PATH/config
    echo 0x24076C50  2 > $DCC_PATH/config
    echo 0x24076C5C  2 > $DCC_PATH/config
    echo 0x24076C68  2 > $DCC_PATH/config
    echo 0x24076C74  2 > $DCC_PATH/config
    #SHRM2_RVSS_PERIPH_SHRM2_CSR_SHRM_RCI_CTRL
    echo 0x24076950  1 > $DCC_PATH/config
    #SHRM_QOS_OUTPUT_POLICY_OVERRIDE
    echo 0x240760A4  1 > $DCC_PATH/config
    #LLCC_FEAC_FENCE_CTRL
    # echo 0x248720B0 1 > $DCC_PATH/config
    # echo 0x258720B0 1 > $DCC_PATH/config
    # echo 0x24C720B0 1 > $DCC_PATH/config
    # echo 0x25C720B0 1 > $DCC_PATH/config

}

config_eva()
{
    echo 0x132028 > $DCC_PATH/config
    echo 0x132038 > $DCC_PATH/config
    echo 0xABF80F8 > $DCC_PATH/config
    echo 0xAB00050 > $DCC_PATH/config
    echo 0xAB1F004 > $DCC_PATH/config
    echo 0xABA0018 > $DCC_PATH/config
    echo 0xABA004C > $DCC_PATH/config
    echo 0xABA0150 > $DCC_PATH/config
    echo 0xABB000C > $DCC_PATH/config
    echo 0xABB0050 5 > $DCC_PATH/config
    echo 0xABB0088 > $DCC_PATH/config
    echo 0xABC0010 2 > $DCC_PATH/config
    echo 0xABE0008 2 > $DCC_PATH/config
    echo 0xABE001C > $DCC_PATH/config
    echo 0xABE0024 2 > $DCC_PATH/config
    echo 0xABF8034 > $DCC_PATH/config
    echo 0xABF804C > $DCC_PATH/config
    echo 0xABF8068 > $DCC_PATH/config
    echo 0xABF807C > $DCC_PATH/config
    echo 0xABA0048 9 > $DCC_PATH/config
    echo 0xABA0038 2 > $DCC_PATH/config
    echo 0xABC0020 > $DCC_PATH/config
    echo 0xABE0014 > $DCC_PATH/config
    echo 0xABE0024 > $DCC_PATH/config
    echo 0xABE001C > $DCC_PATH/config
    echo 0xABE002C 2 > $DCC_PATH/config
    echo 0xABF80A4 > $DCC_PATH/config
    echo 0x19F004 2 > $DCC_PATH/config
    echo 0x19F018 > $DCC_PATH/config
    echo 0xABF808C > $DCC_PATH/config
    echo 0xABF805C > $DCC_PATH/config
    echo 0xABF80F8 > $DCC_PATH/config
    echo 0xABF9F24 > $DCC_PATH/config
    echo 0xABB0000 > $DCC_PATH/config
    echo 0xABC0000 > $DCC_PATH/config
    echo 0xABC0010 3 > $DCC_PATH/config
    echo 0xABC0020 > $DCC_PATH/config
    echo 0xABC1000 > $DCC_PATH/config
    echo 0xABC1020 8 > $DCC_PATH/config
    echo 0xABC2100 10 > $DCC_PATH/config
    echo 0xAB00090 > $DCC_PATH/config
    echo 0xAB00094 > $DCC_PATH/config
}

config_turing()
{
	echo 0x3230030C > $DCC_PATH/config
}

config_qdsp_lpm()
{
    # LPASS
    echo 0x68C0404 2 > $DCC_PATH/config
    echo 0x68C0208 3 > $DCC_PATH/config
    echo 0x68C0228 3 > $DCC_PATH/config
    echo 0x68C0248 3 > $DCC_PATH/config
    echo 0x68C0268 3 > $DCC_PATH/config
    echo 0x68C040C 1 > $DCC_PATH/config
    echo 0x68C0110 2 > $DCC_PATH/config
    echo 0x68C011C 1 > $DCC_PATH/config
    echo 0x7200404 2 > $DCC_PATH/config
    echo 0x7200208 3 > $DCC_PATH/config
    echo 0x7200228 3 > $DCC_PATH/config
    echo 0x7200248 3 > $DCC_PATH/config
    echo 0x7200268 3 > $DCC_PATH/config
    echo 0x720040C 1 > $DCC_PATH/config
    echo 0x7200110 2 > $DCC_PATH/config
    echo 0x720011C 1 > $DCC_PATH/config
    echo 0x7201c30 1 > $DCC_PATH/config
    echo 0x7201ed0 1 > $DCC_PATH/config
    echo 0x7202170 1 > $DCC_PATH/config
    echo 0x7202410 1 > $DCC_PATH/config
    echo 0x72026b0 1 > $DCC_PATH/config
    echo 0x7202950 1 > $DCC_PATH/config
    echo 0x7202bf0 1 > $DCC_PATH/config
    echo 0x7202e90 1 > $DCC_PATH/config
    echo 0x7203130 1 > $DCC_PATH/config
    echo 0x72033d0 1 > $DCC_PATH/config
    echo 0x7203670 1 > $DCC_PATH/config
    echo 0x7201c48 1 > $DCC_PATH/config
    echo 0x7201c60 1 > $DCC_PATH/config
    echo 0x7201c78 1 > $DCC_PATH/config
    echo 0x7201c90 1 > $DCC_PATH/config
    echo 0x7201ca8 1 > $DCC_PATH/config
    echo 0x7201cc0 1 > $DCC_PATH/config
    echo 0x7201cd8 1 > $DCC_PATH/config
    echo 0x7201cf0 1 > $DCC_PATH/config
    echo 0x7201d08 1 > $DCC_PATH/config
    echo 0x7201d20 1 > $DCC_PATH/config
    echo 0x7201d38 1 > $DCC_PATH/config
    echo 0x7201d50 1 > $DCC_PATH/config
    echo 0x7201d68 1 > $DCC_PATH/config
    echo 0x7201d80 1 > $DCC_PATH/config
    echo 0x7201d98 1 > $DCC_PATH/config
    echo 0x7201db0 1 > $DCC_PATH/config
    echo 0x7201ee8 1 > $DCC_PATH/config
    echo 0x7201f00 1 > $DCC_PATH/config
    echo 0x7201f18 1 > $DCC_PATH/config
    echo 0x7201f30 1 > $DCC_PATH/config
    echo 0x7201f48 1 > $DCC_PATH/config
    echo 0x7201f60 1 > $DCC_PATH/config
    echo 0x7201f78 1 > $DCC_PATH/config
    echo 0x7201f90 1 > $DCC_PATH/config
    echo 0x7201fa8 1 > $DCC_PATH/config
    echo 0x7201fc0 1 > $DCC_PATH/config
    echo 0x7201fd8 1 > $DCC_PATH/config
    echo 0x7201ff0 1 > $DCC_PATH/config
    echo 0x7202008 1 > $DCC_PATH/config
    echo 0x7202020 1 > $DCC_PATH/config
    echo 0x7202038 1 > $DCC_PATH/config
    echo 0x7202050 1 > $DCC_PATH/config
    echo 0x7202188 1 > $DCC_PATH/config
    echo 0x72021a0 1 > $DCC_PATH/config
    echo 0x72021b8 1 > $DCC_PATH/config
    echo 0x72021d0 1 > $DCC_PATH/config
    echo 0x72021e8 1 > $DCC_PATH/config
    echo 0x7202200 1 > $DCC_PATH/config
    echo 0x7202218 1 > $DCC_PATH/config
    echo 0x7202230 1 > $DCC_PATH/config
    echo 0x7202248 1 > $DCC_PATH/config
    echo 0x7202260 1 > $DCC_PATH/config
    echo 0x7202278 1 > $DCC_PATH/config
    echo 0x7202290 1 > $DCC_PATH/config
    echo 0x72022a8 1 > $DCC_PATH/config
    echo 0x72022c0 1 > $DCC_PATH/config
    echo 0x72022d8 1 > $DCC_PATH/config
    echo 0x72022f0 1 > $DCC_PATH/config
    echo 0x7202428 1 > $DCC_PATH/config
    echo 0x7202440 1 > $DCC_PATH/config
    echo 0x7202458 1 > $DCC_PATH/config
    echo 0x7202470 1 > $DCC_PATH/config
    echo 0x7202488 1 > $DCC_PATH/config
    echo 0x72024a0 1 > $DCC_PATH/config
    echo 0x72024b8 1 > $DCC_PATH/config
    echo 0x72024d0 1 > $DCC_PATH/config
    echo 0x72024e8 1 > $DCC_PATH/config
    echo 0x7202500 1 > $DCC_PATH/config
    echo 0x7202518 1 > $DCC_PATH/config
    echo 0x7202530 1 > $DCC_PATH/config
    echo 0x7202548 1 > $DCC_PATH/config
    echo 0x7202560 1 > $DCC_PATH/config
    echo 0x7202578 1 > $DCC_PATH/config
    echo 0x7202590 1 > $DCC_PATH/config
    echo 0x72026c8 1 > $DCC_PATH/config
    echo 0x72026e0 1 > $DCC_PATH/config
    echo 0x72026f8 1 > $DCC_PATH/config
    echo 0x7202710 1 > $DCC_PATH/config
    echo 0x7202728 1 > $DCC_PATH/config
    echo 0x7202740 1 > $DCC_PATH/config
    echo 0x7202758 1 > $DCC_PATH/config
    echo 0x7202770 1 > $DCC_PATH/config
    echo 0x7202788 1 > $DCC_PATH/config
    echo 0x72027a0 1 > $DCC_PATH/config
    echo 0x72027b8 1 > $DCC_PATH/config
    echo 0x72027d0 1 > $DCC_PATH/config
    echo 0x72027e8 1 > $DCC_PATH/config
    echo 0x7202800 1 > $DCC_PATH/config
    echo 0x7202818 1 > $DCC_PATH/config
    echo 0x7202830 1 > $DCC_PATH/config
    echo 0x7202968 1 > $DCC_PATH/config
    echo 0x7202980 1 > $DCC_PATH/config
    echo 0x7202998 1 > $DCC_PATH/config
    echo 0x72029b0 1 > $DCC_PATH/config
    echo 0x72029c8 1 > $DCC_PATH/config
    echo 0x72029e0 1 > $DCC_PATH/config
    echo 0x72029f8 1 > $DCC_PATH/config
    echo 0x7202a10 1 > $DCC_PATH/config
    echo 0x7202a28 1 > $DCC_PATH/config
    echo 0x7202a40 1 > $DCC_PATH/config
    echo 0x7202a58 1 > $DCC_PATH/config
    echo 0x7202a70 1 > $DCC_PATH/config
    echo 0x7202a88 1 > $DCC_PATH/config
    echo 0x7202aa0 1 > $DCC_PATH/config
    echo 0x7202ab8 1 > $DCC_PATH/config
    echo 0x7202ad0 1 > $DCC_PATH/config
    echo 0x7202c08 1 > $DCC_PATH/config
    echo 0x7202c20 1 > $DCC_PATH/config
    echo 0x7202c38 1 > $DCC_PATH/config
    echo 0x7202c50 1 > $DCC_PATH/config
    echo 0x7202c68 1 > $DCC_PATH/config
    echo 0x7202c80 1 > $DCC_PATH/config
    echo 0x7202c98 1 > $DCC_PATH/config
    echo 0x7202cb0 1 > $DCC_PATH/config
    echo 0x7202cc8 1 > $DCC_PATH/config
    echo 0x7202ce0 1 > $DCC_PATH/config
    echo 0x7202cf8 1 > $DCC_PATH/config
    echo 0x7202d10 1 > $DCC_PATH/config
    echo 0x7202d28 1 > $DCC_PATH/config
    echo 0x7202d40 1 > $DCC_PATH/config
    echo 0x7202d58 1 > $DCC_PATH/config
    echo 0x7202d70 1 > $DCC_PATH/config
    echo 0x7202ea8 1 > $DCC_PATH/config
    echo 0x7202ec0 1 > $DCC_PATH/config
    echo 0x7202ed8 1 > $DCC_PATH/config
    echo 0x7202ef0 1 > $DCC_PATH/config
    echo 0x7202f08 1 > $DCC_PATH/config
    echo 0x7202f20 1 > $DCC_PATH/config
    echo 0x7202f38 1 > $DCC_PATH/config
    echo 0x7202f50 1 > $DCC_PATH/config
    echo 0x7202f68 1 > $DCC_PATH/config
    echo 0x7202f80 1 > $DCC_PATH/config
    echo 0x7202f98 1 > $DCC_PATH/config
    echo 0x7202fb0 1 > $DCC_PATH/config
    echo 0x7202fc8 1 > $DCC_PATH/config
    echo 0x7202fe0 1 > $DCC_PATH/config
    echo 0x7202ff8 1 > $DCC_PATH/config
    echo 0x7203010 1 > $DCC_PATH/config
    echo 0x7203148 1 > $DCC_PATH/config
    echo 0x7203160 1 > $DCC_PATH/config
    echo 0x7203178 1 > $DCC_PATH/config
    echo 0x7203190 1 > $DCC_PATH/config
    echo 0x72031a8 1 > $DCC_PATH/config
    echo 0x72031c0 1 > $DCC_PATH/config
    echo 0x72031d8 1 > $DCC_PATH/config
    echo 0x72031f0 1 > $DCC_PATH/config
    echo 0x7203208 1 > $DCC_PATH/config
    echo 0x7203220 1 > $DCC_PATH/config
    echo 0x7203238 1 > $DCC_PATH/config
    echo 0x7203250 1 > $DCC_PATH/config
    echo 0x7203268 1 > $DCC_PATH/config
    echo 0x7203280 1 > $DCC_PATH/config
    echo 0x7203298 1 > $DCC_PATH/config
    echo 0x72032b0 1 > $DCC_PATH/config
    echo 0x72033e8 1 > $DCC_PATH/config
    echo 0x7203400 1 > $DCC_PATH/config
    echo 0x7203418 1 > $DCC_PATH/config
    echo 0x7203430 1 > $DCC_PATH/config
    echo 0x7203448 1 > $DCC_PATH/config
    echo 0x7203460 1 > $DCC_PATH/config
    echo 0x7203478 1 > $DCC_PATH/config
    echo 0x7203490 1 > $DCC_PATH/config
    echo 0x72034a8 1 > $DCC_PATH/config
    echo 0x72034c0 1 > $DCC_PATH/config
    echo 0x72034d8 1 > $DCC_PATH/config
    echo 0x72034f0 1 > $DCC_PATH/config
    echo 0x7203508 1 > $DCC_PATH/config
    echo 0x7203520 1 > $DCC_PATH/config
    echo 0x7203538 1 > $DCC_PATH/config
    echo 0x7203550 1 > $DCC_PATH/config
    echo 0x7203688 1 > $DCC_PATH/config
    echo 0x72036a0 1 > $DCC_PATH/config
    echo 0x72036b8 1 > $DCC_PATH/config
    echo 0x72036d0 1 > $DCC_PATH/config
    echo 0x72036e8 1 > $DCC_PATH/config
    echo 0x7203700 1 > $DCC_PATH/config
    echo 0x7203718 1 > $DCC_PATH/config
    echo 0x7203730 1 > $DCC_PATH/config
    echo 0x7203748 1 > $DCC_PATH/config
    echo 0x7203760 1 > $DCC_PATH/config
    echo 0x7203778 1 > $DCC_PATH/config
    echo 0x7203790 1 > $DCC_PATH/config
    echo 0x72037a8 1 > $DCC_PATH/config
    echo 0x72037c0 1 > $DCC_PATH/config
    echo 0x72037d8 1 > $DCC_PATH/config
    echo 0x72037f0 1 > $DCC_PATH/config
}
config_lpass_aon()
{
    echo 0x6E25100 5 > $DCC_PATH/config
    echo 0x6E251AC > $DCC_PATH/config
    echo 0x6E25200 2 > $DCC_PATH/config
    echo 0x6E2A000 > $DCC_PATH/config
    echo 0x7A0104C 2 > $DCC_PATH/config
    echo 0x7A0301C > $DCC_PATH/config
    echo 0x7A03030 > $DCC_PATH/config
    echo 0x7A04130 > $DCC_PATH/config
    echo 0x7A22000 > $DCC_PATH/config
    echo 0x7A23000 > $DCC_PATH/config
}

config_dcc_extra_rscc()
{
    echo 0x1D00010 > $DCC_PATH/config
    echo 0x1D00224 2 > $DCC_PATH/config
    echo 0x1D08088 > $DCC_PATH/config
    echo 0x1D0B088 > $DCC_PATH/config

    echo 0xAF20010 > $DCC_PATH/config
    echo 0xAF20224 2 > $DCC_PATH/config
}

enable_dcc()
{
    #TODO: Add DCC configuration
    DCC_PATH="/sys/bus/platform/devices/100ff000.dcc"
    soc_version=`cat /sys/devices/soc0/revision`
    soc_version=${soc_version/./}

    if [ ! -d $DCC_PATH ]; then
        echo "DCC does not exist on this build."
        return
    fi

    echo 0 > $DCC_PATH/enable
    echo 1 > $DCC_PATH/config_reset
    echo 4 > $DCC_PATH/curr_list
    echo cap > $DCC_PATH/func_type
    echo sram > $DCC_PATH/data_sink
    echo 1 > $DCC_PATH/ap_ns_qad_override_en
    config_dcc_timer

    echo  1 > $DCC_PATH/enable
}

enable_cpuss_register()
{
	cpuss_enable = `cat /sys/kernel/debug/dynamic_mem_dump/cpuss_reg/enable`
	if [ "$cpuss_enable" != "1"]
	then
		return
	fi

	echo 1 > /sys/bus/platform/devices/soc:mem_dump/register_reset

	echo 0x16000000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000030 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000084 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000104 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000184 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000204 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000284 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000384 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000d04 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16000e08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16001000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16001200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16001400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16001600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16001800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16001a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16001c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16002000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16003000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16003400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16003600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16006100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16008000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600e008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600e104 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600e184 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600e204 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600e400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600e600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600e800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600ea00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600ec00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1600ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16010008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16010fcc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1601ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020000 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020040 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020080 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160200c0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020100 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020140 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020180 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160201c0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020200 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020240 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020280 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160202c0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020300 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020340 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020380 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160203c0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020400 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020440 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020480 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160204c0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020500 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020540 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020580 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160205c0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020600 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020640 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16020680 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160206c0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1602e000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1602e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1602e800 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1602ffbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1602ffc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1602ffd0 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030400 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030a00 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030c60 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030c80 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030cc0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030e50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030fb8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16030fcc 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16040000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16040008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16040010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16040020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16040028 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16040080 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16040100 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1604c000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1604f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1604ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16080000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16080008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16080014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16080070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160800c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1608ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16090e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1609c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1609c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1609c010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1609c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1609c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1609c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1609f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1609f010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160a0070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160a0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160a0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160ac000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160ac100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160ae100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160c0000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160c0008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160c0014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160c0070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160c00c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160cffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160d0e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160dc000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160dc008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160dc010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160dc018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160dc100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160dc180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160df000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160df010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160e0070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160e0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160e0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160ec000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160ec100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x160ee100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16100000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16100008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16100014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16100070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161000c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1610ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16110e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1611c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1611c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1611c010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1611c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1611c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1611c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1611f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1611f010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16120070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16120088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16120120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1612c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1612c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1612e100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16140000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16140008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16140014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16140070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161400c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1614ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16150e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1615c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1615c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1615c010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1615c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1615c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1615c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1615f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1615f010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16160070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16160088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16160120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1616c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1616c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1616e100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16180000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16180008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16180014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16180070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161800c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1618ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16190e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1619c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1619c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1619c010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1619c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1619c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1619c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1619f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1619f010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161a0070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161a0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161a0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161ac000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161ac100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161ae100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161c0000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161c0008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161c0014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161c0070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161c00c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161cffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161d0e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161dc000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161dc008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161dc010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161dc018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161dc100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161dc180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161df000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161df010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161e0070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161e0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161e0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161ec000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161ec100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x161ee100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16200000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16200008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16200014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16200070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x162000c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1620ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16210e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1621c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1621c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1621c010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1621c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1621c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1621c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1621f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1621f010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16220070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16220088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16220120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1622c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1622c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1622e100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16240000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16240008 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16240014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16240070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x162400c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1624ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16250e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1625c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1625c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1625c010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1625c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1625c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1625c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1625f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1625f010 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16260070 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16260088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16260120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1626c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1626c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1626e100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280030 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280084 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280104 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280184 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280204 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280284 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280384 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280d04 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16280e08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16281000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16281200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16281400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16281600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16281800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16281a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16281c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16282000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16283400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16283600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16286100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16288000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628e008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628e104 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628e184 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628e204 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628e400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628e600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628e800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628ea00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628ec00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1628ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16410000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1641000c 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16410020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16414000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1641400c 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16414020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440020 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1644003c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440044 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164400f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440444 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440500 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16440700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16450000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16450134 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16450154 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16450168 0x70 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164501e0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16451000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16451140 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16451160 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16451170 0x64 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164511dc 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16453000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16453010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16453020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16453050 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16453084 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16453098 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164530b4 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16454000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16454018 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16455000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16455014 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16456000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164800a0 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1648070c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1648077c 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480808 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480824 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16480840 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16482000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164822e8 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16482350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483a00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483a24 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483a2c 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483b20 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483b30 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483b64 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16483c80 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16488000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1648800c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16488040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16488900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16488c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16488c0c 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16488c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16488fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164900a0 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1649070c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1649077c 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490808 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490824 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16490840 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16492000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164922e8 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16492350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493a00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493a24 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493a2c 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493b20 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493b30 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493b64 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16493c80 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16498000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1649800c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16498040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16498900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16498c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16498c0c 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16498c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16498fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a00a0 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a070c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a077c 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0808 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0824 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a0840 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a2000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a22e8 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a2350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3a00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3a24 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3a2c 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3b20 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3b30 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3b64 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a3c80 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a8000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a800c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a8040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a8900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a8c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a8c0c 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a8c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164a8fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b00a0 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b070c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b077c 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0808 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0824 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b0840 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b2000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b22e8 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b2350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3a00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3a24 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3a2c 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3b20 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3b30 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3b64 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b3c80 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b8000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b800c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b8040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b8900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b8c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b8c0c 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b8c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164b8fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e0000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e2000 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e203c 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e2054 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e2060 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e206c 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e2078 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e2084 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e3000 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e3100 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e3800 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e4000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e5000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e6000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e7000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e7100 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e8000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e8100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e9000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164e9100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164ea000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164eb000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164ec000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164ed000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164ee000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164ef000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f1000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f100c 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f1040 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f2000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f3000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f6000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f6100 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f6300 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f7000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f8000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f8020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164f9000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x164fa000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500000 0x54 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x165000d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x165000d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500100 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500110 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1650011c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500200 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500400 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500460 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500490 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16500d18 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1651001c 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x165100d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x165100d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510100 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510460 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x165104a0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16510d18 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16520d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16520d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16520d18 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16530d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16530d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16530d18 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16540000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16540200 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16540400 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16540600 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16540800 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16540a00 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16550000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16550010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16550030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16550070 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16550100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16560000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16561000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16561020 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16561040 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16561050 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16561060 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16561070 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x165610ac 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16561200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16562000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16562200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16563000 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16563030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16563200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16564004 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16564014 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16564024 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16564034 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16564200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16565000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16565010 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16565024 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16565200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16566000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16800000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16800040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16800080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16800fc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16800fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16800fe0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16800ff0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16801000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16801fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16802000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16802020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16802fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16803000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16803fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16805000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16805fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16806000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16806020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16806fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16807000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16807fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16809000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16809fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1680b000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1680bfd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1680d000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1680dfd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16a00000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c00000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c00100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c00208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c00304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c00400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c00500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c01000 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c01030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c04000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c04100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c04208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c04304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c04400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c04500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c05000 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c05030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c0c000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c0c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c0c208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c0c304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c0c400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c0c500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c0d000 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16c0d030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d00000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d00100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d00208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d00304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d00400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d00500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d01000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0100c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d01014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d01030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d04000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d04100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d04208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d04304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d04400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d04500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d05000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0500c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d05014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d05030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d08000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d08100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d08208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d08304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d08400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d08500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d09000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0900c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d09014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d09030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0c000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0c208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0c304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0c400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0c500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0d000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0d00c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0d014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d0d030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d10000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d10100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d10208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d10304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d10400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d10500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d11000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1100c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d11014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d11030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d14000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d14100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d14208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d14304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d14400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d14500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d15000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1500c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d15014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d15030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d18000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d18100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d18208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d18304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d18400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d18500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d19000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1900c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d19014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d19030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1c000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1c208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1c304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1c400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1c500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1d000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1d00c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1d014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d1d030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d20000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d20100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d20208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d20304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d20400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d20500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d21000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d2100c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d21014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16d21030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e00000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e00010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e00020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e00200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e00240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e00248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e01000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e01010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02200 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x16e02400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000000 0xd8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000260 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000460 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170005f0 0x50 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170007c8 0x90 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000b70 0xf0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000f78 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17001000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17040000 0x80 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17040208 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17040278 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17040408 0xd8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170407f8 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17060000 0xc0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17070000 0xc8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17080000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17080048 0x90 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a0000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a0204 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a0550 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a0580 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a05d0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a0680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a06e4 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a3e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170c0000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170c0198 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170c0328 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170c03f8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170c04a8 0x150 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170c0780 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170d0000 0xb0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170d1000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170d3000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170d5000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170d6000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200000 0xd8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200260 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200460 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172005f0 0x50 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172007c8 0x90 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200b70 0xf0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200f78 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17201000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240000 0x80 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240208 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240278 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240408 0xd8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172407f8 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260000 0xc0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17270000 0xc8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280048 0x90 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0204 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0550 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0580 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a05d0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a06e4 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a3e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0198 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0328 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c03f8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c04a8 0x150 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0780 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0000 0xb0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d1000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d3000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d5000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d6000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800100 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17804000 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17804400 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17804c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17808000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17808100 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1780c000 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1780c400 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1780cc00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810100 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17818000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17818100 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820100 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17824000 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17824400 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17824c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17828000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17828100 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1782c000 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1782c400 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1782cc00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830100 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17838000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17838100 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17841000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842060 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842160 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842400 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17842500 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17843000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17844200 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17845100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17845110 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17845124 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17846018 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17846060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17846100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17846110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17847030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17847040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17847050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17847060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17847070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17847080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17847090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178470a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178470b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178470c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17848000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17848018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17848020 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17848120 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17848130 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17848320 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17849000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17849018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17849020 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17849130 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784a000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784a018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784a020 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784a130 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784b000 0x50 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784b0a4 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784c000 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784d000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784d00c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784d030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1784e040 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851100 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17851330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17852000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17852020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17852040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17852060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17853000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17854000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1785400c 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17854020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988800 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988c00 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988d00 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988e10 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988e40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988e50 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988e60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988e80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988e90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988ea0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998800 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998c00 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998d00 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998e10 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998e40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998e50 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998e60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998e80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998e90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998ea0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8800 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8c00 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8d00 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8e10 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8e40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8e50 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8e60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8e80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8e90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8ea0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0110 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0140 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0160 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0170 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d01d0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d0220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1600 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1614 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1664 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1688 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1694 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1700 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1800 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1810 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d1820 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d20a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d20b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d20c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d22f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2420 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2440 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d24b0 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d25a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2740 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d2780 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d30a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d30b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d30c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d30d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179d3380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b20000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b24000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b2bff8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70008 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71008 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72030 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72060 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72080 0x88 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72138 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72178 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b73000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b73030 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b73050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b73060 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b73080 0x88 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b73138 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b73178 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b74000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b74e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c00004 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c01000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c02000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c02080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17dff000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e01000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b600468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b601000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b601010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b602000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b602010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b602018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b602040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b603000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b603010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b603018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b603020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b603028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1b604000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170a4000 0x8000 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a4000 0x8000 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17980000 0x8000 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17988000 0x800 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17990000 0x8000 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17998000 0x800 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c0000 0x8000 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x179c8000 0x800 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1bb00000 0x40000 > /sys/bus/platform/devices/soc:mem_dump/register_config
}

cpuss_spr_setup()
{
    spr_enable = `cat /sys/kernel/debug/dynamic_mem_dump/spr/enable`
    if [ "$spr_enable" != "1"]
    then
        return
    fi

    echo 1 > /sys/bus/platform/devices/soc:mem_dump/sprs_register_reset

    echo 1 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
}

init_dynamic_mem_dump()
{
    if [ "$debug_build" != true ]
    then
        return
    fi

    if [ ! -d "/sys/kernel/debug/dynamic_mem_dump" ]
    then
        mount -t debugfs none /sys/kernel/debug
    fi

    echo 1 >/sys/kernel/debug/dynamic_mem_dump/apps_scandump/enable
    echo 1 >/sys/kernel/debug/dynamic_mem_dump/cluster_cache/enable
    echo 1 >/sys/kernel/debug/dynamic_mem_dump/cpu_cache/enable
    echo 1 >/sys/kernel/debug/dynamic_mem_dump/cpucp/enable
    echo 1 >/sys/kernel/debug/dynamic_mem_dump/cpuss_cluster/enable
    echo 1 >/sys/kernel/debug/dynamic_mem_dump/cpuss_cpu/enable
    echo 1 >/sys/kernel/debug/dynamic_mem_dump/cpuss_reg/enable
    echo 1 >/sys/kernel/debug/dynamic_mem_dump/spr/enable
}

create_stp_policy()
{
    create_instance /config/stp-policy/coresight-stm:p_ost.policy
    chmod 660 /config/stp-policy/coresight-stm:p_ost.policy
    create_instance /config/stp-policy/coresight-stm:p_ost.policy/default
    chmod 660 /config/stp-policy/coresight-stm:p_ost.policy/default
    echo ftrace > /config/stp-policy/coresight-stm:p_ost.policy/default/entity
}

adjust_permission()
{
    #add permission for block_size, mem_type, mem_size nodes to collect diag over QDSS by ODL
    #application by "oem_2902" group
    chown -h root.oem_2902 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/block_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/block_size
    chown -h root.oem_2902 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/buffer_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/buffer_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/out_mode
    chown -h root.oem_2902 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/block_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/block_size
    chown -h root.oem_2902 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/buffer_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/buffer_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/out_mode

    chgrp shell /sys/bus/coresight/devices/*/enable_source
    chmod 660 /sys/bus/coresight/devices/*/enable_source
    chgrp shell /sys/bus/coresight/devices/*/enable_sink
    chmod 660 /sys/bus/coresight/devices/*/enable_sink
}

enable_cti_flush_for_etf()
{
    if [ "$debug_build" != true ]
    then
        return
    fi

    echo 1 > /sys/bus/coresight/devices/coresight-tmc-etf/stop_on_flush
    echo 1 > /sys/bus/coresight/devices/coresight-cti-swao/enable
    echo 0 24 > /sys/bus/coresight/devices/coresight-cti-swao/channels/trigin_attach
    echo 0 1 > /sys/bus/coresight/devices/coresight-cti-swao/channels/trigout_attach
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
enable_debug()
{
    echo "sun debug"
    find_build_type
    init_dynamic_mem_dump
    create_stp_policy
    adjust_permission
    enable_cti_flush_for_etf
    if [ "$ftrace_disable" != "Yes" ]; then
        enable_extra_ftrace_events
        enable_buses_and_interconnect_tracefs_debug
    fi
    enable_dcc
    enable_cpuss_register
    cpuss_spr_setup
    sf_tracing_disablement
}

enable_dcc
