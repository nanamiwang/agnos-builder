# How to run AGNOS on Pixel 3
## Caution: The porting is still in very early stage, we still have some critical issues to fix. Please read the existing issues before continuing. Use at your own risk. 
https://github.com/nanamiwang/agnos-builder/issues

## Prerequisites
### Pixel 3A
### (Optional) USB type-C passthrough breakout board and USB to TTL adapter if you want to join the kernel development or report kernel bugs. Some
- https://github.com/Peter-Easton/android-debug-cable-howto
- Some $2 USD boards from taobao.com will also work
[TYPE-C male to female test board](https://item.taobao.com/item.htm?id=627260883778)

## Current progress
### The kernel work is based on Sultan's Pixel 3 kernel code.
https://github.com/nanamiwang/pixel3_kernel_sultan/tree/agnos-try
https://github.com/kerneltoast/android_kernel_google_bluecros

### Modifications to AGNOS system image for Pixel 3
https://github.com/nanamiwang/agnos-builder/tree/pixel3

### Modifications to OpenPilot for Pixel 3
- Currently the code is based 0.8.14 release3 branch, with some modification for Pixel 3
- https://github.com/nanamiwang/openpilot-private/tree/pixel3_agnos
- Currently OP is running in single camera mode, no driver monitoring camera and wide camera currently.

## Flash Android 9 images to Pixel 3, unlock the bootloader, install Magisk and root the device, you can follow George's instructions (Line 1 to line 24)
https://gist.github.com/geohot/569e9e4b20fd41203d8da71c6022be15


## Adjust partitions' size for flashing AGNOS images and run AGNOS
### Boot into Android 9, connect the phone to PC using type-C cable, and enter adb shell
```
adb shell
su
```
### Allow root access from Magisk popup.

### Show partition information before resizing
```
Disk /dev/block/sda: 15589376 sectors, 59.5 GiB
Logical sector size: 4096 bytes
Disk identifier (GUID): 00000000-0000-0000-0000-000000000000
Partition table holds up to 21 entries
First usable sector is 6, last usable sector is 15589370
Partitions will be aligned on 2-sector boundaries
Total free space is 248 sectors (992.0 KiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1               6               7   8.0 KiB     FFFF  ssd
   2               8             263   1024.0 KiB  FFFF  misc
   3             264             391   512.0 KiB   FFFF  keystore
   4             392             519   512.0 KiB   FFFF  frp
   5             520          721415   2.8 GiB     FFFF  system_a
   6          721416         1442311   2.8 GiB     FFFF  system_b
   7         1442312         1519111   300.0 MiB   FFFF  product_a
   8         1519112         1595911   300.0 MiB   FFFF  product_b
   9         1595912         1792519   768.0 MiB   FFFF  vendor_a
  10         1792520         1989127   768.0 MiB   FFFF  vendor_b
  11         1989128         2005511   64.0 MiB    FFFF  boot_a
  12         2005512         2021895   64.0 MiB    FFFF  boot_b
  13         2021896         2042375   80.0 MiB    FFFF  modem_a
  14         2042376         2062855   80.0 MiB    0700  modem_b
  15         2062856         2062919   256.0 KiB   FFFF  apdp_a
  16         2062920         2062983   256.0 KiB   FFFF  apdp_b
  17         2062984         2063047   256.0 KiB   FFFF  msadp_a
  18         2063048         2063111   256.0 KiB   FFFF  msadp_b
  19         2063112         2064135   4.0 MiB     FFFF  klog
  20         2064136         2068231   16.0 MiB    FFFF  metadata
  21         2068480        15589370   51.6 GiB    FFFF  userdata
```

### Resize system parititon to 15GB to accommodate AGNOS system image, and resize userdata partition to 23GB
```
sgdisk --delete=5 /dev/block/sda
sgdisk --delete=6 /dev/block/sda
sgdisk --delete=21 /dev/block/sda
sgdisk --new=5:2068480:6000641 --change-name=5:system_a --typecode=5:FFFF /dev/block/sda
sgdisk --new=6:6000642:9932803 --change-name=6:system_b --typecode=6:FFFF /dev/block/sda
sgdisk --new=21:9932804:15589369 --change-name=21:userdata --typecode=21:FFFF /dev/block/sda
```

### Delete production partition
```
sgdisk --delete=7 /dev/block/sda
sgdisk --delete=8 /dev/block/sda
```

### Create systemrw and cache partition
```
sgdisk --new=7:1442312:+16M --change-name=7:systemrw --typecode=7:FFFF /dev/block/sda
sgdisk --new=8:1519112:+128M --change-name=8:cache --typecode=8:FFFF /dev/block/sda
```

### Reboot and enter into fastboot mode
```
reboot bootloader
```

### Format some partitions
```
fastboot format:ext4 userdata
fastboot format:ext4 systemrw
fastboot format:ext4 cache
```

### Flash dsp partition image to vendor partitions, so that /dev/disk/by-label/dsp will appear in AGNOS
```
fastboot flash vendor_b dsp.bin
fastboot flash vendor_a dsp.bin
```

### Flash modem partitions
```
fastboot flash modem_b modem.img
fastboot flash modem_a modem.img
```

### Flash system/boot image to active partitions
```
fastboot flash system system.img
fastboot flash boot mhyboot.img
```

## Reboot the phone.

## If everything is ok, AGNOS will boot. You can connect the Wifi and ssh into the phone.

## Install OpenPilot using AGNOS installer.

## Replace the OpenPilot code
### TODO

## How to build the kernel and AGNOS system image.
### TODO

# TODO
### Fix all critical issues
### Since Sultan's Pixel 3 kernel is [outdated](https://github.com/kerneltoast/android_kernel_google_bluecross/commits/9.0.0-sultan), should we try agnos-kernel-sdm845 or mainline? 
### Porting the driver facing camera and the wide camera
