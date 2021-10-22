#!/bin/sh
#
# Auto flash upgrades
# 23.09.2021 Andrii Marchuk
#

echo "--> Are you ready to upgrade?"
read -rsp $'Press \'c\' key to continue:' -n1 key
if [ "$key" = 'c' ]; then
    echo '\n'
    echo '--> Clear ssh known_hosts file\n'
    sed -i -e '/^10.0.0.1.*/d' ~/.ssh/known_hosts
    sed -i -e '/^192.168.1.1.*/d' ~/.ssh/known_hosts
    sed -i -e '/^192.168.10.1.*/d' ~/.ssh/known_hosts
    sed -i -e '/^192.168.31.1.*/d' ~/.ssh/known_hosts
    sed -i -e '/^192.168.0.1.*/d' ~/.ssh/known_hosts

    echo '--> Reboot to OS/DK...\n'
    ssh root@10.0.0.1 'fw_setenv flag_last_success 0; fw_setenv flag_boot_rootfs 0; reboot'
    echo '\n>>> Wait for a new IP assignment...\n'
    read -rsp $'Press \'c\' key when you have a new IP from OS/DK...:' -n1 key
    echo "\n"
    if [ "$key" = 'c' ]; then
      # copy new firmware to router
      if [ -d "$1" ]; then
        scp $1/openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi root@192.168.1.1:/tmp/
      else
        scp openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi root@192.168.1.1:/tmp/
      fi

      # start flashing it
      echo "\n"
      ssh root@192.168.1.1 'ubiformat /dev/mtd13 -f /tmp/openwrt-ipq807x-generic-redmi_ax6-squashfs-nand-factory.ubi'
      echo "\n-->Check the log above!!!\n"
      read -rsp $'Press \'c\' key when you are ready to reboot:' -n1 key
      echo "\n"
      if [ "$key" = 'c' ]; then
        ssh root@192.168.1.1 'fw_setenv flag_last_success 1; fw_setenv flag_boot_rootfs 1; reboot'
        echo '\n--> Clear ssh known_hosts file\n'
        sed -i -e '/^10.0.0.1.*/d' ~/.ssh/known_hosts
        sed -i -e '/^192.168.1.1.*/d' ~/.ssh/known_hosts
        sed -i -e '/^192.168.10.1.*/d' ~/.ssh/known_hosts
        sed -i -e '/^192.168.31.1.*/d' ~/.ssh/known_hosts
        sed -i -e '/^192.168.0.1.*/d' ~/.ssh/known_hosts

        echo '--> Do you want to Restore Backup? Yes, wait for a new IP assignment...\n'
        read -rsp $'Press \'c\' key to continue:' -n1 key
        echo "\n"
        if [ "$key" = 'c' ]; then
          ssh root@10.0.0.1 'opkg remove luci-i18n-*-zh-cn'
          scp backup-*.tar.gz root@10.0.0.1:/tmp/
          ssh root@10.0.0.1 'sysupgrade -v -r /tmp/backup-*.tar.gz && reboot'
          echo '\n--> Done! Reboot!'
        else
          echo '\n--> Done! Use your OpenWrt!'
          exit
        fi
      else
          exit
      fi
    else
        exit
    fi
else
    exit
fi