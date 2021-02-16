---
layout: lab
toc: true
title: Vitis HLS
number: 4
repo: lab_vitis_hls
---

## Learning Outcomes
The goals of this assignment are to:
* Gain experience using a commerical HLS tool, Xilinx's Vivado HLS tool.
* Observe how changes to the source code affect the resulting resource usage and performance.
* Explore HLS design optimization techniques, and the effect on resource usage and performance.
* Learn about a simple machine learning algorithm.

## Background

Handwriting recognition refers to the computer's ability to intelligently interpret handwritten inputs and is
broadly applied in document processing, signature verification, and bank check clearing. An important step in
handwriting recognition is classification, which classifies data into one of a fixed number of classes. In this lab,
you will design and implement a handwritten digit recognition system based on the **k-nearest-neighbors
(k-NN)** classifier algorithm [[wiki](https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm), [good youtube video](https://www.youtube.com/watch?v=UqYde-LULfs)].

In the assignment you are provided with a set of already classified handwritten digits (called the training sets), and will implement a k-NN algorithm in C++ that is able to identify any input handwritten digit (called the testing instance) using the training sets. In addition, you will use two commonly-used high-level synthesis (HLS) optimizations to parallelize the synthesized hardware and explore design trade-offs in performance and area. 

## Getting Started

### Install Dependencies


```
sudo apt install libc6-dev-i386 libtinfo5 libswt-gtk-4-java
```

### Code Organization
You are provided the following files:
* `digitrec.cpp`: an incomplete source file where you write your k-NN based digit recognition algorithm
in C++.
* `digitrec.h`: the header file that defines the interface for the core functions `update_knn` and `knn_vote`.
* `typedefs.h`: the header file that defines the key data types used in the design.
* `training_data.h`: the header file that contains all the training data.
* `test_data.h`: a set of test data with golden values for testing your prediction accuracy.
* `digitrec_test.cpp`: a test bench (only useful for simulation) that helps verify your code and perform
experiments with various handwritten input digits.
* `Makefile`: a makefile for you to easily compile source code into an executable named digitrec and execute
the program to check results (enter `make`).
* `run.tcl`: the template project Tcl script that allows you to run Vivado HLS synthesis in command line
(`vivado_hls -f run.tcl`). 


### Setting up Vitis HLS
For this assignment we will be using Vitis HLS. 
You can install Vitis on your local machine (<https://www.xilinx.com/support/download.html>).  If you do this, you should install Vitis 2020.2 on an Ubuntu 18.04 (or newer) machine.  

_Note: If you prefer, you can install Vitis on a Windows machine.  I haven't tested this.  It should work with the assignment, with a few extra considerations.  For example, the Makefile which has been provided to quickly compile and run your design may not work unless you have a build system setup.  You can still build and run within Vitis HLS, so it is not a big difference, but keep in mind you may run into problems such as this._

<!-- Vivado HLS requires a license.  You can access the department Xilinx license server by setting the following environment variable.  This means you must either be on the university network, or connected to the CAEDM VPN.

```
export LM_LICENSE_FILE=2100@ece-xilinx.byu.edu
``` -->

To run the Vitis tools you should do the following:
```
source /tools/Xilinx/Vitis_HLS/2020.2/settings64.sh
export LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LIBRARY_PATH
vitis_hls
```

The first step will add the Xilinx binaries to your `PATH`. I second step was needed on my machine to solve a bug (might not be needed with different Ubuntu versions).  The last command runs Vitis HLS.  If you don't want to setup your own machine, contact me and I can give you access to a server with Vitis 2020.2 installed.


### Vivado GUI vs command line
For this assignment you can use the Vivado HLS GUI, or you can work entirely via command line.  If you are using the GUI, create a new project with this configuration:
* Design Files: 
	* `digitrec.cpp` (Top Function: `digitrec`)
* TestBench Files: 
	* `digitrec_test.cpp`
	* `data` _(this is a folder)_
* Part: `xc7z020clg484-1`

When you are ready to collect results you can use the `run.tcl` script to automatically run C simulation and synthesis, and extract results for _k=1,2,3,4,5_.

```
vitis_hls -f run.tcl
```

If you look inside `run.tcl` you will see it creates five projects with the same properties as above, each with a different `k` value.

## Design Overview

**You are given 10 training sets, each of which contains 1800 49-bit training instances for a
different digit (0-9). Each hexadecimal string in *training_set_#* represents a 49-bit training
instance for digit #**. The 49 bits of each instance encodes a 7x7 matrix of binary values (i.e., a bitmap). For example, e3664d8e00<sub>16</sub> in *training_set_0* is a training instance for digit 0 and translates into the following binary 2D matrix and bitmap:

<img src="{% link media/vitis/binary_string0.png %}" height="200">
<img src="{% link media/vitis/img1.png %}" height="200" class="pixelated">

 41c0820410<sub>16</sub> in training set 7 is a training instance for digit 7 and translates into the binary 2D matrix and bitmap shown below:

<img src="{% link media/vitis/binary_string1.png %}" height="200">
<img src="{% link media/vitis/img2.png %}" height="200" class="pixelated">
 
As you can see, the resolution of the digit is limited by the number of bits (49 bits in our assignment) used to represent it. Typically, increasing the number of bits per instance would improve the resolution and possibly the accuracy of recognition. 

We would like to devise an algorithm that takes in a binary string representing a handwritten digit (i.e. the testing instance) and classify it to a particular digit (0-9) by first identifying *k* training instances that are closest to the testing instance (i.e., the nearest neighbors), and then determining the result based on the most common digit represented by these nearest neighbors. 

You are encouraged to read through the links provided above to familiarize yourself with the basic concepts of the k-NN algorithm. **In this assignment, we define the distance between two instances as the number of corresponding bits that are different in the two binary strings.** For example, 1011<sub>2</sub> and 0111<sub>2</sub> differ in the two most significant bits and therefore have a distance of 2. 1011<sub>2</sub> and 1010<sub>2</sub> differ only in the least significant bit and have a distance of 1. As a result, 1011<sub>2</sub> is closer to 1010<sub>2</sub> than to 0111<sub>2</sub>.

## Implementation

### Coding and Debugging
Your first task is to complete the digit recognition algorithm based on the code skeleton provided in `digitrec.cpp`. In particular, you are expected to fill in the code for the following functions:

* `update_knn`: Given the testing instance and a (new) training instance, this function maintains/updates an array of *k* minimum distances per training set.
* `knn_vote`: Among *10&middot;k* minimum distance values, this function finds the *k* nearest neighbors and determines the final output based on the most common digit represented by these nearest neighbors.

Note that the skeleton code takes advantage of arbitrary precision integer type `ap_uint`. \textbf{A useful reference of arbitrary precision integer data types can be found starting on p.144 and p.485 of the [user guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1399-vitis-hls.pdf).

How you choose to implement the algorithm may affect the resulting accuracy of your design as reported by the test bench. **We expect that your design would achieve an error of less than 10% on the provided testing set**. You may use the console output or the generated *out.dat* file to debug your code.

### Design Exploration
The second part of the assignment is to explore the impact of the *k* value on your digit recognition design. Specifically, you are expected to experiment with the *k* values ranging from 1 through 5, and collect the performance and area numbers of the synthesized design for each specific *k*.
* The actual *k* value can be provided to the Makefile (`make K=4`) and changed in *run.tcl*. You can run simulation and synthesis in batch with *run.tcl*. This script will also automatically collect important stats (i.e., accuracy, performance, and resource usage) from the Vivado HLS reports and generate a \emph{knn\_result.csv} file under the result folder.
* In this assignment, you will use a fixed 10ns clock period targeting a specific Xilinx Zynq FPGA device. Clock period and target device have been specified in the run Tcl script.


### Design Optimization
The third part of the assignment is to optimize the design with HLS pragmas or directives. In particular, we
will focus on exploring the effect of the following optimizations in our design and apply them appropriately
to **minimize the latency of the synthesized design**.
* **loop pipelining**: Allows for overlapped execution of loop iterations by leveraging pipelining techniques.
* **loop unrolling**: unfolds a loop by creating multiple copies of its loop body and reducing its trip count accordingly. This technique is often used to achieve shorter latency when loop iterations can be executed in parallel.
* **array partitioning**: partitions an array into smaller arrays, which may result in an RTL with multiple small memories or multiple registers instead of one large memory. This effectively increases the amount
of read and write ports for the storage.

Please refer to the [user guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug1399-vitis-hls.pdf) for details on how to apply these optimizations.  You may insert pragmas or set directives to apply optimizations. You can find code snippets with inserted pragmas throughout the user guide, and a full reference is given in Chapter 4.

**Your proposed solution must meet the clock period constraint, and must not exceed the resources available on the targeted FPGA (xc7z020clg484-1).**

For the sake of simplicity, please try to only use fixed-bound
*for* loop(s) in your program. Note that data-dependent *for* and *while* loops are synthesizable but may lead to a variable-latency design that would complicate your reporting (*You would need to perform C-RTL co-simulation to get the actual cycle count for a design with data-dependent loop bounds*).

## Class Results
On Slack I will post a link to a Google Sheets document where you should post the results of your best solution.  There will be two categories for rankings:
* **Minimum Latency:** Minimum latency provided the design fits within the resources constraints of the chip, and achieves 90% accuracy. 
* **Most resource efficient:**  The goal in this category is to minimize the expression _r<sup>2</sup> &#xb7; L_, where _r_ is the resource usage and _L_ is the total latency.  The resource usage will be defined as the maximum fraction of resource usage for any given resource type (BRAM, DSP, FF, LUT).
 

## Report

Include a short report located as `lab_vitis_hls/report.pdf` with the following:
* Describe how you implemented the *update_knn* and *knn_vote* functions.
* Compare different _k_ values with a table that summarizes the key statistics including the error rate (accuracy), area in terms of resource utilization (number of BRAMs, DSP48s, LUTs, and FFs), and and performance in latency in number of clock cycles. Use the csv file generated by the script, or manually inspect _knn.prj/solution1/syn/report/_.  
* Describe how you added HLS pragmas/directives to minimize the latency of the synthesized design. Please contrast the performance and area of your most optimized design (i.e., with smallest latency) with the baseline design. For this comparison, you only need to set _k_ to 3.
* Use charts, snippets of code, or any other presentation techniques to communicate your design decisions and results.
			
## Submission

Submit your code using tag `lab4_submission`.

## Acknowledgement
This assignment was originally written by Professor Zhiru Zhang from Cornell University.  I have modified it slightly for our class.  The design was originally created by Professor Zhang's students, Ackerley Tng and Edgar Munoz.

