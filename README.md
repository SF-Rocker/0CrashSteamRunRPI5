# Tutorial using sudo with read and write permissions for everyone, to use steam on startup.
1. Move Downloaded .sh bash script to Documents folder.
2. Move Downloaded .service file to this exact location: --> ("/etc/systemd/system/") # Where services Go
3. or
4. Open Terminal Type
5. ```cd Downloads ```
6. ```ls```
7. and then copy the files .sh or .services
8. for .sh bash script type ```mv StartUp.sh /Documents```
9. for .service file type ```ls``` again to make sure your in the same Downloads Directory &
10. type ```mv StartUp.service /etc/systemd/system```
11. use vim, nano or ed to modify Errors, replace $USER with actual name of direcory
also to make this work you need to have bash-language-server installed using snap by canonical.
```sudo apt-get install snap```
after reboot CTRL + ALT T = OPENS TERMINAL WINDOW
type ```sudo snap install core```
after finished and completed type ```clear```
then run ```sudo snap install bash-language-server```
    & in the Documents folder go there now
    ```cd -``` #Goes back 1 directory or to the previous one.
    ```cd Documents```
    run ```sudo ./StartUp.sh```
    to see what code its throwing out you
    run ```ls -l /dev/cuse``` if you are successful it should show
    ```crwxrwxrwx 1 root root 10, 203 $DATE $TIME /dev/cuse```
    if it shows ```crw------- 1 root root 10, 203 $DATE $TIME /dev/cuse```
    then you must have an error and manually debug it yourself, and make sure your kate text editor does't show any errors when launching.
    
