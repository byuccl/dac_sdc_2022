---
title: Lab Setup
layout: page
toc: true
icon: fas fa-wrench
---

## Prerequisite Skills
In this class you are expected to be familiar with the Linux command line, Git and Github.  If you haven't used these tools before, here are links to a few tutorials:

* <https://ryanstutorials.net/linuxtutorial/>
*	[Learn Git in 15 minutes](https://www.youtube.com/watch?v=USjZcfj8yxE)
* [Learn Github in 20 minutes](https://www.youtube.com/watch?v=nhNq2kIvi9s)

## Environment

The assignments assume you are running an Ubuntu 20.04 Linux Operating System.  You may be able to complete some assignments on other Linux variants; however, for the assignments that use the Xilinx Vivado tools, you will need a supported operating system (Ubuntu 18 LTS may work as well).

If you don't yet have a Linux OS environment set up, I would suggest doing so for use in this assignment, and subsequent assignments.  A few options:
* VMWare Workstation is available for free to BYU students through [CAEDM](https://caedm.et.byu.edu/wiki/index.php/Free_Software). It's very easy to set up your own Ubuntu virtual machine.
* You can run Ubuntu from a USB drive or external hard drive.
* You install a full Ubuntu image (including Xilinx tools) in Windows using [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10).  
* You can set up a computer with Linux, or even dual-boot Linux and Windows/MacOS (dual-boot is a bit more complicated than these other options).
* Alternatively, I have a server available that you can ssh into.  You will have to be connected to the CAEDM VPN to use this, so if you choose this option, make sure you have a good internet connection. If you want to go this route, please email me your desired username and I will create a login for you.

## Tools
You are welcome to use whatever development tools you like, but a few things I suggest you look into:
* VS Code for code editing.
* Using SSH keys with Github to avoid having to enter your password when pushing your code up.

## Class Repository
1. You must use this invitation link to set up a Github classroom repo for the class: <https://classroom.github.com/a/B3CVEv7k>

2. This will create a blank repository for you.  On the github website for your repo, click the **Import Code** button (shown below), and import from <https://github.com/byu-cpe/ecen625_student>.
![Screen shot of how to import code]({% link assets/import-code.png %})
3. Clone your repository to your local machine.  


## Getting Code Updates
If for some reason, I need to fix a problem with the starter code, you will need a way of pulling those changes down onto your computer. The easiest approach is to create another remote for your git repo. By default, you will have one remote, `origin`, which will point to your GitHub repo. Add another one using the following command:

```
  git remote add template [URL OF LAB TEMPLATE REPO]
```

If you ever need to pull down changes I made (I will let you know when this is the case), you can do the following:

```
git fetch template
git merge template/master
```

## Submitting Code
Lab submissions will be done by creating a tag in your Git repository.  You can do this like so:

```
git tag lab1_submission
git push origin lab1_submission
```

If, after you create this tag, you want to change it (ie, re-submit your code), you can re-run the above commands and include the --force option, ie:
```
git tag --force lab1_submission
git push --force origin lab1_submission
```