---
layout: lab
toc: true
title: Concurrent HTTP Server
number: 6
repo: https://github.com/byu-ecen493r-classroom/lab6.git
---

> Controlling complexity is the essence of computer programming.
> 
> Brian Kernighan

## GitHub Classroom

The GitHub Classroom link is posted as the topic of the Slack channel for the lab. You must use this link to accept the lab assignment. Once you have accepted the lab, the template repository you need to start the lab can be found [here](https://github.com/byu-ecen493r-classroom/lab6.git){:target="_blank"}.

## Overview

For this lab, you will be extending your HTTP server to handle multiple clients _at once_. The rest of your server will stay the same. There are multiple ways of supporting multiple clients. A typical approach is to spawn a new thread or process for each client that connects. That thread or process is responsible for communicating with a specific client. There is another approach that uses a system call (`poll` or `select`) to determine which sockets are ready to receive data from or write data to. Since with socket programming, most of the time your program is waiting around for the sockets to send or receive data, this allows your program to handle multiple sockets at once. Instead of creating a new thread or process for each client socket, one process keeps track of many sockets at once.

For this lab, we will be using threads to handle multiple clients concurrently. When a new request comes in, a thread is created and the socket is passed to that thread. The newly spawned thread is now responsible for receiving and sending data while the main thread is still accepting new clients. As mentioned in lecture, threads has their own set of issues, largely shared memory. To limit these issues, try to use local variables as much as possible. You should not need to use mutex/locks in this lab!

As part of writing a well behaving server, you will need to approperately handle the threads when you are exiting (the user hits `ctrl-c`). This allows your server to finishing handling clients that have already connected before shutting down the server. To do this, you must join all spawned threads.

Assuming you did lab 5 correctly, you shouldn't have to change anything except `main.c`.

Here is a demonstration of the server:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/dnDi3XXLFpE" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Objectives

- Learn how to use `pthread`.

- Learn how to make an HTTP server concurrent.


## Requirements

- You must be able to handle multiple concurrent clients at once using threads.

- You must gracefully shutdown your server, waiting for all client sockets to finish.

- The default port must be `8085`.

- All other requirements are the same as lab 5.
 

## Testing

Hopefully, your HTTP parsing is working at this point, so you will not need to test that. To test concurrent clients, here are a few thoughts. You can use a tool to help stress-test your server. There are no requirements that your server handles a certain amount of load, just that it handles clients concurrently, so some of these tools might be overkill. You can use the tools to prove to yourself that you are handling clients concurrently. Such tools include [wrk2](https://github.com/giltene/wrk2){:target="_blank"}, [Seige](https://www.joedog.org/siege-home/){:target="_blank"}, and [JMeter](https://jmeter.apache.org){:target="_blank"}.

Another way to test that your server is handling multiple clients is to add an artificial delay (e.g., `sleep`) to your program, just for testing purposes. This technique will simulate a request taking a long time and show if you are handling clients concurrently.

For debugging purposes, it might be useful to prefix all log messages with the socket that you are working on. The socket number should correspond to what thread is running. This can give you insight into what each thread is doing.


## Submission

To submit your code, push it to your Github repository. Tag the commit you want to be graded with a tag named `final`.


## Resources

- [`pthread_create`](https://linux.die.net/man/3/pthread_create){:target="_blank"}

- Threading [example 1]({% link assets/threads.c %}){:target="_blank"} and [example 2]({% link assets/locks.c %}){:target="_blank"} from class.
