---
layout: page
toc: false
title: Vitis HLS Integration Tutorial
---

### Previous: [Vitis Tutorial]({% link _pages/vitis_tutorial.md %})


## Exporting your HLS as IP
This section discusses how you can export your IP from Vivado HLS to be used in a Vivado project.  Since our goal is to communicate with the HLS IP from software, we will add a Slave AXI connection to our HLS IP core so that it can be connected to the ARM AXI bus.

\begin{enumerate}
	\item Run Vivado HLS and open your project from the last assignment.
	\item In Vivado HLS, add a directive to your top-level hardware function.  Choose the \emph{INTERFACE} directive type, and change the mode to an AXI4-Lite Slave (\emph{s\_axilite}).
	\item Run C Synthesis.
	\item Click the Export RTL button \inlinegraphics{export_rtl.png}, and make sure the Format Selection is set to \emph{IP Catalog}.
	\item Close Vivado HLS.
\end{enumerate}

\section{Adding your IP to Vivado}
\begin{enumerate}
	\item Launch Vivado, open your existing project, and open the block design.
	\item If you do not already have a \emph{Processor System Reset} IP, add one to your design.  This will use the reset signal output by the processing system to reset IP in the FPGA fabric.  
	
	\begin{enumerate}
		\item Connect the system clock (\emph{FCLK\_CLK0} from PS) to the \emph{slowest\_sync\_clk} input.
		\item Connect the processor reset output (\emph{FCLK\_RESET0\_N}) to the \emph{ext\_reset\_in} input.		
	\end{enumerate}
	\item If you do not already have a \emph{AXI Interconnect} IP, add one to your design.  This is the bus that will allow the ARM CPU to communicate with the IP implemented in the FPGA fabric.
	
	\begin{enumerate}
		\item Configure the bus to have 1 Slave Interface and 1 Master Interface.
		\item Connect the PS bus master (\emph{M\_AXI\_GP0} from PS) to the \emph{S00\_AXI} slave port.
		\item Connect your clock (\emph{FCLK\_CLK0} from PS) to all the clock inputs (\emph{*ACLK})
		\item Connect your interconnect reset (\emph{interconnect\_aresetn} from \emph{Processor System Reset}) to the \emph{ARESETN} input.
		\item Connect your peripheral reset (\emph{peripheral\_aresetn} from \emph{Processor System Reset}) to the other reset inputs (\emph{*\_ARESETN})
	\end{enumerate}


	\item {Add your HLS IP:}
	
	\begin{enumerate}
		\item Open the IP catalog
		\item Right-click, \emph{Add Repository}
		\item Navigate to your HLS IP found in \texttt{your\_hls\_project/your\_solution/impl/ip}.
		\item Go back to your block design and add the HLS IP to your design.
	\end{enumerate}
	
	\item{Connect up your HLS IP:}
	
	\begin{enumerate}
		\item  Connect the clock (\emph{FCLK\_CLK0} from PS) to the clock input (\emph{ap\_clk})
		\item  Connect the reset (\emph{peripheral\_aresetn} from \emph{Processor System Reset}) to the reset input (\emph{ap\_rst\_n})
		\item Connect the bus (\emph{M00\_AXI} from the \emph{AXI Interconnect}) to the bus slave port (\emph{s\_axi\_AXILiteS})
	\end{enumerate}
	
	\item Assign an address to your HLS IP.  Open the \emph{Address Editor}, find your IP, right-click \emph{Assign Addresses}.
	
	\item Run \emph{Generate Bitstream.}
	
	\item Export the hardware with bitstream, and be sure to choose the same location as last time, overwritting the existing hardware description file.

	\item Close Vivado
\end{enumerate}


\section{Communicating with your HLS IP from Software}
\begin{enumerate}
	\item Launch Xilinx SDK and reopen your existing workspace.
	\item You should see a prompt indicating that the hardware has changed.  Click \emph{Yes} to update your software libraries to support the new hardware system.
	\item Right-click on your BSP project and click \emph{Re-generate BSP sources}. 
	\item Right-click on your BSP project, click \emph{Board Support Package Settings}, go to drivers and make sure you can find your IP core listed.  For the in-class demo, my IP core was called \emph{sum\_array}, so I can find the IP named \emph{sum\_array\_0} in the list and verify that the driver called \emph{sum\_array} is selected. Click OK to close the settings window.
	\item In your BSP project, you can look in \emph{ps7\_coretexa9\_0/include} to find the header files for your driver.  Mine are called \emph{xsum\_array.h} and \emph{xsum\_array\_hw.h}.
	\item Include the necessary header file in your application code and write software to test that you can start your IP, wait for it to complete, and retrieve the return value.  As with most Xilinx drivers, you will need to call the initialization function first (\emph{XSum\_array\_Initialize}).  The first argument is a struct variable that you should define and pass in by pointer, the second is the device ID (\emph{ XPAR\_XSUM\_ARRAY\_0\_DEVICE\_ID}), that can be used by including \emph{xparameters.h}.
\end{enumerate}


\renewcommand*{\bibfont}{\footnotesize}
\printbibliography[heading=bibintoc]

\end{document}

