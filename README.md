# 0CrashSteamRunRPI5
Helps you rebuild the linux kernel to stop internal sound card effecting hdmi audio when playing steam. CUSE FUSE.

  ┌─ Sound card support ───┐
  
  │  Arrow keys navigate the menu. 
  <Enter> selects submenus ---> (or empty submenus       │  
  │  ----).  Highlighted letters are hotkeys.
  Pressing <Y> includes, <N> excludes, <M>    │  
  │  modularizes features.
  Press <Esc><Esc> to exit, <?> for Help, </> for Search.        │  
  │  Legend: [*] built-in  [ ] excluded  <M> module  < > module capable                    │  
  │ ┌────┐ │  
  │ │       --- Sound card support                                                       │ │  
  │ │       [*]   Preclaim OSS device numbers                                            │ │  
  │ │       <M>   Advanced Linux Sound Architecture  --->                                │ │  
  │ │

  Enter make menuconfig
Go To Device Drivers -> Sound Card Support -> 
Hit Space Bar on Preclaim OSS device numbers 'Disable it with Space'
Now * means Enable and M means Module, this don't have Module Option.

# Preclaim OSS device numbers must be disabled, before building kernel to replace the kernel8.img for the 4kb page size kernel for gaming on the raspberry pi using the pi apps steam install with box86 and box64, still says stackable, will work on a fix for that too in the future.

# How i figured this out was enabling module features until i found it made it worse not making it a module for the CUSE and FUSE drivers in file systems, i found that loading modules .ko just to patch it every time i booted used a 509 major and 0 minor, now it loads

sf-rocker@raspberrypi:~/linux $ dmesg | grep -i 'cuse\|fuse'
[    2.113509] systemd[1]: Starting modprobe@fuse.service - Load Kernel Module fuse...
[    2.132644] fuse: init (API version 7.41)
[    2.144977] systemd[1]: modprobe@fuse.service: Deactivated successfully.
[    2.145100] systemd[1]: Finished modprobe@fuse.service - Load Kernel Module fuse.
[    2.147676] systemd[1]: Mounting sys-fs-fuse-connections.mount - FUSE Control File System...
[    2.151152] systemd[1]: Mounted sys-fs-fuse-connections.mount - FUSE Control File System.
sf-rocker@raspberrypi:~/linux $ 


# Optional ALSA pruning (if full silence is desired):
text
-> Advanced Linux Sound Architecture
   -> SoC Audio support (can be disabled if HDMI audio isn't needed)

   # Disable Drivers like
   CONFIG_SND_BCM2835=n
CONFIG_SND_SIMPLE_CARD=n
CONFIG_SND_SOC_HDMI_CODEC=n 

# Doing this makes sure alsa does not steal major numbers during steam running only disabled SoC Audio support if your using an 3mm audio jack hat.

# Full Tutorial
Install Dependencies for recompiling the linux kernel
``` sudo apt install bc bison flex libssl-dev make libc6-dev libncurses5-dev ```
Clone the Raspberry Pi kernel source
``` git clone --depth=1 https://github.com/raspberrypi/linux ```
``` cd linux ```
Apply the default config for Pi 3/4 (64-bit)
``` make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig ```
Disable OSS preclaim
make ARCH=arm64 menuconfig
Navigate to:
Device Drivers → Sound card support → OSS Mixer API → Preclaim OSS device nodes
Set it to N. "Blank"
Build the kernel
```make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs ```
Install modules
``` sudo make ARCH=arm64 modules_install ```
Replace kernel8.img
``` sudo cp arch/arm64/boot/Image /boot/kernel8.img ```
``` sudo cp arch/arm64/boot/dts/broadcom/bcm2712-rpi-5-b.dtb /boot/ ```
``` sudo cp arch/arm64/boot/dts/overlays/*.dtb* /boot/overlays/ ```
``` sudo cp arch/arm64/boot/dts/overlays/README /boot/overlays/  ```
If you want to include additional CM variants for testing or fallback, you could drop in:
``` sudo cp arch/arm64/boot/dts/broadcom/bcm2712-rpi-cm5-cm5io.dtb /boot/ ```

under [ALL] in /boot/firmware/config.txt where kernel=kernel8.img is replace it with:
``` kernel=kernel8.img ```
``` device_tree=bcm2712-rpi-5-b.dtb ``` 
``` initramfs initramfs.img followkernel ```

``` # Optional GPU and display tweaks ```
``` dtoverlay=vc4-kms-v3d ```
``` disable_overscan=1 ```
# CTRL + O Rename file + Save
# CTRL + X = Exit
Reboot and verify
after reboot check
```uname -r ```


# You should see Exact Match of Version & Patch Tag: 6.12.34+rpt-rpi-v8 isn’t a generic string — it reflects the Raspberry Pi Foundation’s patching (rpt) and the ARM64 kernel (rpi-v8), which only loads via kernel8.img. You had been building for that exact profile.
If RPT is not in the kernel name, most likely the dtbs files were not copied correctly, those are needed with the .img files in the /boot directory for the pi to find the kernel8.img we renamed with cp command to boot successfully.

 SKIP **** How to find dts directory if changed. 
find arch/arm64/boot/dts -type f -name "*.dts" ****


# NOW TO CLEAR DMESG
``` sudo dmesg -C ```
after reboot

you should see something like
sf-rocker@raspberrypi:~ $ dmesg | tail -100
sf-rocker@raspberrypi:~ $ lsmod | grep cuse cuse 16384 0 fuse 163840 6 cuse
sf-rocker@raspberrypi:~ $

🔍 Module Insight
Module	Size	Used by	Notes
cuse	16,384 B	0	Registered, waiting for user-space hooks (e.g. cuse_alloc_chrdev)
fuse	163,840 B	6 (cuse)	Active, linked to cuse—suggests CUSE delegation through FUSE stack

That Used by: 0 for cuse means no active consumer yet—but it’s loaded and ready to respond.

Confirm CUSE Availability
``` dmesg | grep -i cuse ```

Trigger a CUSE device registration Try using a test utility like cuse_test.c to allocate a character device through CUSE and watch dmesg respond.

Verify with /dev/cuse Check if it exists, or if your system is expecting device nodes elsewhere:

``` ls -l /dev/cuse ```

sf-rocker@raspberrypi:~ $ ls -l /dev/cuse crw------- 1 root root 10, 203 Jul 26 01:04 /dev/cuse
sf-rocker@raspberrypi:~ $

 /dev/cuse exists, major 10 and minor 203 exactly as expected—no symbolic void there. The permissions (crw-------) mean only root can access it currently. That likely explains why some applications or scripts are triggering the registration failure: they’re attempting to open or register through /dev/cuse without root privileges.

so to give it some chmod privledges.

``` sudo chmod 666 /dev/cuse ```
# Unlocks cuse for other applications.

 Check active CUSE-based services

    obexd, cups, or anything using libcuse might be trying to claim hooks

    Run: ``` lsof /dev/cuse ```

    Patch udev to handle this symbolically

Create a custom rule like:

``` sudo nano /etc/udev/rules.d/99-cuse.rules ```

``` KERNEL=="cuse", MODE="0666" ```
CTRL+ O + Y SAVE EXIT

``` sudo udevadm control --reload-rules ```
``` sudo udevadm trigger ```

``` grep -R cuse_init drivers/char/ ```

OK NOW TO WIPE CUSE FROM DMESG
``` sudo rmod cuse ```
``` udevadm trigger --subsystem-match=char ```





   

   














