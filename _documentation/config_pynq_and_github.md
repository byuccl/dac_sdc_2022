---
layout: page
toc: false
title: Configuring PYNQ and Creating your Github Repo
short_title: PYNQ & Github
indent: 1
number: 7
---


## Change Passwords 

If you are only working from home, you can skip to the next step, otherwise, if you are working in the lab, you should change your password.  This is not just to prevent people from looking at your work, it also prevents another student from accidentally SSH'ing in your PYNQ board and modifying your files.

Change the *byu* user password by running the `passwd` command.

<!-- There are a couple passwords that need to be changed:
  - Change the ''byu'' user password
    - SSH into the PYNQ
    - Run `passwd` (default ''byu'' password is ''byu'') -->
  <!-- - Change the root password
    - SSH into the PYNQ
    - Change to root: `su`  (default root password is xilinx)
    - Run ''passwd'' -->

## Extend your Partition 

You should extend the PYNQ filesystem to fill your entire SD card (by default the filesystem only provides a small amount of free space, and doesn't fill your SD card)

Run these commands.  Please copy and paste them one at a time, and be careful in the process.  It's easy to mess up your entire SD card image:

```
sudo growpart /dev/mmcblk0 2
sudo resize2fs /dev/mmcblk0p2
```

<!-- ## Set PYNQ time 

Run the following to update the time on your PYNQ

    sudo apt install chrony
    sudo chronyc -a 'burst 4/4'
    sudo chronyc -a makestep    
    sudo timedatectl set-timezone America/Boise
    
    
This will fix the current time of the PYNQ, but if you have your PYNQ off for some extended period, and then turn it back on, you will may notice the time is wrong.   -->

## Create your Git Repo
 1. Sign up for your Github classroom repo using this link: <https://classroom.github.com/a/G4EftSD6> This will create an empty private repository on Github for you to use throughout the entire semester. **You must create your repository using this link, or the TAs will not be able to grade your code.**

2. You should now see the message below.  Click the link to navigate to your repository.
<img src = "{% link media/setup/git_classroom1.png %}" width="800" >
  
3. You repository will begin empty, and you should see a message like below.  Click the button shown below to import the starter code into your repository.  When it asks for a URL, use `https://github.com/byu-cpe/ecen427_student`
  <img src = "{% link media/setup/git_classroom2.png %}" width="1000" >

4. Your repo is now set up and ready to go.  You can make note of the URL.  If you forgot, you can always return to  <https://github.com> and it should show your repositories on the left-hand side.
  
## Create SSH Key on the PYNQ 

  - Connect to your PYNQ board via SSH
  - Create an SSH key on the PYNQ using `ssh-keygen`.  **This is different than the key you created on your workstation**.  You can go back to the section on [SSH Keys]({% link _documentation/network_communications.md %}#ssh-keys) if you need to to review how to do this, but it's as simple as calling `ssh-keygen` and hitting *Enter* a bunch of times.
  - Go to <https://github.com/settings/keys>, and add your public key to your Github account using the *New SSH key* button.  Remember you can view your newly created key using `cat ~/.ssh/id_rsa.pub`, then simply copy and paste into Github.
  - This will allow you to commit to your Github repo without needing to enter a password each time.

## Clone your Repo on the PYNQ

  - Go to your newly created repo.  
  - Click the **Code** button, and then the **Use SSH** link, as shown here: 
    <img src = "{% link media/setup/git_classroom3.png %}" width="800" >

  - Copy the URL that is shown.  It should be something like: *git@github.com:byu-cpe-classroom/427-labs-\<your_id\>.git*
  - SSH to your PYNQ, clone the repository into the ''ecen427'' directory:  

        ssh pynq
        git clone git@github.com:byu-cpe-classroom/427-labs-<your_id>.git ~/ecen427



## Configure Git 

Since this is the first time using Git on the PYNQ system, you need to configure it.  Run these commands (**making sure to enter your name and email**):
```
git config --global user.name "Your Name"
git config --global user.email your_email@example.com
```

### Add Starter Code Remote 

  - When you clone your repo, Git will create a *remote* called *origin* that is connected to your repo. 
  - You can view your remotes by typing `git remote`, and even check the linked URL by typing `git remote get-url origin`.
  - Next, you should add a new remote.  You can call it whatever you like, but a good name is *startercode*.  This remote will link to the starter code repository.  This will allow you to retrieve any updates I make to the code provided to you (I will probably need to make some updates to the code during the semester).  You do this like so:

        git remote add startercode https://github.com/byu-cpe/ecen427_student


Then, if you ever need to pull down changes I make, you can do the following to fetch the latest changes from the starter code and merge them into your code:
  
    git fetch startercode
    git merge startercode/master
