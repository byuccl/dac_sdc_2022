---
layout: page
toc: false
title: Vitis HLS Integration Tutorial
---

### Previous: [Vitis Tutorial]({% link _pages/vitis_tutorial.md %})


### Exporting your HLS as IP
This section discusses how you can export your IP from Vivado HLS to be used in a Vivado project.  Since our goal is to communicate with the HLS IP from software, we will add a Slave AXI connection to our HLS IP core so that it can be connected to the ARM AXI bus.

* Run Vitis HLS and open your project from the last assignment.
* Add a directive to your top-level hardware function.  Choose the *INTERFACE* directive type, and change the mode to an AXI4-Lite Slave (*s_axilite*).
* Run C Synthesis.
* Click *Solution->Export RTL*, and make sure the Format Selection is set to * Vivado IP (.zip)*.
* Close Vivado HLS.
* Unzip your IP to a folder, for example, I used `unzip digitrec.zip -d lab_vitis/ip/digitrec/`


### Adding your IP to Vivado
* Run Vivado, open your existing project, and open the block design.
* If you do not already have a `Processor System Reset` IP, add one to your design.  This will use the reset signal output by the processing system to reset IP in the FPGA fabric.  
	* Connect the system clock ( `FCLK_CLK0` from *ZYNQ7 Processing System*) to the *slowest_sync_clk* input.
	* Connect the processor reset output (*FCLK_RESET0_N*) to the *ext_reset_in* input.		
* If you do not already have an *AXI Interconnect* IP, add one to your design.  This is the bus that will allow the ARM CPU to communicate with the IP implemented in the FPGA fabric.
	* Configure the bus to have 1 Slave Interface and 1 Master Interface.
	* Connect the PS bus master (*M_AXI_GP0* from *ZYNQ7 Processing System*) to the *S00_AXI* slave port.
	* Connect your clock (*FCLK_CLK0* from *ZYNQ7 Processing System*) to all the clock inputs (_*ACLK_)
	* Connect your interconnect reset (*interconnect_aresetn* from *Processor System Reset*) to the *ARESETN* input.
	* Connect your peripheral reset (*peripheral_aresetn* from *Processor System Reset*) to the other reset inputs (_*ARESETN_)


* Add your HLS IP:
	* Open the IP catalog
		* Right-click, *Add Repository*
		* Navigate to the *ip* folder that contains your HLS IP extracted in the earlier step, and add this directory.
	* Go back to your block design and add the HLS IP to your design.
	
* Connect up your HLS IP:
	* Connect the clock (*FCLK_CLK0*) to the clock input (*ap_clk*)
	* Connect the reset (*peripheral_aresetn*) to the reset input (*ap_rst_n*)
	* Connect the bus (*M00_AXI* from the *AXI Interconnect*) to the bus slave port (*s_axi_control*)
	
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

