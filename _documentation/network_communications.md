---
layout: page
toc: false
title: Setting Up Network Communications
short_title: PYNQ Network
indent: 1
number: 5
---


## SSH Communication 
Once you have the PYNQ set up you can connect to it using SSH. 

If you are working in the lab, you can access the PYNQ board in the lab using:

    ssh xilinx@pynq03.ee.byu.edu
        
where the "03" is replaced with the number of the PYNQ board you are using.  **The default password is `byu`.**  

If working remotely, you will need to replace *pynq03.ee.byu.edu* with your PYNQ's IP address.





## SSH Keys
Instead of having to authenticate with a password each time connecting to the PYNQ, you can set up an SSH key to do automatic authentication.  [This tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-1804) explains how to set this up in a variety of ways.

A few of notes __before__ following the tutorial:
  * If your computer doesn't have `ssh-copy-id` installed, you will need to follow the instructions below that (the lab computers have it installed). 
  * Although it is less secure, it is nicer if you do not specify a passphrase for the key; this will give you secure, passwordless access to the PYNQ.  Presumably the host computer is protected by password, which makes not having a passphrase less of an issue
  * You probably don't want to follow Step 4 of the tutorial

**Before proceeding, make sure you can ssh into your PYNQ board without being prompted for a password.**

