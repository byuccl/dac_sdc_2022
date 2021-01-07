---
layout: lab
toc: true
title: Vitis
number: 5
repo: lab_vitis
---


# !!! This Lab is a Work in Progress !!!


\input{../../../Academic/latex/asst_template.tex}


\class{ECEN 625}
\term{Winter 2019}
\assttitle{Assignment 4B -- HLS in an SoC Environment}
\duedate{Tuesday, March 12, 2019 11:59pm}


\setuppage

\makeatletter
\@ifpackageloaded{biblatex}{\addbibresource{references.bib}}{\bibliography{references}}
\makeatother

\begin{document}

\maketitle
\thispagestyle{fancy}

\section{Learning Outcomes}
The goals of this assignment are to:
\begin{itemize}
	\item Test your HLS hardware from the last lab, and implement it on an SoC platform.
	\item Learn how to connect Vivado HLS cores in a larger Vivado hardware project.
	\item Learn how to call HLS accelerators from software in an SoC environment.
	\item Measure performance of your HLS accelerator.
\end{itemize}

\section{Implementation}

\subsection{Interfacing with HLS from software}
\textbf{Step 1: } Export your HLS IP to RTL, include it in an SoC Vivado project, and write software to run your accelerator.

There is a tutorial posted on the course website that walks through configuring a Xilinx SoC device in Vivado and writing ``Hello World'' software to run on the device using Xilinx SDK.  The tutorial also describes how to include your HLS IP in a Vivado project and how to communicate with it from software running on the embedded ARM processor.


\subsection{Measuring Execution Time}

\textbf{Step 2:} Run your baseline C code using the ARM processor, and measure execution time.

\textbf{Step 3:} Run your lowest latency accelerator created in HLS, and measure execution time.

There are a few different ways you can perform high-resolution timing on your board.  A few alternatives:
\begin{enumerate}
	\item For the 7-series ZYNQ, the ZYNQ global timer (xtime\_l.h) 
	\item For the 7-series ZYNQ, the per-core private timer (xscutimer.h)
	\item Adding an AXI Timer to the FPGA fabric (\url{https://www.xilinx.com/support/documentation/ip_documentation/axi_timer/v2_0/pg079-axi-timer.pdf})
	
	If you are using an MPSoC platform, the A53 also has public/privates timers that can be used.  Be sure you understand the API for these timers so that you know you are measuring time accurately. 
\end{enumerate}

\subsection{Exploring Interfaces}
The way your kNN accelerator is currently configured, the training samples are stored within the accelerator, which means they are implemented using the FPGA fabric, likely using the BRAMs.

\textbf{Step 4:} Modify your design in order to build a system where the training data is stored within main memory.  To do this, the training arrays should be declared in your software code, not in the code that is synthesized to hardware.

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

