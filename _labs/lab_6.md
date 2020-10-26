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

For this lab, you will be extending your HTTP server to handle multiple clients _at once_. The rest of your server will stay the same. There are multiple ways of supporting multiple clients. A typical approach is to spawn a new thread or process for each client that connects. That thread or process is responsible for communicating with a specific client. There is another approach that uses a system call (`poll` or `select`) to determine which sockets are ready to receive data from or write data too. Since with socket programming, most of the time your program is waiting around for the sockets to send or receive data, this allows your program to handle multiple sockets at once. Instead of creating a new thread or process, we will have one process that keeps track of many sockets at once.

The simplest approach is to use threads and that is the approach we will be using in this lab. When a new request comes in, a thread is created and the socket is passed to that thread. The newly spawned thread is now responsible for receiving and sending data while the main thread is still accepting new clients. As mentioned in lecture, threads has their own set of issues, largely shared memory. To limit these issues, try to use local variables as much as possible. You should not need to use mutex/locks in this lab!

## Objectives

- Learn how to use `pthread`.

- Learn how to make an HTTP server concurrent.


## Requirements

- You must be able to handle multiple concurrent clients at once using threads.

- The default port must be `8085`.

- All other requirements are the same as lab 5.
 

## Testing

Hopefully, your HTTP parsing is working at this point, so you will not need to test that. To test concurrent clients, here are a few thoughts. You can use a tool to help stress-test your server. There are no requirements that your server handles a certain amount of load, just that it handles clients concurrently, so some of these tools might be overkill. You can use the tools to prove to yourself that you are handling clients concurrently. Such tools include [wrk2](https://github.com/giltene/wrk2){:target="_blank"}, [Seige](https://www.joedog.org/siege-home/){:target="_blank"}, and [JMeter](https://jmeter.apache.org){:target="_blank"}.

Another way to test that your server is handling multiple clients is to add an artificial delay (e.g., `sleep`) to your program, just for testing purposes. This technique will simulate a request taking a long time and show if you are handling clients concurrently.


## Resources

- [`pthread_create`](https://linux.die.net/man/3/pthread_create){:target="_blank"}

- Threading [example 1](assets/threads.c){:target="_blank"} and [example 2](assets/locks.c){:target="_blank"} from class.