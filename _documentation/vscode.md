---
layout: page
toc: false
title: Compiling and Running Programs on the PYNQ Board
short_title: Compiling Programs
indent: 1
number: 9
---


## Repo Structure 
Look through the files provided to you in the Git repo.  There are some helpful explanations in the README.md <https://github.com/byu-cpe/ecen427_student>.  

## Writing Code

Open your Git repo directory in VSCode using the folder view, with the Remote SSH extension, as described previously.  This will allow you to create and edit files directly on your PYNQ.

## Build System

### CMake 

To build your user space programs, you are required to use CMake.  CMake is a tool that will automatically create Makefiles for you, based on a configuration file called `CMakelists.txt`.  CMake is already set up in the provided repo. 

You can look at the top-level [CMakeLists.txt](https://github.com/byu-cpe/ecen427_student/blob/master/userspace/CMakeLists.txt) file provided to you.  *Note:* This file is located in your `userspace` folder.  For the first few labs of the class you will be writing code that runs in Linux user space, so all of your code will be placed within this folder.  Later, beginning in Lab 4, you will write kernel code that will be located in the `kernel` folder, but this will not be built using the CMake system.

For Lab1, you are provided a *Hello, World* application, [main.c](https://github.com/byu-cpe/ecen427_student/blob/master/userspace/apps/lab1_helloworld/main.c).


Note that the top-level [CMakeLists.txt](https://github.com/byu-cpe/ecen427_student/blob/master/userspace/CMakeLists.txt) file has a `add_subdirectory(apps)` statement, which will instruct CMake to process the apps [CMakeLists.txt](https://github.com/byu-cpe/ecen427_student/blob/master/userspace/apps/CMakeLists.txt) file.  This in turn has a `add_subdirectory(lab1_helloworld)` statement that will process the lab1 [CMakeLists.txt](https://github.com/byu-cpe/ecen427_student/blob/master/userspace/apps/lab1_helloworld/CMakeLists.txt) file.  The contents of these files are explained below.

### Compiling Your Code 


To compile the Lab1 executable, you need to navigate to the build directory, and then run CMake and point it to the top-level CMakeLists.txt file, like so:

    cd userspace/build
    cmake ..

This will produce a Makefile in your build directory.  Run it to compile the *Hello, World* application.

    make


**Tip:** Although CMake takes a minute to run the first time, you won't need to run it ever again (unless you completely delete your build directory).  Once CMake has been run once and has set up the Makefile system, you can just re-run `make` for any future changes.  Even if you change the CMake files, the system is set up so that the generated Makefile will detect these updates, and automatically call CMake to update itself.

<span style="color:blue">**IMPORTANT:**</span> Never run ''cmake'' from anywhere but your *build* directory.  It creates *many* temporary files that will clutter up your source files.

### Running Your Code 
From within the build directory you can run the following to execute the Lab 1 *Hello, World* program:

    ./apps/lab1_helloworld/helloworld


### Understanding the CMakeLists.txt files 

The top-level [CMakeLists.txt](https://github.com/byu-cpe/ecen427_student/blob/master/userspace/CMakeLists.txt) file contains the following:

    cmake_minimum_required(VERSION 3.4)

The first line in the CMakeLists.txt file is found at the beginning of most CMake files and indicates the minimum version of CMake that your makefile supports.

    set(CMAKE_BUILD_TYPE Debug)

This line instructs CMake to pass the debug flag (''-g'') to the GCC compiler.  This can help you track down the source of segmentation faults.

    include_directories(drivers)

The `include_directories` statement instructs CMake where to look for header (*.h*) files.  In Lab 2 you will create some drivers with associated header files that you will want to include in your application code.  This line ensures the compiler will find your driver header files.

    add_subdirectory(drivers)
    add_subdirectory(apps)

These lines instruct CMake to look in these directories for additional CMakeLists.txt files and process them.


The Lab 1 [CMakeLists.txt](https://github.com/byu-cpe/ecen427_student/blob/master/userspace/apps/lab1_helloworld/CMakeLists.txt) file contains the following: 

    add_executable(helloworld main.c)

This directs CMake to create a new executable program.  The first argument is the name of the executable, which in this case is `helloworld`.  The remaining arguments to the command provide a list of source code files, which in this case is only main.c.


## Backing up Your Code

You should commit your files and push them up to Github <ins>**OFTEN!!**</ins>.  **We will not make any special accommodations for students that lose their code because they were not pushing their code up to Github frequently.**. 


