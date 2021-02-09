---
layout: page
toc: false
title: Vivado & Vitis Tutorials
---

## Setup

Make sure you have Vivado/Vitis 2020.2 installed on your machine.  This can be done in your Windows/Linux host OS, or in a virtual machine.  See instructions [here]({% link _other_pages/install_vitis.md %}).

### Installing Boards
If you are using a Digilent board, such as the Zedboard, you need to setup the board files in Vivado.  See <https://github.com/Digilent/vivado-boards/>.

### Running Vivado
Before you can run the Vivado tools you should first run the configuration script:
```
source /tools/Xilinx/Vivado/2020.2/settings64.sh
```

This will add the tools to your _PATH_.  

To run Vivado, simply run `vivado`.




## Hello World in Vivado (Hardware)

### Creating the Project
After launching Vivado, follow these steps to create a hardware project:
1. _Create Project_..., and choose a project name and location.  You can name your project whatever you want, but make sure you place the project in it's own directory.  For example, my project was named *625_lab5* and located at *lab_vitis/hw/vivado_proj*. (Note that I chose to add a _hw_ subdirectory and then created a project directory within this.  You will see why this is useful when you get to the section on _Committing to Git_). Click Next.  Choose an RTL project. Click _Next_.  
2. You don't need to add any sources or constraints yet, just click _Next_.
2. On the next you will be asked to choose an FPGA part.  Click _Boards_ at the top, and choose your board (ie. Zedboard).  Click Finish to create your project.

### Creating a Base Design
In these steps we will create a basic system, containing only the Zynq processing system (PS).
1. Click _Create Block Design_, and click _OK_ on the popup.
2. Add the _ZYNQ7 Processing System_ IP to the design (right-click, Add IP).
3. A green banner should appear with a link to _Run Block Automation_.  Run this. This will configure the ZYNQ for your board.
4. The `FCLK_CLK0` output of the _Zynq Processing System_ will serve as your system clock.  It is set to 100MHz by default.  Connect it to the `M_AXI_GP0_ACLK` input.	
5. Generate a top-level module: In the _Sources_ window, expand _Design Sources_ and right-click on your block design (_design_1.bd_) and select _Create HDL Wrapper_. Use the option to _Let Vivado manager wrapper and auto-update_.

### Committing to Git
Want to commit your project to Git? Don't try and commit your actual project files, as this won't work.  Instead, we will instruct Vivado to create a single Tcl script that can be used to re-create our project from scratch:
* Select _File->Project->Write Tcl_. 
* Make sure to check the box _Recreate Block Designs using Tcl_.  
* Those choose a file location.  This should be outside your project directory, since your project directory is temporary and not committed to Git.  My script is located at `lab_vitis/hw/create_hw_proj.tcl`.  Commit this Tcl script to Git.
* Now, feel free to delete your Vivado project folder, and then you can simply recreate it using `vivado -source create_hw_proj.tcl`.  I typically create a simple _Makefile_ such as this:

```
proj:
	vivado -source create_hw_proj.tcl

clean:
	rm -rf 625_lab5
```

### Synthesizing the hardware
1. Run _Generate Bitstream_.
2. Once the bitstream generation is complete, export the hardware:
 *  _File->Export Hardware_.  
 * Chose the _Include Bitstream_ option, and choose a location to store the Xilinx Shell Archive (.xsa). Mine is placed at `lab_vitis/hw/625_lab5_hw.xsa`.  This file will be provided to the software tools in the next section to tell the software tools all about our hardware system configuration.
3. You should commit this _.xsa_ file to Git.

## Hello World in Vitis (Software)

Run Vitis (`vitis`), and choose a workspace location. I used _lab_vitis/sw_ for my workspace location.

### Create Vitis Projects
1. Create the platform project.  This project generates the _standalone_ operating system code, which is support software and drivers for a bare-metal environment.
  * _File->New->Platform Project_.  
  * Chose a _Platform Project name_.  I chose *625_hw*.  
  * Browse to your _.xsa_ file name. 
<img src = "{% link media/tutorials/hw_platform.png %}" width="800">
  

2. Change the _stdout_ output.  By default, the output from your program will be sent over the physical UART pins present on the board.  But instead of having to connect a UART to the board, we will use the option that allows us to send stdout over an virtual UART using the JTAG (USB) connection.
  * Expand your platform project, and double click on the _platform.spr_ file.  Select the *standalone on ps7_cortexa9_0->Board Support Package*, and click _Modify BSP Settings_.
<img src = "{% link media/tutorials/open_bsp.png %}" width="800">
  * In the _Board Support Package Settings_ popup, go to the _standalone_ menu, and change _stdout_ to use *coresight_comp_0*.  
<img src = "{% link media/tutorials/bsp_stdout.png %}" width="800">
  * Click _OK_ to close the window and save the BSP settings.

3. Build the BSP code.  Right click on your platform project and choose _Build Project_. 

4. Create your application project.
  *  _File->New->Application Project_. 
  * Chose your platform that you created in the last step.
<img src = "{% link media/tutorials/vitis_application.png %}" width="800">
  * Choose an application name (ie. HelloWorld), and continue through the next screens.
  * On the _Templates_ screen, choose _Hello World_, and then click _Finish_.
  * After you complete the wizard, build your application.  Right click on your application project and choose _Build Project_. 


### Run the Applicaton on the Board
\begin{enumerate}
	\item Configure the FPGA with the \inlinegraphics{configure_fpga.png} menu button.
	\item Right-click on your application project, choose Run As$\rightarrow$Launch on Hardware (System Debugger).
	\item To view the program output, you will need to use the console selector button \inlinegraphics{console_select.png} in the \emph{Console} window to select the \emph{TCF Debug Virtual Terminal - ARM Cortex-A9 MPCore \#0} console.
	\item You should see the message \emph{Hello World}.
\end{enumerate}


\section{Exporting your HLS as IP}
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

