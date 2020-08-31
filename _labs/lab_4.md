---
layout: lab
toc: true
title: TCP Server
number: 4
repo: https://github.com/byu-ecen493r-classroom/lab4.git
---

> First, solve the problem. Then, write the code.
>
> John Johnson

## Overview

In this lab, you will be building a TCP server that implements your favorite protocol (the same one as the last three labs). The individual parts of the lab are outlined below. Many of the components that you have developed and refined in the previous labs can be reused in this lab, with some modifications.

### Protocol

This lab will be using the same version of the protocol you developed in TCP Client **v1** (all ASCII and no pipelining). This will make it easier to test your server. This also means that your server is in charge of closing the connection. 

The request protocol will be formatted as follows:

```
ACTION LENGTH MESSAGE
```

Once your server has received a request, it will parse it, transform the message, and send back a response. In processing a request, if an unexpected action is encountered or a request is malformed, then the message "error" should be returned.

To simplify this lab, a few adjustments will be made:

- You only need to support one client at a time.

- Typically for a server, you provide the IP address you would like the server to bind to (e.g., `127.0.0.1`, `192.0.2.33`), or `0.0.0.0` to bind to all interfaces. For this lab, you can bind to all interfaces (`AI_PASSIVE` or `INADDR_ANY`, depending on what system call you use).


### Command-line Interface (CLI)

The CLI will have no arguments and three options: port, verbose flag, and help flag. The port option changes the port that your server binds to. Your program will print nothing to `stdout` and can print log messages to `stderr`, if the verbose flag is set.

Your server will be designed to block forever. Once it has handled one client, it will wait for another client to connect. As a result, you must be able to properly handle an [interrupt signal (`SIGINT`)](https://en.wikipedia.org/wiki/Signal_(IPC)){:target="_blank"}. A process is usually sent this signal by typing `ctrl-c` in a terminal window. Your server must catch this signal and properly shutdown the server.


## Objectives

- Learn to build a server.

- Get experience with handling signals.


## Requirements

- No modifications to `tcp_server.h` are allowed.

- The name of your program must be named `tcp_server`.

- `tcp_server` accepts no arguments, and three options, as outlined above.

```
Usage: tcp_server [--help] [-v] [-p PORT]

Options:
  -h, --help
  -v, --verbose
  --port PORT, -p PORT
```



- The default port must be `8080`.

- You must set the [`SO_REUSEADDR`](https://man7.org/linux/man-pages/man7/socket.7.html){:target="_blank"} option on the server socket.

- Your server must handle any request size.

- Your server does not need to support IPv4 or concurrent clients.

- Return "error" if an error occurs when processing request.

- Properly shutdown server when an interrupt signal (`ctrl-c`) is sent to server.


## Testing

[Netcat](http://netcat.sourceforge.net) is going to be your best friend for this lab. This will allow you to connect directly to your server and test out different input. You can also use the client that you created in lab 1.

## Resources

- [Guide on socket programming](https://beej.us/guide/bgnet/html/){:target="_blank"}

- [toupper](http://www.cplusplus.com/reference/cctype/toupper/){:target="_blank"}

- [strcpy](https://www.programiz.com/c-programming/library-function/string.h/strcpy){:target="_blank"}

- [rand](http://www.cplusplus.com/reference/cstdlib/rand/){:target="_blank"}

- [Fisher–Yates shuffle](https://en.wikipedia.org/wiki/Fisher–Yates_shuffle){:target="_blank"}

- [Catch Ctrl-C in C](https://stackoverflow.com/questions/4217037/catch-ctrl-c-in-c){:target="_blank"}