---
layout: page
toc: false
title: Vitis Tutorial
---

### Previous: [Vivado Tutorial]({% link _pages/vivado_tutorial.md %})


## Create Vitis Projects

Run Vitis (`vitis`), and choose a workspace location. I used _lab_vitis/sw_ for my workspace location.


### Create the platform project

The platform project generates the _standalone_ software layer code, which provides a software layer to access hardware and processor features (timers, interrupts, etc) in a bare-metal environment.
  1. _File->New->Platform Project_.  
  2. Chose a _Platform Project name_.  I chose *625_hw*.  
  3. Browse to your _.xsa_ file name.  
<img src = "{% link media/tutorials/hw_platform.png %}" width="800">
  4. Click *Finish*.
  

2. Change the _stdout_ output.  By default, the output from your program will be sent over the physical UART pins present on the board.  But instead of having to connect a UART to the board, we will use the option that allows us to send stdout over an virtual UART using the JTAG (USB) connection.
  * Expand your platform project, and double click on the _platform.spr_ file.  Select the *standalone on ps7_cortexa9_0->Board Support Package*, and click _Modify BSP Settings_.  
<img src = "{% link media/tutorials/open_bsp.png %}" width="800">
  * In the _Board Support Package Settings_ popup, go to the _standalone_ menu, and change _stdout_ to use *coresight_comp_0*.  
<img src = "{% link media/tutorials/bsp_stdout.png %}" width="800">
  * Click _OK_ to close the window and save the BSP settings.

3. Build the BSP code.  Right click on your platform project and choose _Build Project_. 

### Create the application project
  1.  _File->New->Application Project_. 
  2. Chose your platform that you created in the last step.  
<img src = "{% link media/tutorials/vitis_application.png %}" width="800">
  3. Choose an application name (ie. HelloWorld), and continue through the next screens.
  4. On the _Templates_ screen, choose _Hello World_, and then click _Finish_.
  5. After you complete the wizard, build your application.  Right click on your application project and choose _Build Project_. 


## Run Your Applicaton on the Board
*  Right-click on your executable folder (down one level from the *_system* project created in the last step -- see image below), choose *Run As->Launch on Hardware (Single Application Debug*.  
<img src = "{% link media/tutorials/run_program.png %}" width="800">

* To view the program output, you will need to use the console selector button in the *Console window to select the *TCF Debug Virtual Terminal - ARM Cortex-A9 MPCore #0* console.  This is the JTAG console for core 0.
<img src = "{% link media/tutorials/select_console.png %}" width="800">

* You should see the message *Hello World*.

### Next:  [Vitis HLS Integration Tutorial]({% link _pages/hls_integration_tutorial.md %})
