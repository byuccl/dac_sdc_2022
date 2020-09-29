---
layout: lab
toc: true
title: TCP Client v2
number: 2
repo: https://github.com/byu-ecen493r-classroom/lab2.git
---

> Any fool can write code that a computer can understand. Good programmers write code that humans can understand.
> 
> Martin Fowler

## Overview
For this lab, you will be building off what you did in the previous lab. You will want to use your previous code as a starting point. We will be using the same protocol, but with a minor adjustment. The `Config` `struct` and `tcp_client.h` file have been modified to reflect these changes, so make sure to review these changes.

This lab adds [pipelining](https://en.wikipedia.org/wiki/Pipeline_(computing)){:target="_blank"} to our protocol. In this context, pipelining is sending multiple requests in one TCP connection. In the previous lab, if you wanted to send multiple requests, you had to start a TCP connect for each request. This can be quite time consuming because of [TCP's three-way handshake](https://en.wikipedia.org/wiki/Transmission_Control_Protocol#Connection_establishment){:target="_blank"}. Rather than starting a new TCP connection for each request, we can reuse the TCP socket and send multiple requests. To accommodate pipelining, both your command-line tool and our protocol will need to change. 

### Protocol

The request structure is in the same format as before, `ACTION LENGTH MESSAGE`. The list of actions is the same. However, the response from the server has changed. Instead of sending the transformed text, the server now sends back the length of the response*, followed by the response: `LENGTH TRANSFORMED_MESSAGE`. For example, if your client sent,

```
reverse 11 Hello World
```

The response from the server would be

```
11 dlroW olleH
```

There is no special characters between responses. You will need to figure out when the first message ends, and the next one begins. For example, if your client sent two pipelined commands,

```
reverse 11 Hello World
uppercase 11 Hello World
```

The response from the server would be

```
11 dlroW olleH11 HELLO WORLD
```


### Command-line Interface (CLI)

Instead of providing the action and text one at a time (e.g., `./tcp_client reverse "hello world"`), your program will now accept a file name as the only argument. This file will contain a list of actions and text, separated by newlines. For example, to run the client with `input.txt` as the input file,

```
./tcp_client input.txt
```

And the contents of `input.txt` could be,

```
title-case hello world
reverse this is a fun lab
uppercase networking is the best!
shuffle banana
```

Here is an [input file]({% link _labs/input.txt %}) to get you started. You will want to create your own to test out various aspects of your program. We will also be adding the ability to read from `stdin` if "-" is provided as the file name. This is a common paradigm for command-line tools and allows for easily pipelining of tools. For example, you could run the following:

```
cat input.txt | ./tcp_client -
```

You could imagine more interesting ways of chaining commands together. 

Here is a video of the program running:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/V_jFzM07lio" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


## Objectives

- Learn to read from a file and `stdin`.
- Get more experience with allocating memory and function pointers.
- Program with pipelining in a socket program.
- Understand how data is buffered when calling `send()` and `recv()`


## Requirements

- The name of your program must be named `tcp_client`.

- No modifications to `tcp_client.h` are allowed.

- The default port must be `8081`.

- Update `tcp_client` to accept *one* argument, a file name. If a "-" is provided, read from `stdin`. All the other options from the previous lab must stay the same.

```
Usage: tcp_client [--help] [-v] [-h HOST] [-p PORT] FILE

Arguments:
  FILE   A file name containing actions and messages to
         send to the server. If "-" is provided, stdin will
         be read.

Options:
  --help
  -v, --verbose
  --host HOSTNAME, -h HOSTNAME
  --port PORT, -p PORT
```

- To simplify your program, all actions and text provided to your program must be sent to the server before reading the response.

- If an action provided in a file is unknown, that line must be skipped. This includes blank lines.

- You must properly separate out the responses.

- Once your program has determined that all data has been received, *you* must close the socket.

- Your program must handle *any size* input.

## Testing

You can follow the same testing structure as lab 1. I will also be running a TCP server at `lundrigan.byu.edu:8081`. This server is only accessible on campus (for security purposes). If you are off-campus, you will need to VPN or use [SSH port forwarding](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding) to test against it.


## Resources

- [strchr](http://www.cplusplus.com/reference/cstring/strchr/){:target="_blank"}

- Memory management
    - [malloc](https://en.cppreference.com/w/c/memory/malloc){:target="_blank"}

    - [realloc](https://en.cppreference.com/w/c/memory/realloc){:target="_blank"}

    - [Please Grow Your Buffers Exponentially](https://blog.mozilla.org/nnethercote/2014/11/04/please-grow-your-buffers-exponentially/){:target="_blank"}

    - [This might be helpful too.](https://stackoverflow.com/questions/15409453/pointer-being-reallocd-was-not-allocated){:target="_blank"}

- [Function pointers](https://www.learn-c.org/en/Function_Pointers){:target="_blank"}

- File IO
    - [fopen](http://www.cplusplus.com/reference/cstdio/fopen/){:target="_blank"}

    - [fread](http://www.cplusplus.com/reference/cstdio/fread/){:target="_blank"}

    - [getline](https://linux.die.net/man/3/getline){:target="_blank"}


<p class="almost-hide" markdown="1">* <span>You might be asking yourself, if I sent the message, then I already know the length of the response, why does the server send it to me? Well, don't ask it. If you ask too many questions, then I am going to have to add more actions to the protocol that change the length of the content, which in turn will make the lab harder for you. Just keep quite and hope that no one notices. You're smart, you can understand why the content length would be important in a response outside of the context of this ~~contrived~~ simple protocol.</span></p>
