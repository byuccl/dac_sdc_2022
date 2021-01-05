---
layout: lab
toc: true
title: Vivado HLS
number: 4
repo: lab_vivado_hls
---


# !!! This Lab is a Work in Progress !!!

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

### Code Organization
You are provided the following files:
* `digitrec.cpp`: an incomplete source file where you write your k-NN based digit recognition algorithm
in C++.
* `digitrec.h`: the header file that defines the interface for the core functions `update_knn` and `knn_vote`.
* `typedefs.h`: the header file that defines the key data types used in the design.
* `data/training_set_#.dat`: training set for digit #, where # = 0, 1, 2, ..., 9.
* `training data.h`: the header file that combines all the training data sets (i.e., `data/testing_set.dat`) into a constant array.
* `data/testing_set.dat`: a set of testing instances with corresponding expected values to help you test your
design.
* `digitrec_test.cpp`: a test bench (only useful for simulation) that helps verify your code and perform
experiments with various handwritten input digits.
* `Makefile`: a makefile for you to easily compile source code into an executable named digitrec and execute
the program to check results (enter `make`).
* `run.tcl`: the template project Tcl script that allows you to run Vivado HLS synthesis in command line
(`vivado_hls -f run.tcl`). 


### Setting up Vivado HLS
For this assignment we will be using Vivado HLS. 
You can install Vivado on your local machine (<https://www.xilinx.com/support/download.html>).  If you do this, I suggest you install Vivado 2019.2 Design or System Edition on an Ubuntu 18.04 machine.  

_Note: If you prefer, you can install Vivado on a Windows machine.  I haven't tested this.  It should work with the assignment, with a few extra considerations.  For example, the Makefile which has been provided to quickly compile and run your design may not work unless you have a build system setup.  You can still build and run within Vivado HLS, so it is not a big difference, but keep in mind you may run into problems such as this._

Vivado HLS requires a license.  You can access the department Xilinx license server by setting the following environment variable.  This means you must either be on the university network, or connected to the CAEDM VPN.

```
export LM_LICENSE_FILE=2100@ece-xilinx.byu.edu
```

To run the Vivado tools you should first run the configuration script:
```
source /opt/Xilinx/Vivado/2019.2/settings64.sh
```

This will add the tools to your `PATH`.  If you don't want to setup your own machine, contact me and I can give you access to a server with Vivado 2019.2 installed.


### Vivado GUI vs command line
For this assignment you can use the Vivado HLS GUI, or you can work entirely via command line.  If you are using the GUI, create a new project with this configuration:

\begin{itemize}
	\item Top Function: digitrec
	\item Design Files: 
	
	\begin{itemize}
		\item digitrec.cpp
	\end{itemize}
	\item TestBench Files:
	
	\begin{itemize}
		\item digitrec\_test.cpp
		\item data \emph{(this is a folder)}
	\end{itemize}
	\item Part: xc7z020clg484-1
\end{itemize}

When you are ready to collect results you can use the \emph{run.tcl} script to automatically run C simulation and synthesis, and extract results for $k=1,2,3,4,5$.

\begin{lstlisting}
vivado_hls -f run.tcl
\end{lstlisting}

If you look inside \emph{run.tcl} you will see it creates five projects with the same properties as above, each with a different $k$ value.

\section{Design Overview}


\begin{figure}[h!]
	\centering
	\begin{subfigure}[b]{0.3\textwidth}
		\centering
		\includegraphics[trim={6cm 11cm 25cm 2cm}, clip,width=.33\textwidth]{binary_strings.pdf}
		\caption{Binary string in 2D array}
		\label{fig:binary_string_1}
	\end{subfigure}
	~~~~~~~
	\begin{subfigure}[b]{0.3\textwidth}
	\centering
		\includegraphics[trim={0cm 0cm 0cm 0cm}, clip,width=.6\textwidth]{img1.png}
		\caption{Binary image}
		\label{fig:binary_image_1}
	\end{subfigure}
	
	\caption{Training instance for digit 0}
	\label{fig:training_digit_0}
\end{figure}

\begin{figure}[h!]
	\centering
	\begin{subfigure}[b]{0.3\textwidth}
		\centering
		\includegraphics[trim={11.5cm 11cm 19.5cm 2cm}, clip,width=.33\textwidth]{binary_strings.pdf}
		\caption{Binary string in 2D array}
		\label{fig:binary_string_2}
	\end{subfigure}
	~~~~~~~
	\begin{subfigure}[b]{0.3\textwidth}
	\centering
		\includegraphics[trim={0cm 0cm 0cm 0cm}, clip,width=.6\textwidth]{img2.png}
		\caption{Binary image}
		\label{fig:binary_image_2}
	\end{subfigure}
	
	\caption{Training instance for digit 7}
	\label{fig:training_digit_7}
\end{figure}

\textbf{You are given 10 training sets, each of which contains 1800 49-bit training instances for a
different digit (0-9). Each hexadecimal string in \emph{training\_set\_\#} represents a 49-bit training
instance for digit \#}. The 49 bits of each instance encodes a 7x7 matrix of binary values (i.e., a bitmap).
For example, $e3664d8e00_{16}$ in \emph{training\_set\_0} is a training instance for digit 0 and translates into the binary 2D matrix in \cref{fig:binary_string_1}, whose 1 bits outline the digit 0. A binary image of the array is shown in \cref{fig:binary_image_1}. $41c0820410_{16}$ in training set 7 is a training instance for digit 7 and translates into the binary 2D matrix in \cref{fig:binary_string_2}, whose 1 bits approximately outline the digit 7. The corresponding binary image is shown in \cref{fig:binary_image_2}. As you can see, the resolution of the digit is limited by the number of bits (49 bits in our assignment) used to represent it. Typically, increasing the number of bits per instance would improve the resolution and possibly the accuracy of recognition. 

We would like to devise an algorithm that takes in a binary string representing a handwritten digit (i.e. the testing instance) and classify it to a particular digit (0-9) by first identifying $k$ training instances that are closest to the testing instance (i.e., the nearest neighbors), and then determining the result based on the most common digit represented by these nearest neighbors. 

You are encouraged to read through [1] to familiarize yourself with the basic concepts of the k-NN algorithm.
\textbf{In this assignment, we define the distance between two instances as the number of corresponding bits that are different in the two binary strings.} For example, $1011_2$ and $0111_2$ differ in the two
most significant bits and therefore have a distance of 2. $1011_2$ and $1010_2$ differ only in the least significant bit and have a distance of 1. As a result, $1011_2$ is closer to $1010_2$ than to $0111_2$.

\section{Implementation}

\subsection{Coding and Debugging}
Your first task is to complete the digit recognition algorithm based on the code skeleton provided in \emph{ digitrec.cpp}. In particular, you are expected to fill in the code for the following functions:

\begin{itemize}
	\item \emph{update\_knn}: Given the testing instance and a (new) training instance, this function maintains/updates an array of $k$ minimum distances per training set.
\item	\emph{knn\_vote}: Among $10 \times k$ minimum distance values, this function finds the $k$ nearest neighbors and determines the final output based on the most common digit represented by these nearest neighbors.
\end{itemize}

Note that the skeleton code takes advantage of arbitrary precision integer type \emph{ap\_uint}. \textbf{A useful reference of arbitrary precision integer data types can be found starting on p.212 and p.609 of the user guide~\cite{vivado_hls}}.

How you choose to implement the algorithm may affect the resulting accuracy of your design as reported by the test bench. \textbf{We expect that your design would achieve an error of less than 10\% on the provided testing set}. You may use the console output or the generated \emph{out.dat} file to debug your code.


\subsection{Design Exploration}
\label{sec:design_exploration}
The second part of the assignment is to explore the impact of the $k$ value on your digit recognition design. Specifically, you are expected to experiment with the $k$ values ranging from 1 through 5, and collect the performance and area numbers of the synthesized design for each specific $k$.

\begin{itemize}
	\item The actual $k$ value can be specified in \emph{Makefile} and/or \emph{run.tcl}. You can run simulation and synthesis in batch with \emph{run.tcl}. This script will also automatically collect important stats (i.e., accuracy, performance, and resource usage) from the Vivado HLS reports and generate a \emph{knn\_result.csv} file under the result folder.
\item	In this assignment, you will use a fixed 10ns clock period targeting a specific Xilinx Zynq FPGA device. Clock period and target device have been specified in the run Tcl script.
\end{itemize}

\subsection{Design Optimization}
The third part of the assignment is to optimize the design with HLS pragmas or directives. In particular, we
will focus on exploring the effect of the following optimizations in our design and apply them appropriately
to \textbf{minimize the latency of the synthesized design}.}

\begin{itemize}
	\item \textbf{loop pipelining} Allows for overlapped execution of loop iterations by leveraging pipelining techniques.
	\item \textbf{loop unrolling} unfolds a loop by creating multiple copies of its loop body and reducing its trip count accordingly. This technique is often used to achieve shorter latency when loop iterations can be executed in parallel.
\item \textbf{array partitioning} partitions an array into smaller arrays, which may result in an RTL with multiple small memories or multiple registers instead of one large memory. This effectively increases the amount
of read and write ports for the storage.
\end{itemize}

Please refer to the following user guide for details on how to apply these optimization using Vivado HLS
(v2016.4).

\begin{itemize}
	\item Vivado Design Suite User Guide, High-Level Synthesis, UG902 (v2018.2) \cite{vivado_hls}

\begin{itemize}
	\item Loops, p.317
 \item Arrays, p.325
\end{itemize}
You may insert pragmas or set directives to apply optimizations. You can find code snippets with
inserted pragmas throughout the user guide, and a full reference is given in Chapter 4 (p.415).
\end{itemize}

%\textbf{Other than the added pragmas/directives, your program should look the same with baseline.}

\textbf{Your proposed solution must meet the clock period constraint, and must not exceed the resources available on the targeted FPGA (xc7z020clg484-1).}


%In this experiment, please avoid unrolling the outermost loop (i.e., the one that iterate 1800 times) so your design would not require excessive chip area. 
For the sake of simplicity, please try to only use fixed-bound
{\tt for} loop(s) in your program. Note that data-dependent {\tt for} and {\tt while} loops are synthesizable but may lead to a variable-latency
design that would complicate your reporting (\emph{You will need to enable C-RTL co-simulation to get the actual cycle count for a design with data-dependent loop bounds}).

\section{Class Results}
On Piazza I will post a link to a Google Sheets document where you should post the results of your best solution.  There will be two categories for rankings:
\begin{enumerate}
	\item \textbf{Minimum Latency.} Minimum latency provided the design fits within the resources constraints of the chip, and achieves $10\%$ error rate. 
	\item \textbf{Most ``resource efficient".} The goal in this category is to minimize the expression $r^2 \cdot L$, where $r$ is the resource usage and $L$ is the total latency.  The resource usage will be defined as the maximum fraction of resource usage for any given resource type (BRAM, DSP, FF, LUT).
\end{enumerate}
 
\section{Report}


\begin{enumerate}
\item Submit a report containing the following items:
\begin{itemize}
	  \item Your name
		\item Describe how you implement the \emph{update\_knn} and \emph{knn\_vote} functions.
		\item Compare different $k$ values with a table that summarizes the key stats
including the error rate (accuracy), area in terms of resource utilization (number of BRAMs, DSP48s,
LUTs, and FFs), and and performance in latency in number of clock cycles.  Use the csv file generated by the script, or manually inspect \emph{knn.prj/solution1/syn/report/}.  
		\item Describe how you added HLS pragmas/directives to minimize the latency of the synthesized design. Please contrast the performance and area of your most optimized design (i.e., with smallest latency) with the baseline design. For this comparison, you only need to set $k$ to 3.
		\item Use charts, snippets of code, or any other presentation techniques to communicate your design decisions and results.
			
		\item Any feedback you want to share.
		
		
\end{itemize}

\item Submit your source code.  If you only change the one .cpp file, then only submit that file.
\end{enumerate}



\section{Submission Instructions}
Submit your report and source code to \href{mailto:jgoeders@byu.edu}{jgoeders@byu.edu} with the subject: 625 Asst4

\section{Acknowledgement}
This assignment was originally written by Professor Zhiru Zhang from Cornell University.  I have modified it slightly for our class.  The design was originally created by Professor Zhang's students, Ackerley Tng and Edgar Munoz.

\renewcommand*{\bibfont}{\footnotesize}
\printbibliography[heading=bibintoc]

\end{document}

