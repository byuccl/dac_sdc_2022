---
layout: page
toc: true
title: TCP Server
lab: 2
---

### Overview

The Internet runs off of TCP sockets. TCP offers a lot of great benefits, like in order data delivery, reliability, and congestion control. However, it is not without its idiosyncrasies. This lab give you your first taste of sending data across the Internet, and will help you understand the common pitfalls of using a TCP socket.

### Objectives

- Learn how to parse command line arguments
- Become familiar with the server socket API
- Understand how data is buffered when calling `send()` and `recv()`

### Requirements


- Must be named `tcp_server`
- Must accept two command line arguments for the size of the send and receive buffer (respectively).


### Pass Off

- To pass off, run the following script. I

### Resources

- This is a great guide on writing socket programs: https://beej.us/guide/bgnet/
