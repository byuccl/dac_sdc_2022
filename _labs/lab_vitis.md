---
layout: lab
toc: true
title: Vitis
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


### Part 3: Exploring Interfaces 
The way your kNN accelerator is currently configured, the training samples are stored within the accelerator, which means they are implemented using the FPGA fabric, likely using the BRAMs.

Modify your design in order to build a system where the training data is stored within main memory.  To do this, the training arrays should be declared in your software code, not in the code that is synthesized to hardware.
# Work in progress

The Vivado HLS manual contains descriptions of how you can alter the interfaces to your IP block (\emph{Managing Interfaces}, p.85).  At this point you should have already changed the \emph{Block-Level Interface Protocol}, when you add the interface directive to control your HLS core using an AXILite slave connection.

In order for your HLS core to receive the training data, you will likely have to add a new argument to your function.  You must then decide how you want to provide training data to your HLS core through this new argument, that will become a port on the hardware block.  The section on \emph{Port-Level Interface Protocol}  (p.87) discusses this in detail.  The table on p.90 is a good starting point.  It is completely up to you how you implement this, and what protocols you would like to explore.

If you're not sure where to start, try something like this:
\begin{enumerate}
	\item Add a pointer or array argument to your function to provide the training data.
	\item Configure the interface for this port to be an memory-mapped AXI Master (\emph{m\_axi}), and modify your Vivado project to give the new master port access to the main memory, \emph{\textbf{OR}}
	\item Configure the interface for this port to be an AXI Stream (\emph{axis}), and add a DMA core to your Vivado project that can read data from main memory and send it over an AXI Stream.
		
\end{enumerate}

In either case, if you haven't already done so, you will need enable the AXI high performance slave interface on the PS (\emph{S\_AXI\_HP0}), which will allow the cores in the PL (master interface on your HLS core or the DMA core) to access the main memory contained in the PS.


\textbf{Step 5:} Once configured, run this modified system and measure its runtime.

\section{Report}


\begin{enumerate}
\item Submit a report containing the following items:
\begin{itemize}
	  \item Your name
		\item \textbf{Hardware Implementation.} Describe your initial steps of implementing your HLS core on the board. 
		
		\begin{enumerate}
			\item What board did you use?
			\item What version of your HLS accelerator did you use?  For example, you may find your largest configuration does not actually fit on the FPGA.  
			\item What steps did you perform to verify that your HLS core was operating correctly?
		\end{enumerate}
		\item \textbf{Runtimes.}  Provide data, compare and comment on:
		
		\begin{enumerate}
			\item Measured runtime of the software implementation using the ARM processor (Step 2)
			\item Predicated runtime of your HLS core, based on the latency values reported by the Vivado HLS tool, before implementation in hardware.
			\item Measured runtime of your HLS core (Step 3)			
		\end{enumerate}
		
		Be sure to describe the method you employed to measure run-time and discuss how confident you are that your measurements are correct.
		
		\item \textbf{Interfaces.} 
		
		\begin{enumerate}
			\item Describe the approach you used to provide training data from main memory to your HLS accelerator. 
			\item Include HLS resource usage before/after making this change, to demonstrate that BRAMs are no longer being used for the training data.
			\item Include screenshots, where helpful, of your Vivado block design.
			\item Provide runtime data for this configuration, and comment on how it compares to the previous approach of storing training data within the accelerator.  
			\item What are the advantages and disadvantages of storing the data in the hardware accelerator versus in main memory?
		\end{enumerate}
		
		\item Use charts, snippets of code, or any other presentation techniques to communicate your design decisions and results.
			
		\item Any feedback you want to share.
		
		
\end{itemize}

\item Submit your files.  This should include:
\begin{enumerate}
	\item Your PDF report.
	\item Your ARM application source code.
	\item Your HLS source code, and directives file.
	\item A screenshot of your Vivado block diagram.
	\item Your Vivado project in TCL form (run \texttt{write\_proj\_tcl} in the Vivado console to generate a single TCL file of your project).
\end{enumerate}

\end{enumerate}



\section{Submission Instructions}
Submit your report and source code to \href{mailto:jgoeders@byu.edu}{jgoeders@byu.edu} with the subject: 625 Asst4B


\renewcommand*{\bibfont}{\footnotesize}
\printbibliography[heading=bibintoc]

\end{document}

