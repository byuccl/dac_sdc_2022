---
title: Coding Standard
layout: page
toc: true
icon: fas fa-terminal
---

### 1. General

* **1.1** You must write C-code. No class definitions are allowed. If you need a data-structure, it must be something supported by "C", such as a `struct`.

* **1.2** When compiled, your code must not cause the compiler to issue any warnings or errors. Some of the provided files in "supportFiles" generate warnings, and those can be ignored.

* **1.3** Your code, when submitted, must be in a finished form. You are allowed a total of 5 lines of "commented-out" code per file.

* **1.4** Avoid using repetitive sections of copied and pasted code in your programs.

* **1.5** Busy loops (delays based on for-loops) are not allowed, except for test code.

* **1.6** All code will be graded against the coding standard.

### 2. Comments
* **2.1** Comments must be _meaningful_. Make sure that your code completely describes your intent. If your code is unclear or does not completely describe what is going on, comment accordingly.

* **2.2** Each function (except for `main`) must have a comment header which includes:
    - A description of the function (what it does, what has to happen first, etc.).
    - A list of all of the arguments, their names, and meanings.
    - A description of the return value and its meaning.

* **2.3** Each time you create a new scope, such as when using `{}` braces, there must be a comment associated with it to describe what the code is doing. Loops and conditionals, for example, define a new scope.


### 3. Formatting
* **3.1** You must use the `clang-format` code formatter on your code. You must configure your system with the following settings:
    - BasedOnStyle: LLVM
    - IndentWidth: 4
    - UseTab: Never
