---
layout: lab
toc: true
title: Vitis Integration
number: 5
repo: lab_vitis
---





## Learning Outcomes
The goals of this assignment are to:
* Test your HLS hardware from the last lab, and implement it on an SoC platform.
* Learn how to connect Vivado HLS cores in a larger Vivado hardware project.
* Learn how to call HLS accelerators from software in an SoC environment.
* Measure performance of your HLS accelerator.

## Preliminary

In this lab you will export your HLS accelerator as an IP to include in a Vivado project on the FPGA.  You will then create an embedded software application in Vitis (different from Vitis HLS), that will communicate with your accelerator.  

Most of the direction for this lab are included in a set of tutorial pages.  Depending on your experience you may need to complete some or all of these tutorials in order to complete this lab:
* [Vivado Tutorial]({% link _pages/vivado_tutorial.md %}): Tutorial on creating a block-design Vivado project with the ARM processor.
* [Vitis Tutorial]({% link _pages/vitis_tutorial.md %}): Running a bare-metal *Hello World* application in Vitis.
* [HLS Integration Tutorial]({% link _pages/hls_integration_tutorial.md %}): Exporting your HLS accelerator as an AXI4 IP and integrating it into your hardware and software projects.

## Implementation

### Part 1: System Setup
As described in the tutorials, export your HLS IP to RTL, include it in an SoC Vivado project, and write software to run your accelerator.  You can use any version of your HLS IP from the last lab (ie, unoptimized, min area, min latency, etc.)
  * Add your Vivado project Tcl file to your Git repo in the *lab_vitis/hw* folder.
  * Add your IP files to your Git repo in the *lab_vitis/ip* folder.

### Part 2: Measuring Execution Time

You are provided with an incomplete [main.cpp](https://github.com/byu-cpe/ecen625_student/blob/main/lab_vitis/sw/main.cpp) that is similar to the test program used in the last lab.  It will test the accuracy of your accelerator with the same set of test data.  Complete the rest of the program and measure the runtime of your accelerator.

There are a few different ways you can perform high-resolution timing on your board.  A few alternatives:
* For the 7-series ZYNQ, the ZYNQ global timer *xtime_l.h*
* For the 7-series ZYNQ, the per-core private timer *xscutimer.h*
* Adding an AXI Timer to the FPGA fabric (\url{https://www.xilinx.com/support/documentation/ip_documentation/axi_timer/v2_0/pg079-axi-timer.pdf})
* If you are using an MPSoC platform, the A53 also has public/privates timers that can be used.  Be sure you understand the API for these timers so that you know you are measuring time accurately. 

In order to minimize the time spent in software, you should disable any printing while timing your code (set `logging` to `false`), and you should set compiler optimizations to *O2* or *O3*.  You can enable compiler optimizations in Vitis by right-clicking your application project (ie, *625_lab5*, not *625_lab5_system*), selecting *Properties*, and in the popup navigate to *C/C++ Build->Settings->Tool Settings->ARM v7 g++ compiler->Optimization*.

### Part 3: Software Runtime

Replace the call to your hardware accelerator with a software implementation of the function.  You should be able to use your existing HLS code with some minor modifications.  Measure and collect the runtime.


### Part 4: Exploring Interfaces 
The way your kNN accelerator is currently configured, the training samples are stored within the accelerator, which means they are implemented using the FPGA fabric, likely using the BRAMs.

Modify your design in order to build a system where the training data is stored within main memory.  To do this, the training arrays should be declared in your software code, not in the code that is synthesized to hardware.

The [Vitis HLS manual](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1399-vitis-hls.pdf) contains descriptions of how you can alter the interfaces to your IP block (Chapter 15: Managing Interface Synthesis).  At this point you should have already changed the *Block-Level Interface Protocol*, when you added the interface directive to control your HLS core using an AXILite slave connection.

In order for your HLS core to receive the training data, you will have to add a new argument to your function, `const digit training_data[]`.  You must then decide how you want to provide training data to your HLS core through this new argument, that will become a port on the hardware block.  The section on *Port-Level I/O Protocols* discusses this in detail.  You probably want to implement either an *AXI4-Stream interface* or *AXI4 master*.  It is completely up to you how you implement this, and what protocols you would like to explore.  Make sure you read the section titled *Using AXI4 Interfaces*.

If you're not sure where to start, try something like this:
1. Add a pointer or array argument to your function to provide the training data.
2. Choose between a memory-mapped or streaming interface:
	* Memory Mapped:
		*  Configure the interface for this port to be an memory-mapped AXI Master (*m_axi*)
		* Read about how the master port determines the address offset to use, and configure your interface appropriately.
		* Modify you your Vivado project to add a Slave interface (*HP Slave AXI Interface*) on your *ZYNQ7 Processing System*.  This gives a different block access to the DRAM. 
		* Connect your new AXI master port in your HLS IP to this port.give the new master port access to the main memory.
	* Streaming:
		* Configure the interface for this port to be an AXI Stream (\emph{axis})
		* Add a DMA core to your Vivado project that can read data from main memory and send it over an AXI Stream to your IP core.
		* Modify you your Vivado project to add a Slave interface (*HP Slave AXI Interface*) on your *ZYNQ7 Processing System*.  This can be used to give the DMA core access to the DRAM. 

**Bug Reminder**: Just a reminder of the Vitis HLS 2020.2 driver [Makefile bug]({% link _pages/hls_integration_tutorial.md %}).  When you export your new IP core, remember to fix the Makefile.

Once configured, create a Vitis software application that will run this modified system and measure its runtime.

## Report
Include a short PDF report, located at `lab_vitis/report.pdf`.  Include the following items:
* Briefly describe your hardware implementation.  What board did you use?  What version of your HLS accelerator did you use?  For example, you may find your largest configuration does not actually fit on the FPGA.  How did you verify that your HLS core was operating correctly?
		
* **Runtimes:**
	* Provide software-only runtime (from Part 3)
	* Provide accelerated runtime (from Part 2).  Does the per item runtime match the latency reported by Vivado HLS? (it should be pretty close)

* **Interfaces:**
	* Describe the approach you used to provide training data from main memory to your HLS accelerator. 
	* Include HLS resource usage before/after making this change, to demonstrate that BRAMs are no longer being used for the training data.
	* Provide runtime data for this configuration, and comment on how it compares to the previous approach of storing training data within the accelerator.  
	* What are the advantages and disadvantages of storing the data in the hardware accelerator versus in main memory?

## Submission 
Submit your code on Github using the tag `lab5_submission`
 
	


