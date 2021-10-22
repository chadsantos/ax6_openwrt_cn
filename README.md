# Re-packing of the [coolsnowwolf/lede](https://github.com/coolsnowwolf) OpenWrt for Redmi AX6  

## Some usefull links:  
https://www.right.com.cn/forum/thread-4875974-1-1.html  
https://www.right.com.cn/forum/thread-4111331-1-1.html  
https://qust.me/post/hong-mi-ax6-jie-suo-ssh-an-zhuang-shi-yong-shellclash-jiao-cheng/  

## Upgrade:  
1. Do the back up.  
2. In terminal:  
    >sysupgrade -v --force /tmp/openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-sysupgrade.bin  

## [Clear install from the stock firmware](https://www.right.com.cn/forum/thread-4111331-1-1.html):  
0. Get root and ssh access  
1. Copy the xiaomimtd12.bin file to router 192.168.31.1:  
    >scp ./firmware-osdk/xiaomimtd12.bin root@192.168.31.1:/tmp  

2. SSH Login to the router (192.168.31.1) and execute  
     >nvram set flag_last_success=0  
     nvram set flag_boot_rootfs=0  
     nvram set flag_boot_success=1  
     nvram set flag_try_sys1_failed=0  
     nvram set flag_try_sys2_failed=0  
     nvram set boot_wait=on  
     nvram set uart_en=1  
     nvram set telnet_en=1  
     nvram set ssh_en=1  
     nvram commit  

     >mtd write /tmp/xiaomimtd12.bin rootfs  
     reboot; exit  

3. Copy the a6minbib.bin file to router 192.168.1.1:  
    >scp ./firmware-osdk/a6minbib.bin root@192.168.1.1:/tmp  

4. SSH Login to router (192.168.1.1) and execute:  
    >. /lib/upgrade/platform.sh  
    switch_layout boot; do_flash_failsafe_partition a6minbib "0:MIBIB"  
    reboot; exit  

5. [Download the latest firmware version](https://github.com/uamarchuan/ax6_openwrt_cn/releases)  

6. Copy the openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi file to the router 192.168.1.1:  
    >scp ./openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi root@192.168.1.1:/tmp  

7. SSH Login to the router (192.168.1.1) and execute:  
    >ubiformat /dev/mtd13 -f /tmp/openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi  
    fw_setenv flag_last_success 1  
    fw_setenv flag_boot_rootfs 1  
    reboot; exit  

## Re-install from coolsnowwolf/lede OpenWrt to my OpenWrt version:  
1. Do the back up.  

2. SSH Login to router (10.0.0.1) and execute:  
    >ssh root@10.0.0.1  
    >>fw_setenv flag_last_success 0  
    fw_setenv flag_boot_rootfs 0  
    reboot; exit  

3. Copy the openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi file to the router (192.168.1.1):  
    > scp openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi root@192.168.1.1:/tmp/  

4. SSH Login to the router (192.168.1.1) OS/DK and execute:  
    > ssh root@192.168.1.1
    >> ubiformat /dev/mtd13 -f /tmp/openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi  
    fw_setenv flag_last_success 1  
    fw_setenv flag_boot_rootfs 1  
    reboot; exit  


# Changes
1) Modified default IP to 10.0.0.1
2) Replaced NTP server to Europe
3) Changed tme zone
4) Changed hostname to 'ax6'
5) Removed unnecessary packages
6) Added L2TP vpn connection (only need run: opkg install xl2tpd ppp-mod-pppol2tp)
7) Added official repositories
8) Added EN, RU and UK languages (EN is a default one)
9) Added kmod-wireguard
999) Installed additional soft: mc, iperf3


# OpenWrt usefull commands
**Update all packages:**  
>opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade