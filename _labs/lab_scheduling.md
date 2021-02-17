---
layout: lab
toc: true
title: Scheduling
number: 3
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
In this lab you are going to write an HLS scheduler that operates on LLVM intermediate representation (assembly-like code).  You are going to formulate a schedule (ie, pick a cycle number for each instruction), such that the schedule completes are soon as possible.  But you can't just run all the instructions at once! You need to respect data and memory dependencies, as well as respecting functional unit limits (ie. you can't read unlimited things from memory at once), and the critical path constraint.

This provided code isn't part of a real HLS tool (your schedule won't be used to produce any RTL), but the concepts and techniques are very similar to what is done in commerical HLS tools.

Like the last lab, you will be writing an LLVM pass.  Your pass won't be changing the LLVM code, but rather reading the LLVM IR for a basic block (DAG), and using information about the hardware units for each instructions in order to determine a good HLS schedule.

### Compiling your LLVM pass
Your pass code and [CMakeLists.txt](https://github.com/byu-cpe/ecen625_student/blob/main/lab_scheduling/src/CMakeLists.txt) file are provided in the `src` directory. Your LLVM pass will be a `FunctionPass`, and will be run via the `runOnFunction()` function:
```
bool Scheduler625::runOnFunction(Function &F) {
  ...
}
```
The code for this function is already given to you.   You can look through it and see that it will call `scheduleASAP()` and `scheduleILP()` to perform the scheduling, and then generate the reports that you should have already used last lab.

You can compile this pass in the same manner as last lab:
```
cd build
cmake ../src
make
```

This will produce your library `scheduler_625.so`.  
<!-- You can now go back and try re-compiling the `simple` benchmark.  You should now see an "Invalid schedule" error, since you haven't coded up the scheduler yet! -->


### Running Your Scheduler
You can run your scheduler the same way you ran the provided scheduler in the last lab, except you should define `MYSCHEDULER=1`.  For example, you can schedule the  `simple` benchmark:
```
cd benchmarks/simple
make schedule MYSCHEDULER=1
```

You don't need to run your ATB pass from last lab, so just always run `make schedule` and not `make atb_schedule` when gathering your results.  (Of course you're always welcome to try your scheduler out on your ATB-generated IR code if you want to try it out.)

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

I've given you a few aids to help you debug your code.  You will see that after calling your scheduling functions I will print the schedule out, and then validate it.  The validation checks that the schedule is functionally correct, that is, it checks that you have assigned all instructions to states, that data dependencies are met, that available functional units are not exeeded. If you specify a target period (discussed later), it will also check that the critical path is within the constraint.  It does not check that your solution is good!  You could create a very bad schedule that simply executed each instruction in a different cycle, which may pass validation, but will not get you a very good grade on the assignment.

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
* `lprec *` Not a function, but the structure which contains your ILP problem.  This will be initialized from `make_lp()` and you will pass it into every other function you call.   Unfortunately lp_solve is not object oriented.
* `make_lp()` To create a new ILP problem. 
* `add_constraintex()` To add a new constraint using sparse column format.
* `set_obj_fnex()` To set the objective function using sparse column format.
* `set_minim()` or `set_maxim()` To select minimization or maximization of objective.
* `write_LP()` if you wish to output the ILP after it is formed.
* `solve()` To solve the problem.
* `get_variables()` To extract the solution.	

Documentation on these functions can be found online.  Post on Piazza if you have further questions.

## Implementation

### Part 1: ASAP Scheduler (20% of grade)

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

Try this scheduler out on the `simple` benchmark:
```
cd benchmarks/simple
make schedule MYSCHEDULER=1 ASAP=1
```

This program is simple enough that you should end up with a valid scheduling, even when ignoring resource constraints.  You can then test out the `simple_unrolled` example, to see that this scheduling technique fails on a more complicated design.

Look at the design and make sure you understand why it introduces issues with resource usage.

### Part 2: ASAP Scheduler with Resource Constraints (50% of grade)
For this deliverable you must write code to perform resource-constrained ASAP scheduling.  You will use an ILP formulation to determine an optimal scheduling.  Use the following approach:
* Use an ILP variable to represent the _start cycle_ of each Instruction.  This code is already provided to you.
* An extra variable is used to represent the NOP at the end of the schedule.
* Add constraints to ensure data dependencies are met.  If there is a dependency I<sub>1</sub>->I<sub>2</sub>, then create a dependency "S(I<sub>2</sub>) >= S(I<sub>1</sub>) + latency(I<sub>1</sub>)", where S(I) is the start cycle of Instruction I.
* Add resource constraints.  We will discuss for this in class, but the approach is that for each FunctionalUnit, you should find all Instructions that use it, then choose a heuristic ordering in order to _bind_ the Instructions to the available FunctionalUnits.  Then, for the various Instructions bound to each individual FunctionalUnit instance, their start times must be separated by at least the _InitiationInterval_ of the FunctionalUnit.
* Set the objective function to be start time of the terminating NOP.

The code to execute the ILP solver and extract the schedule is provided to you.

Once you have this implemented, test out the `simple_unrolled` example to see that a valid schedule is obtained.  Run your design like so:
```
make schedule MYSCHEDULER=1 ILP=1 
```

### Part 3: Adding timing constraints (20% of grade)

You can apply a 10ns clock period constraint to the schedule like so:
```
make schedule MYSCHEDULER=1 ILP=1 PERIOD=10.0
```

This will cause the Schedule validation code to also check that the delay of each combinational path is within the target period.  If you run this on the `simple` or `simple_runrolled` benchmarks, you should see that your scheduler now fails.

Add additional constraints to your ILP formulation to prevent long combinational chaining.  It's up to you to come up with a solution for this.  In my solutions I use a recursive function to search for all combinational paths that exist from one Instruction (I<sub>1</sub>) to another (I<sub>2</sub>) that exceed the target period, and esure that S(I<sub>2</sub>) > S(I<sub>1</sub>).  This will be challenging, and I don't expect everyone to finish this part, which is why it is worth less points than the previous section.

### Report (10% of grade) 
Include a short PDF report, located at `lab_scheduling/report.pdf`.  Include the following items:
* Why did we need to include the terminating NOP instruction in our problem formulation?
* Given an example of something else you could use ILP for.  Try to come up with something relating to your research.		
* Report the number of constraints you used for the `simple_unrolled` benchmark.  You can report the total for all you ILP forumlations (across each BasicBlock), or just the maximum of any BasicBlock.  Either is fine, just state in your report what you chose.  You can get this by keeping track yourself as you add the constraints, or printing the entire ILP formulation after you are done. There is no need to perform any optimizations to try and minimize the number of constraints; this is only included so that you can get a feel for the size of the ILP problem you are formulating. 
* If you completed Part 3, explain in a paragraph the approach you took.
    


## Submission 
Submit your code on Github using the tag `lab3_submission`
 
