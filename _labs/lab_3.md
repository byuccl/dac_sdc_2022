---
layout: lab
toc: true
title: LLVM
number: 3
# repo: https://github.com/byu-ecen493r-classroom/lab1.git
---



## Learning Outcomes
The goals of this assignment are to:
* Understand the benefits of applying optimizations to the IR code, prior to the standard HLS algorithms.
* Gain experience using LLVM to modify the IR code of a program.
* Practise C++ skills.

## Background

In this assignment you will write an optimization pass for LLVM, that transforms the IR code.  The goal of the transformation will be to identify adder trees in the IR, and perform tree balancing, as shown in 

<img src="{% link media/llvm/balancer_example.svg %}" width="600">


### Motivation

simple_unrolled_partitioned/simple.c
```
int main() {
   ...
    // int A[100];
    int A1[20];
    int A2[20];
    int A3[20];
    int A4[20];
    int A5[20];

    int i;
    for (i = 0; i < 20; i++) {
        A1[i] = my_rand();
        A2[i] = my_rand();
        A3[i] = my_rand();
        A4[i] = my_rand();
        A5[i] = my_rand();
    }

    int sum = 0;
    for (i = 0; i < 20; i += 2) {
        sum += A1[i] + A1[i + 1] + A2[i] + A2[i + 1] + A3[i] + A3[i + 1] +
               A4[i] + A4[i + 1] + A5[i] + A5[i + 1];
    }

    if (sum == 3184847)
        printf("CORRECT\n");
    else
        printf("ERROR\n");
    return 0;
}
```


The example above, or similar logic trees, often occur when we unroll loops.  Loop unrolling can offer greater performance by potentially executing multiple iterations of the loop in parallel.

The code above shows the `simple.c` program, which sums the values of a 100 entry array.  I have manually performed _loop unrolling_, and unrolled this loop by a factor of 10, so that for each iteration of the loop, 10 values from the array are summed.   The problem with such an approach is that it is usually not possible to load 10 values from memory at once.  If values are loaded sequentially, there will be little to no benefits to loop unrolling.  To get around this problem, I have also manually performed _memory banking_, by splitting up the `A` array, into 5 equal sized arrays, `A1`, `A2`, `A3`, `A4`, and `A5`.  Each of these can be placed in a separate dual-ported memory, allowing us to read 10 values from memory simultaneously.

Now that these optimizations are in place, if you compile the design and inspect the IR code, you will see that we end up with a summation similar to the left-hand side of \cref{fig:balancer_example}.  We would like to automatically optimize the IR to balance the adder tree, producing a structure similar to the right-hand side of \cref{fig:balancer_example}.  This optimization can improve the critical path of the resulting hardware, or if timing constraints are imposed, reduce the latency of each loop iteration.  
%In addition, it requires fewer adder resources for large adder trees (A cascading summation requires $O(n)$ adders, while a balanced tree requires $O(log(n))$ adders).

\emph{Note:} Although I manually performed the loop unrolling and memory banking by modifying the C code, these options are often available to the user of an HLS tool via pragmas in their C code (LegUp supports loop unrolling via pragmas, but not memory banking, whereas the commerical tool Xilinx Vivado HLS, supports both).




\section{Getting Started}

\subsection{Set up your environment}
The instructions for this assignment assume you are running an Ubuntu 16.04 Linux Operating System.  You may be able to complete this assignment in other modern Linux variants; however, you may run into unexpected problems getting the code to compile, and finding the necessary packages for your distribution.

