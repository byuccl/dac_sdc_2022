---
layout: lab
toc: true
title: Scheduling
number: 2
repo: lab_scheduling
---


## Learning Outcomes
The goals of this assignment are to:
* Familiarize yourself with HLS scheduling algorithms.
* Use and explore a popular open-source HLS tool, LegUp, which is built on a widely used open-source compiler framework, LLVM.
* Gain experience formulating and coding linear programming solutions.
* Practice C++ skills.

## Getting Started

### Required Packages
```
sudo apt install llvm-9 libclang-common-9-dev clang-9 liblpsolve55-dev texlive-latex-base texlive-pictures
```

### How this lab works
In this lab you are going to write an HLS scheduler that operates on LLVM intermediate representation (assembly-like code).  You are going to formulate a schedule (ie, pick a cycle number for each instruction), such that the schedule completes are soon as possible.  But you can't just run all the instructions at once! You need to respect data and memory dependencies, as well as respecting functional unit limits (ie. you can't read unlimited things from memory at once). 

This provided code isn't part of a real HLS tool (your schedule won't be used to produce any RTL), but the concepts and techniques are very similar to what is done in commerical HLS tools.

### Running an LLVM Pass
Your scheduler is going to run as an LLVM pass.  This mean that after you compile a C program to LLVM IR, you are doing to run your pass on the LLVM IR. 

