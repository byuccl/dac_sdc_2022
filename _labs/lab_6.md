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

For this lab, you will be extending your HTTP server to handle multiple clients _at once_. The rest of your server will stay the same. There are multiple ways of supporting multiple clients. A typical approach is to spawn a new thread or process for each client that connects. That thread or process is responsible for communicating with a specific client. Once the client disconnects, the thread or process is used for another client. 

However, for this lab, we will be exploring an alternative approach. Instead of creating a new thread or process, we will have one process that keeps track of many sockets at once. This technique is done through the system calls `poll` or `select`. For this lab, you will be using `poll`. 


It would be best if you didn't have to reinvent the wheel, so you will use the code provided in the Beej's Guide to Network Programming. The section describing the code can be found [here](https://beej.us/guide/bgnet/html/#poll), and the source code can be found [here](https://beej.us/guide/bgnet/examples/pollserver.c). I highly recommend you read the section before writing the code.


## Objectives

- Learn how to use `poll`.

- Get experience integrating other people's code into your own.


## Requirements

- You must be able to handle multiple concurrent clients at once using `poll`.

- The default port must be `8085`.

- All other requirements are the same as lab 5.
 

## Testing

Hopefully, your HTTP parsing is working at this point, so you will not need to test that. To test concurrent clients, here are a few thoughts. You can use a tool to help stress-test your server. There are no requirements that your server handles a certain amount of load, just that it handles clients concurrently, so some of these tools might be overkill. You can use the tools to prove to yourself that you are handling clients concurrently. Such tools include [wrk2](https://github.com/giltene/wrk2), [Seige](https://www.joedog.org/siege-home/), and [JMeter](https://jmeter.apache.org).

Another way to test that your server is handling multiple clients is to add an artificial delay (e.g., `sleep`) to your program, just for testing purposes. This technique will simulate a request taking a long time and show if you are handling clients concurrently.


## Resources

🤷‍♂️