---
layout: lab
toc: true
title: TCP Client v1
number: 1
repo: https://github.com/byu-ecen493r-classroom/lab1.git
---


> Programming isn't about what you know; it's about what you can figure out.
> 
> Chris Pine

## Overview

For this lab, you will be building a simple TCP client that sends data to a server to be transformed. The client will be a command-line tool that follows standard Unix norms. There are two parts to this lab:

- Interact with a TCP server using the protocol outlined below.
- Build a program that can parse command-line options and arguments.

The purpose of the protocol is to have a client send text to a server to transform. The server will convert the text by either uppercasing, lowercasing, title casing, reversing, or shuffling the text and send it back to the client.

### Protocol

The request structure is in the form of `ACTION LENGTH MESSAGE`. The values of `ACTION` can be "uppercase", "lowercase", "title-case", "reverse", or "shuffle". `LENGTH` is the length of the message. `MESSAGE` is the text that you want to send. For example, if you want "Hello World" to be reversed, you would send

```
reverse 11 Hello World
```

The response from the server would be

```
dlroW olleH
```

### Command-line Interface (CLI)

To use your protocol, you will be building a command-line tool that accepts different options and arguments. Here is a video of the program running:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/pdnJnOV6zqI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Your program must be able to accept a port and hostname as an option. For arguments, your program must be able to accept an action and a message.

To follow standard Unix norms, you must be careful what gets printed out to `stdout` and `stderr`. `stdout` is for the main output of your program and should be safe to pass to another program (using the pipe `|` operator). `stderr` is for all other output (errors and debugging).

To make this lab easier, you can assume the following:

- Once the server has sent the data, it will close the socket.

- Your application does not need to handle more than 1024 bytes of input.

For all labs, you have the option of using a simple logging library, [log.c](https://github.com/rxi/log.c){:target="_blank"}. I highly recommend you get familiar with it and use it. It does a lot of things for you and will save you time. If you do use it (and really you should), take care to provide the right log level output for messages (e.g., `log_debug`, `log_info`, `log_warn`). This will save you trouble when later when you are hunting down a bug. In my opinion, good logging messages is the key to good debugging.

## Objectives

- Learn how to parse command-line arguments using `getopt_long`.
- Become familiar with building a good command-line tool
- Use the socket API

## Requirements

- The name of your program must be named `tcp_client`.

- No modifications to `tcp_client.h` are allowed.

- Your program must have the following usage pattern and parse all of the options and arguments correctly.

```
Usage: tcp_client [--help] [-v] [-h HOST] [-p PORT] ACTION MESSAGE

Arguments:
  ACTION   Must be uppercase, lowercase, title-case,
           reverse, or shuffle.
  MESSAGE  Message to send to the server

Options:
  --help
  -v, --verbose
  --host HOSTNAME, -h HOSTNAME
  --port PORT, -p PORT
```

- If an incorrect argument or option is given, you must provide an error message, followed by the correct usage, as shown above.

- The default `HOST` must be "localhost", and the default `PORT` must be 8080.

- Your program is allowed only to print two things to `stdout`:
    - The usage message when `--help` option is provided. _The usage message displayed because of an incorrect option or argument should be printed to `stderr`_.
    - The text returned from the server.

- When the verbose flag is set, you must print debugging messages to `stderr`. These debugging messages must be *meaningful* and not garbage data. They should be helpful to anyone that is trying to debug your program.

- Your program must return a correct exit code, using `EXIT_SUCCESS` and `EXIT_FAILURE` (see [here](https://en.wikipedia.org/wiki/Exit_status#C_language){:target="_blank"}).

- Your program should be able to handle an arbitrary amount of input, up to 1024 bytes.


## Testing

There are a few ways to test your client. The first is using `netcat`. Netcat can create a temporary TCP server on `localhost` at port 8080 by running the following command:

```
nc -l 8080
```

You can have your client connect to the server and see what is being received. You can also type a message into `netcat` as a response to your client.

I will also be running a TCP server at `lundrigan.byu.edu:8080`. This server is only accessible on campus (for security purposes). If you are off-campus, you will need to VPN or use [SSH port forwarding](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding){:target="_blank"} to test against it. Here is a video demonstrating how to using port forwarding to test out lab 1:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/Kfmsi_WCd74" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


## Resources

- [getopt](https://man7.org/linux/man-pages/man3/getopt.3.html){:target="_blank"}

- [Options vs Arguments](https://stackoverflow.com/questions/36495669/difference-between-terms-option-argument-and-parameter){:target="_blank"}

- [Guide on socket programming](https://beej.us/guide/bgnet/html/){:target="_blank"}

- `stderr` and `stdout`
    - [Tutorial](http://www.learnlinux.org.za/courses/build/shell-scripting/ch01s04.html){:target="_blank"}
    - [`stderr` vs `stdout`](https://stackoverflow.com/questions/3385201/confused-about-stdin-stdout-and-stderr){:target="_blank"}
    - [Redirect `stderror`](https://askubuntu.com/questions/625224/how-to-redirect-stderr-to-a-file){:target="_blank"}

- [Wrapping `printf` into a function](https://stackoverflow.com/questions/20639632/how-to-wrap-printf-into-a-function-or-macro){:target="_blank"}

- [`netcat`](https://en.wikipedia.org/wiki/Netcat){:target="_blank"}

- [Exit Status](https://www.tldp.org/LDP/abs/html/exit-status.html){:target="_blank"}

