---
layout: lab
toc: true
title: LLVM
number: 2
repo: lab_llvm
---


## Background

### Learning Outcomes
The goals of this assignment are to:
* Understand the benefits of applying optimizations to the IR code, prior to the standard HLS algorithms.
* Gain experience using LLVM to modify the IR code of a program.
* Practise C++ skills.


### Motivation
In this assignment you will get to write your own compiler optimization pass!  You will use LLVM (a commonly used compiler, like GCC).  The goal of the transformation will be to identify adder trees in the IR, and perform tree balancing, as shown below.  This optimization is especially helpful when targeting hardware.

<img src="{% link media/llvm/balancer_example.svg %}" width="600">

Consider the following code (from [simple.c](https://github.com/byu-cpe/ecen625_student/blob/main/benchmarks/simple/simple.c)) that sums the values of a 100-entry array.
```
int A[100];
for (int i = 0; i < 100; i++)
    sum += A[i];
```

To implement this in hardware, we could build an RTL circuit with a state machine that repeatedly read a value from memory, added it to a sum register, and incremented the address.  We could also use an HLS tool to build that RTL for us, and it may take a similar approach if no optimizations were applied.

The code could be made much faster by performing multiple loop iterations in parallel.  This is referred to as _loop unrolling_.  


The following code, (from [simple_unrolled_partitioned/simple.c](https://github.com/byu-cpe/ecen625_student/tree/main/benchmarks/simple_unrolled_partitioned)), shows the array summation  unrolled by a factor of 10.  One issue with unrolling like this is that it is usually not possible to load 10 values from memory at once.  If values are loaded sequentially, there will be little to no benefits to loop unrolling.  To get around this problem, the code also includes _memory banking_, where the  `A` array is split into 5 equal sized arrays, `A1`, `A2`, `A3`, `A4`, and `A5`.  Each of these can be placed in a separate dual-ported memory, allowing us to read 10 values from memory simultaneously.  (_While this C code implements loop unrolling and memory banking manually, modern HLS tools will do this for you when requested.  Certain tools may even be smart enough to do it automatically._)


```
int A1[20];
int A2[20];
int A3[20];
int A4[20];
int A5[20];

for (int i = 0; i < 20; i += 2) {
    sum += A1[i] + A1[i + 1] + 
           A2[i] + A2[i + 1] + 
           A3[i] + A3[i + 1] +
           A4[i] + A4[i + 1] + 
           A5[i] + A5[i + 1];
```

The above code will end up creating a cascading adder tree as shown in the left side of the figure above.  We would like to automatically optimize the IR to balance the adder tree, producing a structure similar to the right-hand side of \cref{fig:balancer_example}.  This optimization can improve the critical path of the resulting hardware, or if timing constraints are imposed, reduce the latency of each loop iteration.

## Getting Started

### Required Packages
```
sudo apt install llvm-9 llvm-9-dev libclang-common-9-dev clang-9 liblpsolve55-dev texlive-latex-base texlive-pictures
```

### Running LLVM 
Your scheduler is going to run as an LLVM pass.  This means that after you compile a C program to LLVM IR, you are doing to run your pass on the LLVM IR. 

You are given a few different C programs in the `benchmarks` directory.  You can `cd` into these benchmark directories, and run `make <target>` to compile them.  Try running just  `clang` (C front-end compiler) to compile the `simple` benchmark your C code into LLVM IR.

```
cd benchmarks/simple
make clang
```

The provided [Makefile](https://github.com/byu-cpe/ecen625_student/blob/main/benchmarks/simple_unrolled_partitioned/Makefile) will first run `clang-9` to produce a binary IR file (`simple.clang.bc`), after which it will run `llvm-dis-9` to dissassemble the binary into human readable IR (`simple.clang.ll`)

Look through the LLVM IR file and try to understand how it implements the `simple.c` program.  Then go to the `simple_unrolled_partitioned` bechmark and look at the IR that program produces.  Make sure you can find the long sequence of cascaing add instructions.

### Writing an LLVM pass

While you could download the LLVM source code, and add your pass code to it, compiling LLVM from source can take 20-30 minutes.  Instead, we are going to develop your pass _out-of-tree_.  Above you should have installed the LLVM 9 binaries using the Ubuntu package manger.  We are going to compile your pass code into a shared library object (.so) file, than can be loaded by LLVM at runtime.

Your pass code and [CMakeLists.txt](https://github.com/byu-cpe/ecen625_student/blob/main/lab_llvm/src/CMakeLists.txt) file are provided in the `src` directory. For this assignment we will be using a `BasicBlockPass` in LLVM.  That is, it is a transformation pass that modifies code contained with a single basic block.  

Take a look at [AdderTreeBalancer.cpp](https://github.com/byu-cpe/ecen625_student/blob/main/lab_llvm/src/AdderTreeBalancer.cpp), specifically these lines:

```
char AdderTreeBalancer::ID = 0;
static RegisterPass<AdderTreeBalancer> X("ATB_625", "Adder Tree Balancer Pass");

bool AdderTreeBalancer::runOnBasicBlock(BasicBlock &BB) {
	...
}
```


The `RegisterPass` registers your pass with LLVM and specifies that it can be called using the `-ATB_625` flag.  The `AdderTreeBalancer` class is a subclass of `llvm::BasicBlockPass `, meaning this pass should be called for every BasicBlock in the code.  Specifically, the `runOnBasicBlock()` function will be called for each BasicBlock.


You can also create passes that operate at different scopes, including Module (entire C program), Function, Loop, Region, and more.  More information on these types of passes can be found at [WritingAnLLVMPass](https://releases.llvm.org/9.0.0/docs/WritingAnLLVMPass.html).


Go ahead and compile the provided code:
```
cd lab_llvm/build
cmake ../src
make
```

This will produce your library `ATB_625.so`.  

### Running Your LLVM Pass

The benchmark Makfile contains several targets that can be used to run your AdderTreeBalancer pass.:
* `make atb`: This will run your pass, followed by dead code elimination (which will remove unused instructions).  This will produce a file `*.atb.ll` which contains the LLVM IR after your pass is run.
* `make atb_check`: Since you are modifying the original program, you will want to double check that you haven't broken the functionality. This target will first run the `atb` target to produce the transformed IR, followed by running it using the LLVM emulator (`lli`).  The `simple_unrolled_partitioned` and `shared_add_tree` benchmarks both print **CORRECT** or **ERROR**, depending on whether the sum is correct. 
* `make atb_schedule`: This will run the `atb` pass, and then pass the new LLVM IR to an HLS scheduler, which will determine which instructions can run in each cycle in hardware.  This will produce PDF files which display the schedule of each IR instructions.  If you implement the pass correctly, you will see improvements made to the produced schedule.
* `make schedule`: This will run the HLS schedule without your ATB pass.


### Code Organization

* `lab_llvm/src/AdderTreeBalancer.cpp/.h` -- You will add all your code for this assignment in theses files.  You are welcome to add additional source files if you like.

* `benchmarks` -- This contains some C programs to test your code.  You are welcome to test your pass with any design in this folder (or create your own test designs); however, only the `simple_unrolled_partitioned` and `shared_add_tree` designs have large adder trees.  The `shared_add_tree` design has an adder tree used by another adder tree, so it's useful to test that you are handling that correctly (see the first tip listed later on this page).

## Implementation

How you code the tree balancer is up to you.  

You probably want to follow this general approach:
1. Look through the Instructions in the BasicBlock for add instructions, treat this instruction `I` as the root of an adder tree, and collect a list of inputs to this adder tree.
2. Create a balanced adder tree with these inputs, and add these new `add` instructions to the BasicBlock.	
3. Replace uses of the root adder instruction, `I`, with the output of your newly created adder tree.
4. Repeat until all adder trees are balanced.

Some tips with this approach:
* When recursively visiting adders, you need to make sure the output of an intermediate node is not used elsewhere in the code.  You can do this by checking that the number of uses is one (`Value.getNumUses()`).  The reason for this is that all of these instructions will be deleted and replaced by your adder tree; only the final output of the adder tree can be used multiple places in the code.
* The inputs to your adder tree may be instructions, constants, function arguments, etc.  You should use the LLVM `Value` to keep track of the inputs.
* You will need to add all of your newly created addition instructions to the BasicBlock.  Make sure you add them in a valid position, and order (ie. the final addition in your tree should be located before any uses, and adder nodes in your tree should be in a valid ordering).  If you are smart in how you create your adder tree, you can build a list of add instructions that are already in the correct order.  You can then add all of these add instructions immediately before instruction `I` (as described in Step 3 of the technique above).
* You don't need to delete the adder instructions you are replacing with your tree.  As long as you complete Step 3, these additions will become dead code.  Since dead code elimination is performed after your pass, these instructions will automatically be removed. Likewise, if you only complete Step 1 and 2, and never use your new adder tree, dead code elimination will remove it. 
* In Step 1 you are iterating over the BasicBlock.  However, if you end up inserting an adder tree, you are modifying the very data structure you are iterating over.  You cannot continue iterating at this point.  Either exit out of the iteration and start over, or keep a track of pending changes and wait until the iteration is complete before actually making the changes. 
* You will probably want to keep track of which additions are part of your balanced adder trees, and then skip over them in Step 1.  Otherwise you can end up in an endless loop of replacing your balanced adder trees with new identical adder trees.  **The other benefit of this approach is that you don't need to check whether existing adder networks in the user's code are balanced or not.  Simply replace them with a balanced adder tree regardless of whether the existing structure is already optimal.**


## LLVM Coding Tips
Here are a few suggestions to help you with the LLVM API.  If you are still unsure how you do something in LLVM, please post on Slack and I would be happy to help you out.

### Resources

We are using LLVM version 9.0.  The documentation can be found at <https://releases.llvm.org/9.0.0/docs/>.  Some useful pages:
* The [Language Reference Manual](https://releases.llvm.org/9.0.0/docs/LangRef.html) describes each LLVM IR instruction.
* The [Programmers Manual](https://releases.llvm.org/9.0.0/docs/ProgrammersManual.html) is a good place to start reading about coding in LLVM.

### The LLVM Classes

LLVM is an object-oriented code base, with **lots** of inheritance.  You can find auto-generated documentation for each class.  For example, check out the [Instruction](http://llvm.org/doxygen/classllvm_1_1Instruction.html) class.  Usually the quickest way to find these documentation pages is a google search.

Take a look at the illustrated class hierarchy on that webpage.  You will see that `Instruction` inherits from `User`, which in turn inherits from `Value`.  **From LLVM programmers manual**: 
* `Value`: The Value class is the most important class in the LLVM Source base. It represents a typed value that may be used (among other things) as an operand to an instruction. There are many different types of Values, such as Constants, Arguments. Even Instructions and Functions are Values.
* `User`: The User class is the common base class of all LLVM nodes that may _refer_ to other Values. It exposes a list of "Operands" that are all of the Values that the User is referring to. The User class itself is a subclass of Value.
* `Instruction`: The Instruction class is the common base class for all LLVM instructions. It provides only a few methods, but is a very commonly used class. The primary data tracked by the Instruction class itself is the opcode (instruction type) and the parent BasicBlock the Instruction is embedded into. To represent a specific type of instruction, one of many subclasses of Instruction are used.

In this assignment you will be frequently using the `add` instruction.  This instruction is of type `BinaryOperator` (a subclass of Instruction), which is used by all instructions that operate on two pieces of data (thus Binary).  To check if it is an adder, you can call `getOpcode()`, which for an adder will return the constant `Instruction::Add`.

### Debugging

In LLVM, you can use ``outs() <<`` to print out just about any class you want.  You can print Values, Users, Instructions, BasicBlocks, Functions, etc.  Just keep in mind that to print an object you should use the object itself, not a pointer to the object.  If you have a pointer, you should dereference it, such as:
```
Instruction * I = ...;
outs() << *I << "\n";
```

You can also use `report_fatal_error("message")` to stop execution immediately and report an error.

### Checking Instruction Types

When iterating through the `Instruction` objects in a BasicBlock, you may need to check the type of Instruction.  This can be done a few different ways.  For example, here are a few ways to check if an `Instruction` is a `BinaryOperator`.

```
Instruction * I;
if (isa<BinaryOperator>(I)) {
   // I is a BinaryOperator
}
```

```
Instruction * I;
if (BinaryOperator * bo = dyn_cast<BinaryOperator>(I)) {
    dbgs() << "Instruction is a binary operator with opcode " << bo->getOpcode() << "\n";
}
```


### Creating Instructions

Generally to create new instructions, you do not call the constructor directly, but rather call a static class method.  For example, one way to create a new `add` instruction:

```
Value * in1 = ...
Value * in2 = ...
BinaryOperator * bo = BinaryOperator::Create(BinaryOperator::Add, in1, in2, "myInsnName", (Instruction*) NULL);
```

The last argument in this case is a pointer to an existing `Instruction`, and the new Instruction will be inserted preceeding it. If you pass in NULL, the new instruction is not inserted into the code, but you will need to do so later.

### Inserting Instructions
There are many ways to insert instructions into a basic block.  These are discussed in the [Programmers Manual](https://releases.llvm.org/9.0.0/docs/ProgrammersManual.html#creating-and-inserting-new-instructions), although I have found this is somewhat out of date. In particular, the pages gives this example, but it is missing the required `->getIterator()` on the existing Instruction.

### Replacing Instructions or Usage
	
If you want to swap out an Instruction for a different one, there are a few options:	
```
void ReplaceInstWithInst(Instruction *From, Instruction *To);
```
This adds the instruction `To` to a basic block, such that it is positioned immediately before `From`, replaces all uses of `From` with `To` and then removes `From.
	
```
/// Replace all uses of an instruction (specified by BI) with a value, then
/// remove and delete the original instruction.
void ReplaceInstWithValue(BasicBlock::InstListType &BIL,
                          BasicBlock::iterator &BI, Value *V);
```						
This replaces all uses of the instruction referenced by the iterator `BI` with the Value `V`, and then removes the instruction referenced by the iterator `BI`.	This is similar to `ReplaceInstWithInst`, except that it doesn't add `V` into the code anywhere -- it assumes this was already done.  It also requires you to pass in an interator to the old instruction, rather than a pointer to the instruction itself.  This can easily be done with code such as the following: 

```
BinaryOperator * oldAdder = ...;
BinaryOperator * adderTree = ...;
BasicBlock::iterator BI(oldAdder);
ReplaceInstWithValue(BB.getInstList(), BI, adderTree);
```



## Deliverables

1. Submit your code on Github using the tag `lab2_submission`

2. Include a 1-page PDF document (`lab_llvm/report.pdf`) that includes the following:


For the `simple_unrolled_partitioned` program, obtain the missing results in the following tables (there are 8 cells to fill in), and include the completed tables in your report.  You can find the HLS schedule by looking at the `main.schedule.rpt` file, and the longest path by looking at the `main.timing.rpt` file, which lists the longest path for each BasicBlock.  The cycles per loop iteration can be obtained from the scheduling report (or Gantt chart PDF), by manually looking at how many states are created for the summation loop.  The total summation time is simply the product of the longest path, loop iteration latency, and number of iterations (20).

#### CLOCK_PERIOD <= 20ns 

|           | Longest Path (ns) | Loop iteration latency | Summation Time (ns) |
|-----------|------------------:|-----------------------:|--------------------:|
|WITHOUT TreeBalancer| 17.5     | 4                      |  1400               |
|WITH TreeBalancer   |          |                        |                     |
|Speedup             | -        | -                      | ?x                  |


#### CLOCK_PERIOD <= 5ns 

|           | Longest Path (ns) | Loop iteration latency | Summation Time (ns) |
|-----------|-------------------|------------------------|---------------------|
|WITHOUT TreeBalancer| 5.0      | 12                     | 1200                |
|WITH TreeBalancer   |          |                        |                     |
|Speedup             | -        | -                      | ?x                  |