\subsection{Get the code}
\begin{enumerate}
	\item Download the LegUp 4.0 HLS tool source code from \url{http://legup.eecg.utoronto.ca/download.php}
	\item Extract the files to a location of your choice (such as {\tt \textasciitilde{}/legup})
	\item Download the patch file (\textit{ecen625\_asst2\_3.patch}) from the course website.
	\item Apply the patch file to your LegUp 4.0 installation:
	\begin{lstlisting}
	cd ~/legup
	\end{lstlisting}
	First run a dry-run to make sure there will be no errors.  If there are errors, recheck that you are in the correct directory, and that you followed the previous steps properly.
	\begin{lstlisting}
	patch -p1 --dry-run <  ecen625_asst2_3.patch
	\end{lstlisting}
	
	If the dry run executed without errors, then run the patch:
	\begin{lstlisting}
	patch -p1 <  ecen625_asst2_3.patch
	\end{lstlisting}
	
	\textbf{When you are done with this assignment be sure to keep this file structure, as we will continue using it for the next assignment.}
\end{enumerate}



\subsection{Initial build}
You will first need to install the necessary packages:
\begin{lstlisting}
sudo apt install tcl8.5-dev libmysqlclient-dev liblpsolve55-dev build-essential \
automake libtool libgmp3-dev clang-3.5 gcc-4.8-plugin-dev libc6-dev-i386 \
libqt4-dev csh

\end{lstlisting}


To compile, just run the following from the top-level directory:
	\begin{lstlisting}
	make	
	\end{lstlisting}

It will take a while, so you may want to use a parallel build (ex. make -j4 to use 4 threads; if you are using my ssh0 machine, you can use 20 threads).  Keep in mind if your compilation fails using a parallel build, the error message may be buried, so you may want to run a normal make in that case to see what the error is.


Even if you get the following error, you can consider your build complete:
\begin{lstlisting}
make[1]: ip-make-ipx: Command not found
\end{lstlisting}

\emph{(There are some things done in the build script after this point that require you to install the Altera FPGA tools, which we will not do for this assignment.  So if you get to this error you've made it far enough.  We will consider this a successful build.  All of the executables that you will use in this assignment will have been successfully built at this point.)}

When you make change to any files, you will need to run make again.  This shouldn't take too long.  However, a quicker method is to run the following command \textbf{from the Verilog folder} to just recompile the bare minimum (assuming you only changed files within the Verilog folder):



\subsection{Incremental build}
\label{sec:incremental_build}
When you make change to any files, you will need to run make again.  This shouldn't take too long.  However, a quicker method is to run the following command from the {\tt llvm/lib/Transforms/LegUp/} folder to just recompile the bare minimum (assuming you only changed files within the {\tt llvm/lib/Transforms/LegUp/} folder):  

\begin{lstlisting}
	/home/jgoeders/ecen625/asst2/llvm/utils/makellvm opt
\end{lstlisting}


\emph{(This recompiles only the \emph{opt} binary, which is the LLVM optimizer, which is responsible for executing our transformation pass.)}

\subsection{Setting up Eclipse}
Typically when I am coding for LegUp/LLVM I use Eclipse.  Here are some setup instructions after you have checked and done an initial build of the code.  If you don't plan on using Eclipse, just skip this section.

\begin{enumerate}
	\item File--$>$New--$>$Other.  Choose C/C++--$>$Makefile Project With Existing Code.
	\item Choose a project name (such as ECEN522rAsst2)
	\item For existing code location, browse to the code you checked out.
	\item Choose "Linux GCC" as the indexer.
	\item Click Finish
\end{enumerate}

To set up the quick build process in Eclipse (remember you need to do a full compile before you can do a quick incremental build):

\begin{enumerate}
	\item Right-click project, choose Properties
	\item Select C/C++ Build 
	\item For the build command, use the following (change path for your setup): \newline /home/jgoeders/ecen625/asst2/llvm/utils/makellvm opt 
	\item For the build directory, click "Workspace..." and browse to the Verilog folder.  It should look something like this after you select it: \$\{workspace\_loc:/asst2/llvm/lib/Target/Verilog\}
	\item Select the "Behvaior" tab, and clear the "Build (incremental build)" field (remove the word 'all').
\end{enumerate}



\subsection{Code Organization}
In this assignment we are adding an optimization pass to the middle passes of the compiler, so the compiler code is located in the {\tt Transforms} folder.  (In case you are interested, LLVM passes that only analyze the IR program, but don't modify it, are typically located in the {\tt Analysis} folder.) Take a look at the files that are part of the assignment:
\begin{itemize}
	\item {\tt llvm/lib/Transforms/LegUp/} -- This folder contains transforms that are part of LegUp.   
	\item {\tt llvm/lib/Transforms/LegUp/AdderTreeBalancer.cpp/.h} -- You will add all your code for this assignment in theses files. 
	\item {\tt examples/625} -- This contains some C programs to test your code.  For this assignment, I have added the {\tt simple\_unrolled\_partitioned} design, as shown in \cref{fig:code}, so that you can test your optimization pass.  The {\tt shared\_add\_tree} design may also help with testing your code for this assignment.  The other benchmarks in the 625 folder might not see any benefit from this optimization, but you can always create your own benchmark if you want to do further testing.
\end{itemize}

\subsection{Creating an Optimization Pass in LLVM}
For this assignment we will be using a {\tt BasicBlockPass} in LLVM.  That is, it is a transformation pass that modifies code contained with a single basic block.  In this section I will describe how to create such a pass, and how to register it with LLVM, such that LLVM will execute your pass for every basic block in the design.  This code is already given to you.

You can also create passes that operate at different scopes, including Module (entire C program), Function, Loop, Region, and more.  More information on these types of passes can be found at \url{http://releases.llvm.org/3.5.0/docs/WritingAnLLVMPass.html}.

If you look at {\tt AdderTreeBalancer.cpp/.h} you will see the following relevant pieces of code:

\begin{itemize}
	\item The class is a subclass of {\tt BasicBlockPass}

\begin{lstlisting}
class AdderTreeBalancer : public BasicBlockPass {
\end{lstlisting}

	\item All LLVM passes must contain a static identifier, ID.  This need to be contained within the class, but you never modify it.  It is used and modified by the LLVM pass manager.
\begin{lstlisting}
	static char ID;
\end{lstlisting}

	\item You must define the following function, which is a virtual function in the parent {\tt BasicBlockPass} class.  This function will be called by the LLVM pass manager on every basic block in the code.  So the bulk of your code will be placed within this function.  This function returns a bool, indicating whether the code made any changes to the basic block. 
\begin{lstlisting}
	bool runOnBasicBlock(BasicBlock &BB);
\end{lstlisting}

	\item You must register your pass with the LLVM pass manager.  The first argument to the {\tt RegisterPass} constructor is the command-line argument for your pass, and the second argument is a text description which is provided to the user when they use ``-help" on the command line. 
\begin{lstlisting}
	static RegisterPass<AdderTreeBalancer> X("legup-adderTreeBalancer", "Adder Tree Balancer Pass");
\end{lstlisting}


\end{itemize}


\subsection{Compiling and Running the Pass}

When the pass is compiled (either by a top-level make, or by rebuilding {\tt opt}), it will be compiled into a library containing all LegUp passes.  This file is located here:
\begin{lstlisting}
legup/llvm/Release+Asserts/lib/LLVMLegUp.so
\end{lstlisting}

You can test that it is compiled properly by running the {\tt opt} command, and using {\tt -help} to list all available passes.  You need to pass an argument to {\tt opt} to tell it to include your library file.  The full command looks like this:

\begin{lstlisting}
legup/llvm/Release+Asserts/bin/opt -load legup/llvm/Release+Asserts/lib/LLVMLegUp.so -help 
\end{lstlisting}

After you compile, run this command and verify that {\tt legup-adderTreeBalancer} appears in the list of available passes.


To execute the pass, you would use the following command, where $<$input\_ir$>$.bc is the IR input file, and $<$outout\_ir$>$.bc is the optimized IR code produced by the pass:
\begin{lstlisting}
legup/llvm/Release+Asserts/bin/opt -load legup/llvm/Release+Asserts/lib/LLVMLegUp.so <input_ir>.bc -o <output_ir>.bc
\end{lstlisting}

However, you shouldn't ever need to call {\tt opt} directly.  I have modified the {\tt Makfile} so your pass will automatically be called as part of the full LegUp compile flow.  To enable it, all you need to do is add the following to the {\tt Makefile} that resides within the example program directory.  

\begin{lstlisting}
ADDER_TREE_BALANCER = 1
\end{lstlisting}

I have already added this to {\tt examples/625/simple\_unrolled\_partitioned/Makefile}.  

If you are interested in seeing how I added this to the LegUp makefile, you can look at {\tt examples/Makefile.common}, lines 158--163, which contain:
\begin{lstlisting}
	# 625 tree balancer pass
ifdef ADDER_TREE_BALANCER
	$(LLVM_HOME)opt $(OPT_FLAGS) -legup-adderTreeBalancer -dce $(NAME).postlto.9.bc -o $(NAME).postlto.bc
else
	cp $(NAME).postlto.9.bc $(NAME).postlto.bc
endif 
\end{lstlisting}

The {\tt -dce} option runs dead code elimination after your pass.

Remember, the .bc files are binary IR files.  The {\tt *.postlto.9.bc} is the IR file before your pass is called, and the {\tt *.postlto.bc} is the IR file after your pass is called.  \uline{If you want to inspect the IR, then open the human-readable files {\tt *.postlto.9.ll} and {\tt *.postlto.ll} in your favorite text editor.}




\section{Coding the Tree Balancer} 
\label{sec:coding_the_tree}

How you code the tree balancer is up to you.  

You probably want to follow this general approach:
\begin{enumerate}
		\item Look through the Instructions in the basic block to identify adder trees, and collect a list of inputs to this adder tree.
		\item Create a balanced adder tree with these inputs.		
		\item Replace uses of the root adder instruction, $I$, with the output of your newly created adder tree.
\end{enumerate}

Some tips with this approach:
\begin{itemize}
	\item When recursively visiting adders, you need to make sure the output of an intermediate node is not used elsewhere in the code.  You can do this by checking that the number of uses is 1 ({\tt (Value*)->getNumUses()}).  The reason for this is that all of these instructions will be deleted, and replaced by your adder tree.  Only the final output of the adder tree can be used multiple places in the code.
	\item The inputs to your adder tree may be instructions, constants, etc.  You should use the LLVM {\tt Value} class (see \cref{sec:llvm_classes}) to keep track of the inputs.
	\item You will need to add all of your newly created addition instructions to the basic block.  Make sure you add them in a valid position, and order (ie. the final addition in your tree should be located before any uses, and adder nodes in your tree should be in a valid ordering).  This may be simpler than you think.  You should be able to add your entire tree at the location of instruction $I$ (as described in Step 1 of the technique above).
	\item You don't need to delete the adder instructions you are replacing with your tree.  As long as you complete Step 3, these additions will become dead code.  Since dead code elimination is performed after your pass, these instructions will automatically be removed.
	\item In step 1 you are iterating over the basic block.  However, if you end up inserting an adder tree, you are modifying the very data structure you are iterating over.  You cannot continue iterating at this point.  Either exit out of the iteration and start over, or keep a track of pending changes and wait until the iteration is complete before actually making the changes.  
	\item You will probably want to keep track of which additions are part of your balanced adder trees, and then skip over them in Step 1.  Otherwise you can end up in an endless loop of replacing your balanced adder trees with new identical adder trees.  The other benefit of this approach is that you don't need to check whether existing adder networks in the user's code are balanced or not.  Simply replace them with a balanced adder tree regardless of whether the existing structure is already optimal.
	\item Since you are modifying the original program, you may want to double check that you haven't broken the functionality.  For the {\tt simple\_unrolled\_partitioned} example, I have made it self checking, and it prints {\tt CORRECT} or {\tt ERROR} depending on whether the sum is correct.  You can use the LLVM IR emulator ({\tt lli}) to execute the IR code.  For example:
	\begin{lstlisting}
simple_unrolled_partitioned> ../../../llvm/Release+Asserts/bin/lli simple.bc 
CORRECT

	\end{lstlisting}
\end{itemize}

\section{LLVM Coding Tips}
Here are a few suggestions to help you with the LLVM API.  If you are still unsure how you do something in LLVM, please post on Piazza and I would be happy to help you out.

\subsection{Resources}

The LLVM documentation for version 3.5 (the version bundled with this LegUp release) is located at \url{http://releases.llvm.org/3.5.0/docs/index.html}.  Probably the most useful page is the Programmers Manual (\url{http://releases.llvm.org/3.5.0/docs/ProgrammersManual.html}).

\subsection{The LLVM Classes}
\label{sec:llvm_classes}

LLVM is an object-oriented code base, with lots of inheritance.  In assignment 2, you used the {\tt Instruction} class.  You can find documentation on it at \url{http://llvm.org/docs/doxygen/html/classllvm_1_1Instruction.html}.  Usually the quickest way to find these documentation pages is a google search.

Take a look at the illustrated class hierarchy on that webpage.  You will see that {\tt Instruction} inherits from {\tt User}, which in turn inherits from {\tt Value}.  \textbf{From LLVM programmers manual}: 
\begin{itemize}
  \item \textbf{Value:} The Value class is the most important class in the LLVM Source base. It represents a typed value that may be used (among other things) as an operand to an instruction. There are many different types of Values, such as Constants, Arguments. Even Instructions and Functions are Values.
	\item \textbf{User:} The User class is the common base class of all LLVM nodes that may refer to Values. It exposes a list of “Operands” that are all of the Values that the User is referring to. The User class itself is a subclass of Value.
	\item \textbf{Instruction:} The Instruction class is the common base class for all LLVM instructions. It provides only a few methods, but is a very commonly used class. The primary data tracked by the Instruction class itself is the opcode (instruction type) and the parent BasicBlock the Instruction is embedded into. To represent a specific type of instruction, one of many subclasses of Instruction are used.
\end{itemize}

In this assignment you will be frequently using the {\tt add} instruction.  This instruction is of type {\tt BinaryOperator} (a subclass of {\tt Instruction}), which is used by all instructions that operate on two pieces of data (thus Binary).  To check if it is an adder, you can call {\tt getOpcode()}, which for an adder will return the constant {\tt Instruction::Add}.

\subsection{Debugging}

In LLVM, you can use ``{\tt dbgs() <<}" to print out just about any class you want.  You can print Values, Users, Instructions, BasicBlocks, Functions, etc.  Just keep in mind that to print an object you should use the object itself, not a pointer to the object.  If you have a pointer, you should dereference it, such as:
\begin{lstlisting}
Instruction * I = ...;
dbgs() << *I << "\n";
\end{lstlisting}

\subsection{Checking Instruction Types}

When iterating through the {\tt Instruction} objects in a basic block, you may need to check the type of Instruction.  This can be done a few different ways.  For example, here are a few ways to check if an {\tt Instruction} is a {\tt BinaryOperator}.

\begin{lstlisting}
Instruction * I;
if (isa<BinaryOperator>(I)) {
   // I is a BinaryOperator
}
\end{lstlisting}

\begin{lstlisting}
Instruction * I;
if (BinaryOperator * bo = dyn_cast<BinaryOperator>(I)) {
    dbgs() << "Instruction is a binary operator with opcode " << bo->getOpcode() << "\n";
}
\end{lstlisting}


\subsection{Creating Instructions}

Generally to create new instructions, you do not call the constructor directly, but rather call a static class method.  For example, one way to create a new {\tt add} instruction:

\begin{lstlisting}
Value * in1 = ...
Value * in2 = ...
BinaryOperator * bo = BinaryOperator::Create(BinaryOperator::Add, in1, in2, "myInsnName", (Instruction*) NULL);
\end{lstlisting}

The last argument in this case in the {\tt Instruction} location where this new instruction should be inserted.  The new instruction is inserted before the instruction passed in.  If you pass in NULL, the new instruction is not inserted into the code, but you will need to do so later.

\subsection{Inserting Instructions}
There are many ways to insert instructions into a basic block.  These are discussed in the Programmers Manual ( \url{http://releases.llvm.org/3.5.0/docs/ProgrammersManual.html#creating-and-inserting-new-instructions} )

Some commands you may find helpful:

\begin{enumerate}

\item {\tt (BasicBlock\&).getInstList().insert(Instruction * InsertBefore, Instruction * I);}
	\begin{itemize}
		\item Inserts instruction {\tt I} immediately preceeding instruction {\tt InsertBefore}.		
	\end{itemize}
	
	
	\item {\tt ReplaceInstWithInst()}
	
	
	\begin{itemize}
		\item Adds the instruction {\tt To} to a basic block, such that it is positioned immediately before {\tt From}
		\item Replaces all uses of {\tt From} with {\tt To}
		\item Removes {\tt From}
	\end{itemize}



\begin{lstlisting}
/// ReplaceInstWithInst - Replace the instruction specified by From with the
/// instruction specified by To.
///
void llvm::ReplaceInstWithInst(Instruction *From, Instruction *To);
\end{lstlisting}

\item {\tt ReplaceInstWithValue()} 
	\begin{itemize}
		\item Replaces all uses of the instruction referenced by the iterator {\tt BI} with the Value {\tt V}
		\item Removes the instruction referenced by the iterator {\tt BI}
	\end{itemize}

\begin{lstlisting}
/// ReplaceInstWithValue - Replace all uses of an instruction (specified by BI)
/// with a value, then remove and delete the original instruction.
///
void llvm::ReplaceInstWithValue(BasicBlock::InstListType &BIL,
                                BasicBlock::iterator &BI, Value *V);
\end{lstlisting}

	This is similar to \#2, except that it doesn't add {\tt V} into the code anywhere -- it assumes this was already done.  It also requires you to pass in an interator to the old instruction, rather than a pointer to the instruction itself.  This can easily be done with code such as the following: 

\begin{lstlisting}
BinaryOperator * oldAdder = ...;
BinaryOperator * adderTree = ...;
BasicBlock::iterator BI(oldAdder);
ReplaceInstWithValue(BB.getInstList(), BI, adderTree);
\end{lstlisting}



\end{enumerate}






\section{Deliverables}
\label{sec:deliverables}

Create the code to perform adder tree balancing, and collect the results described in this section.

%Remember to change the code in {\tt GenerateRTL.cpp} to use the build-in LegUp SDCScheduler, instead of the scheduler you created for Assignment 2.  If you want to test it out with your scheduler, by all means go for it!  But for the numbers you submit in the report, you should use the LegUp scheduler so that the scheduling is consistent between all class members.

For the {\tt simple\_unrolled\_partitioned} program, obtain the missing results in the following table (there are 8 cells in the table to fill in), and include the completed table in your report.  You can find the HLS schedule by looking at the {\tt scheduling.legup.rpt} file, and the longest path by looking at the {\tt timingReport.legup.rpt} file, which lists the longest paths by function (when I used this it wasn't reporting the longest path correctly for the {\tt my\_rand()} function.  That's fine, just ignore that and use the timing from {\tt main}, which is all we care about).  The cycles per loop iteration can be obtained from the scheduling report, by manually looking at how many states are created for the summation loop.  The total summation time is simply the product of the longest path, loop iteration latency, and number of iterations (20).

\begin{table}[h!]
\centering
\begin{tabular}{|l|r|r|r|} \hline
\multicolumn{4}{|c|}{CLOCK\_PERIOD $\le$ 20ns} \\ \hline
& Longest Path (ns) & Loop iteration latency & Summation Time (ns) \\ \hline
WITHOUT TreeBalancer & 19.97 & 3 & 1198.2\\ \hline
WITH TreeBalancer & & & \\ \hline
Speedup & - & - & ?x \\ \hline
\end{tabular}

~~~

\begin{tabular}{|l|r|r|r|} \hline

\multicolumn{4}{|c|}{CLOCK\_PERIOD $\le$ 5ns} \\ \hline
& Longest Path (ns) & Loop iteration latency & Summation Time (ns)  \\ \hline
WITHOUT TreeBalancer & 4.99 & 6 &  598.8\\ \hline
WITH TreeBalancer & &  &\\ \hline
Speedup & - & - & ?x \\ \hline
\end{tabular}
\end{table}




\begin{enumerate}
\item Submit a report containing the following items:
\begin{itemize}
	  \item Your name
		\item The table from \cref{sec:deliverables}.
		\item Explain the approach you used for your code.
		\item In this assignment we didn't worry about the order of operations of the additions.  Does this matter?  Could we use the same technique for other operations?  subtraction, multiplication, floating foint operations, etc?  Why or why not?  What considerations or work-around might you employ to support such operations?
				
		\item Feedback:
		\begin{itemize}
		\item How many hours you spent on the assignment?  
		\item How challenging was the C++ coding?
		\item Anything you liked?
		\item Anything you didn't like? Or anything you would change?
		\item Did you find the assignment worthwhile? Why or why not?	
		\end{itemize}
		
		
\end{itemize}

\item Submit your source code.  If you only change the one .cpp file, then only submit that file.
\end{enumerate}



\section{Submission Instructions}
Submit your report and source code to \href{mailto:jgoeders@byu.edu}{jgoeders@byu.edu} with the subject: 625 Asst2


\end{document}

