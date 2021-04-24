---
layout: page
toc: false
title: Serial Communications
short_title: PYNQ Serial
indent: 2
number: 4
---

In the case that an `ssh` connection fails, or you don't know the board's IP address yet, you can also get command-line access to the PYNQ via UART connection over USB.  The board must be powered via a USB cable connected the host computer for this to work.

## Windows 
Find the serial port: 
  * Open *Device Manager*
  * In the *Ports* section, find the *USB Serial Port* device, and make note of the COM port number.  For example, it may be *COM6*.

Connect using [putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/)
  * Run putty
  * Switch to *Serial*
  * In the *Serial Line* box, enter the appropriate COM port number, eg. *COM6*
  * In the *Speed* box, enter 115200.
  * Click *Open*
  * You may need to hit *Enter* on your keyboard a few times for the PYNQ command prompt to appear.

## Linux or Mac 

Find the serial port: 
  * Run `ls /dev/ttyUSB*` (Linux) or `ls /dev/tty.*` (Mac)
  * Plug in the Pynq board via USB
  * Run the command again and see what is new.  It will probably be named /dev/ttyUSB0 or /dev/ttyUSB1 (different on Mac). There may be more than one new serial port connected, and you may need to try connecting to both.  (Usually it is USB1)

Connect with `screen`:
  * Run `sudo screen /dev/[port_name] 115200`
  * If it hangs, type ''Ctrl-a, k'' to kill the Screen session
  * Try the other port
  * You may need to hit *Enter* on your keyboard a few times for the PYNQ command prompt to appear.

While you may be tempted to use this UART connection for all of your work, we strongly advise against it.  It is slow and sometimes unreliable.  Use this to determine the IP address, and then connect via SSH.
