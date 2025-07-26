# 0CrashSteamRunRPI5
Helps you rebuild the linux kernel to stop internal sound card effecting hdmi audio when playing steam. CUSE FUSE.

  ┌────────────────────────────────── Sound card support ──────────────────────────────────┐
  │  Arrow keys navigate the menu.  <Enter> selects submenus ---> (or empty submenus       │  
  │  ----).  Highlighted letters are hotkeys.  Pressing <Y> includes, <N> excludes, <M>    │  
  │  modularizes features.  Press <Esc><Esc> to exit, <?> for Help, </> for Search.        │  
  │  Legend: [*] built-in  [ ] excluded  <M> module  < > module capable                    │  
  │ ┌────────────────────────────────────────────────────────────────────────────────────┐ │  
  │ │       --- Sound card support                                                       │ │  
  │ │       [*]   Preclaim OSS device numbers                                            │ │  
  │ │       <M>   Advanced Linux Sound Architecture  --->                                │ │  
  │ │

  Enter make menuconfig
Go To Device Drivers -> Sound Card Support -> 
Hit Space Bar on Preclaim OSS device numbers 'Disable it with Space'
Now * means Enable and M means Module, this don't have Module Option.

#Preclaim OSS device numbers must be disabled, before building kernel to replace the kernel8.img for the 4kb page size kernel for gaming on the raspberry pi using the pi apps steam install with box86 and box64, still says stackable, will work on a fix for that too in the future.

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

# Doing this makes sure alsa does not steal major numbers during steam running only disabled soC if your using an 3mm audio jack hat.