You are given a few different C programs in the `benchmarks` directory.  You can `cd` into these benchmark directories, and run `make` to compile them.  The provided [Makefile](https://github.com/byu-cpe/ecen625_student/blob/main/lab_scheduling/benchmarks/Makefile.common) will first run `clang` (C front-end compiler) to compile your C code into LLVM IR, and then run `opt` which is used to run analysis and optimization passes on IR.  Specifically the Makefile is set up to run your scheduling pass (`-sched625`).

Try this out for the `simple` benchmark:
```
cd benchmarks/simple
make
```

You will see an error:
```
.../scheduler_625.so: cannot open shared object file: No such file or directory
```

This is because we haven't compiled your compiler pass yet.  But you can still browse the LLVM IR produced by clang.  Look through the `simple.clang.ll` file and try to understand how it implements the `simple.c` program.

### Compiling an LLVM pass

While you could download the LLVM source code, and add your pass code to it, compiling LLVM from source can take 20-30 minutes.  Instead, we are going to develop your pass _out-of-tree_.  Above you should have installed the LLVM 9 binaries using the Ubuntu package manger.  We are going to compile your pass code into a shared library object (.so) file, than can be loaded by LLVM at runtime.

Your pass code and [CMakeLists.txt](https://github.com/byu-cpe/ecen625_student/blob/main/lab_scheduling/src/CMakeLists.txt) file are provided in the `src` directory.

Take a look at [Scheduler625.cpp](https://github.com/byu-cpe/ecen625_student/blob/main/lab_scheduling/src/Scheduler625.cpp), specifically these lines:

```
char Scheduler625::ID = 0;
static RegisterPass<Scheduler625> X("sched625", "HLS Scheduler for ECEN 625",
                                    false /* Only looks at CFG? */,
                                    true /* Analysis pass? */);

bool Scheduler625::runOnFunction(Function &F) {
  ...
}
```

The `RegisterPass` registers your pass with LLVM and specifies that it can be called using the `-sched625` flag.  The `Scheudler625` class is a subclass of `llvm::FunctionPass`, meaning this pass should be called for every function in the code.  Specifically, the `runOnFunction()` function will be called for each function in the IR.

Go ahead and compile the provided code:
```
cd build
cmake ../src
make
```

This will produce your library `scheduler_625.so`.  You can now go back and try re-compiling the `simple` benchmark.  You should now see an "Invalid schedule" error, since you haven't coded up the scheduler yet!

### How Scheduling Works

In our pretend HLS tool, we're going to assume that it will create a circuit that executes the instructions from one basic block at a time. That is, all instructions within a basic block will execute before transitioning to the next basic block (this approach is used in many HLS tools).  This means that we really only need to worry about scheduling the instructions relative to each other within each _Basic Block_.  If our schedule was used by an actual HLS tool, it would generate controlling logic that would then sequence the execution of these different basic blocks.  

The provided code will schedule the Instructions within each Basic Block one at a time:
```
// Loop through basic blocks
for (auto &bb : F.getBasicBlockList()) {
  if (ILPFlag)
    scheduleILP(bb);
  else
    scheduleASAP(bb);
}
  ```

The bulk of this assignment will be implementing these two scheduling approaches: `scheduleASAP()` and `scheduleILP()`.

## Code Framework

In the two scheduling functions you should write code that schedules the `Instruction`s of a basic block to a set of cycle numbers (0, 1, 2, 3, ..., n).  You can do this by populating the following data structure:
```
std::map<Instruction *, int> Scheduler625::schedule;
```
Not all instructions need to be scheduled.  Some instructions don't get translated into hardware logic.  You can check using the following:
```
static bool SchedHelper::needsScheduling(Instruction &I);
```
For example, the following code is a very simple (and invalid) scheduler that would schedule all Instructions to cycle number 0.
```
for (auto & I : bb) {
  if (!SchedHelper::needsScheduling(I))
    continue;
  schedule[&I] = 0;
}
```

### Debugging

I've given you a few aids to help you debug your code.  You will see that after calling your scheduling functions I will print the schedule out, and then validate it.  The validation checks that the schedule is functionally correct, that is, it checks that you have assigned all instructions to states, that data dependencies are met, that available functional units are not exeeded. If you specify a target period (discussed later), it will also check that the critical path is within the constraint.  It does not check that your solution is optimal!  You could create a very bad schedule that simply executed each instruction in a different cycle, which may pass validation, but will not get you a very good grade on the assignment.

### Getting the Info You Need

LLVM has no idea that you are going to perform mock HLS scheduling, and knows nothing about the potential hardware we are going to target.  As such, you are given some extra classes that contain the information you need:
* `FunctionHLS`: This is a wrapper aound each `Function` and contains HLS-specific information for the function.  This object is available as a private variable `fHLS` inside your Scheduler class.  It provides the following information:
  * `FunctionalUnit *getFU(Instruction &I)` returns the `FunctionalUnit` for an Instruction. This will return NULL for certain Instructions that don't require hardware units (ie control-flow instructions). 
  * `std::vector<Instruction *> &getDeps(Instruction &I)` returns a list of Instructions that the scheduling of Instruction `I` is dependent upon.  These dependencies will always be Instructions that execute earlier in the same BasicBlock.  This includes:
    * _Data dependencies:_ For example, if `I`=`%3 = add %1, %2` then both the `%1 = ...` and `%2 = ...` Instructions could be in the list.
	* _Memory dependencies:_ For example, if you have two instructions that access the same physical memory, `store %A, %1` and `load %A, %2`, then the former would be included in the dependency list of the latter.

* `bool needsScheduling(Instruction &I)`: Not all Instructions need to be scheduled.  Make sure you check this value before trying to schedule an Instruction.  For example, if you pass a non-scheduled Instruction to `getDeps()` it will throw an error.
* `int SchedHelper::getInsnLatency(Instruction &I)`: Returns the number of cycles of latency for Instruction `I`.  For example, a latency of 1 means the data produced by this operation can be used in the next cycle.  A latency of 0 means that this Instruction is implemented by purely combinational logic, and it's output can be _chained_ into the input of another operation in the same cycle. 
* `double getInsnDelay(Instruction &I)`: Returns the estimated nanosecond delay for Instruction `I`.  This is useful if you want to limit _chaining_ to meet a certain clock frequency.
* `FunctionalUnit`: This class represents a hardware functional unit that implements an operation.
  * `int getNumUnits()`: The represents how many Instructions can use this unit at one time.  For example, `load` and `store` Instructions will access dual-ported RAMs on the FPGA that allow **two** memory operations to be issued at once.  Most operations (addition, subtraction, comparison, etc) can be implemented using the FPGA fabric.  For the "fabric" FunctionalUnit, a 0 is returned, indicating there is no limit placed on the number of these functional units. 
  * `int getInitiationInterval()`: Even though some FunctionalUnits may have a multi-cycle latency, _pipelining_ allows for these units to accept new data more often than the latency.  This function returns the cycle interval that new data can be provided.  For example, a `load` operation will take two cycles to retrieve the data, but a new read request can be issued each cycle.

  
### Integer Linear Programming

In this assignment we will use the `lp_solve`} linear programmer tool.  We will discuss formulating ILP problems in class.  Generally you should use the following functions (in this order), to set up and solve an ILP problem:
* `lprec *` Not a function, but the structure which contains your ILP problem.  This will be initialized from `make_lp()` and you will pass it into every other function you call.   Unfortunately lp\_solve is not object oriented.
* `make_lp()` To create a new ILP problem. 
* `add_constraintex()` To add a new constraint using sparse column format.
* `set_obj_fnex()` To set the objective function using sparse column format.
* `set_minim()` or `set_maxim()` To select minimization or maximization of objective.
* `write_LP()` if you wish to output the ILP after it is formed.
* `solve()` To solve the problem.
* `get_variables()` To extract the solution.	

Documentation on these functions can be found online.  Post on Piazza if you have further questions.

## Implementation

### Part 1: ASAP Scheduler (20\% of grade)

For this deliverable you must write code to perform unconstrained ASAP scheduling.  See section 5.3.1 from the textbook.  Unconstrained means you do not need to consider resource or timing constraints.  You still need to consider data dependencies.

This is to be completed in the following function:
```
void Scheduler625::scheduleASAP(BasicBlock &bb) {}
```

For this function, don't create an ILP solution.  You can simply treat the instructions in the basic block as a topologically sorted DAG and propagate start times as you work through the list of instructions.  This should be a fairly simple task, especially considering the previous assignment, and is mainly to get you used to the APIs and data structures.

A few pieces of advice:
* Remember, not every `Instruction` in the `BasicBlock` needs to be scheduled.  Call `SchedHelper::needsScheduling()` to check.
* The terminating Instruction (branch, return) should always be scheduled in the last cycle.  This can be done like so:
```
schedule[bb.getTerminator()] = getMaxCycle(bb);
```

Try this scheduler out on the `simple` benchmark.  This program is simple enough that you should end up with a valid scheduling, even when ignoring resource constraints.  You can then test out the `simple_unrolled` example, to see that this scheduling technique fails on a more complicated design.

Look at the design and make sure you understand why it introduces issues with resource usage.

## Part 2: ASAP Scheduler with Resource Constraints (50% of grade)
For this deliverable you must write code to perform resource-constrained ASAP scheduling.  You will use an ILP formulation to determine an optimal scheduling.

The approach we will be using is described in Section 5.4.1 of the textbook.   We will go through this in class.

Although the full details are in the textbook, I will provide a brief description here.  The algorithm works by establishing a \textbf{boolean} LP variable for every Instruction in the basic block, and every possible start time, which indicates whether the Instruction is scheduled to start at that cycle number.  In the textbook this is defined as $x_{il}$.  This variable is 1 if Insturction $i$ starts execution at time $l$, and 0 otherwise.  You will see in the code I have given you, I have added another set of variables for the terminating NOP instruction (See Figure 5.8 in the textbook).  I have also given you a function which returns the maximum possible number of cycles in the basic block.  Thus, the total number of boolean LP variables for a basic block are $(number\_of\_isntructions + 1)\cdot max\_mum\_cycles$ (the +1 is for the NOP).

You will need to formulate the ILP problem by:
\begin{itemize}
	\item Adding constraints to ensure every instruction is scheduled to exactly 1 cycle (equation 5.8 from textbook)
	\item Addding data dependency constraints (equation 5.9 from textbook)
	\item Adding resource constraints (equation 5.10 from textbook)
	\item Set the objective function to be start time of the terminating NOP
\end{itemize}

The code to execute the ILP solver and extract the schedule is provided to you.

This is to be completed in the following function (you are free to add additional private member functions to the class as needed):
\begin{lstlisting}
void Scheduler625::scheduleIlp(Function *F, SchedulerDAG *dag) {
}
\end{lstlisting}

Once you have this implemented, test out the {\tt simple\_unrolled} example to see that a valid schedule is obtained.   You can then modify the design configuration ({\tt simple\_unrolled/config.tcl}) to reduce the target clock period to the point where your scheduler fails due to timing constraints.



## Part 3: Adding timing constraints (20% of grade)
Update your code from the previous section to also consider timing constraints (ie. critical path delay).  This will be challenging, and I don't expect everyone to finish this part, which is why it is worth less marks than the previous section.


\subsection{Part 4: Report (10\% of grade)}


\begin{enumerate}
\item Submit a report containing the following items:
\begin{itemize}
	  \item Your name
		\item Why did we need to include the terminating NOP instruction in our problem formulation?
		\item Given an example of something else you could use ILP for.  
		Try to come up with something relating to your research.		
		\item Include the {\tt scheduling.legup.rpt} for the {\tt simple} and {\tt simple\_unrolled} programs.
		
		\item If you completed Part 3, explain in a paragraph the approach you took.
		
		
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
Submit your report and source code to \href{mailto:jgoeders@byu.edu}{jgoeders@byu.edu} with the subject: 625 Asst3


\end{document}

