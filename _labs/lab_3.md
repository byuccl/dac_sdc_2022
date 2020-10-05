---
layout: lab
toc: true
title: TCP Client v3
number: 3
repo: https://github.com/byu-ecen493r-classroom/lab3.git
---

> If debugging is the process of removing software bugs, then programming must be the process of putting them in. 
> 
> Edsger Dijkstra

## Overview

For this lab, you will be building off what you did in the previous two labs. You will want to use your previous code as a starting point. The major difference is that we will be creating a [binary protocol](https://en.wikipedia.org/wiki/Binary_protocol){:target="_blank"}. What this means is that instead of using ASCII, we will be using binary. I know what you are thinking: ASCII is binary! And you are right! In fact, this protocol will still have ASCII characters to represent the text of the message. However, for the action and message length fields, we will be using binary.

### Protocol

The request protocol will be formatted as follows:

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Action |                    Message Length                   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                             Data                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Action: 5 bits
Message Length: 27 bits
Data: variable
```

We are very concerned about wasted space, so we will be packing these bits in tight!

The mapping from text action to binary action is as follows:

| Action       | Binary Value |
|--------------|--------------|
| `uppercase`  | 0x01         |
| `lowercase`  | 0x02         |
| `title-case` | 0x04         |
| `reverse`    | 0x08         |
| `shuffle`    | 0x10         |

All other values are reserved and should not be used ☠️.

The response will be formatted as:

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Message Length                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                             Data                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Message Length: 32 bits
Data: variable
```

When dealing with binary formats, you have to be careful what kind of [endianness](https://en.wikipedia.org/wiki/Endianness){:target="_blank"} you use. You don't know what architecture the server is running, so you can't assume it is the same as yours. The server also can't assume anything. To deal with this, all networking protocols are formatted in big-endianness (called network order).

For example, if you wanted to reverse the string "The LAN Before Time", then you would send the following binary data (displayed in hex format):

```
40 00 00 13 54 68 65 20 4C 41 4E 20 42 65 66 6F 72 65 20 54 69 6D 65
```

If you were to print this to your console, you would see:
```
@\0\0�The LAN Before Tiem
```

Where `\0` is the NULL terminator and � is `DC3`, which is an unrepresentable ASCII character.


### Command-line Interface (CLI)

Your program will take the same input file as the previous lab. So from the command-line interface perspective, you do not have to modify anything. This lab only touches the protocol part.

### Technical Debt

At this point in the labs, you might have incurred some [technical debt](https://en.wikipedia.org/wiki/Technical_debt){:target="_blank"}. Since this lab is on the lighter side, this is your chance to pay it back. Take some time to understand how all of the different parts come together. Having a clear understanding of this will be helpful in future labs. Take time to make sure your code is clean and understandable. Run [Valgrind](https://www.valgrind.org){:target="_blank"}.


## Objectives

- Understand the difference between a binary protocol and a text-based protocol.

- Implement a binary protocol.

- Get more practice with bit bashing.


## Requirements

- The name of your program must be named `tcp_client`.

- No modifications to `tcp_client.h` are allowed.

- The default port must be `8082`.

- Everything about the command-line interface must stay the same as lab 2.

- You must build off the previous lab (meaning you have to keep the pipelining).

- Your program must handle *any size* input, up to the allowable limit of the protocol.

- Use the binary version of the protocol.

- Ensure that Valgrind reports no errors.


## Testing

You can follow the same testing structure as lab 1 and 2. I will also be running a TCP server at `lundrigan.byu.edu:8082`. This server is only accessible on campus (for security purposes). If you are off-campus, you will need to VPN or use [SSH port forwarding](https://help.ubuntu.com/community/SSH/OpenSSH/PortForwarding) to test against it.


## Resources

- [`htonl`, `htons`, `ntohl`, `ntohs`](https://linux.die.net/man/3/htonl){:target="_blank"}

- [The Valgrind Quick Start Guide](https://www.valgrind.org/docs/manual/quick-start.html#quick-start.mcrun){:target="_blank"}

- [Copying integer value to character buffer and vice versa in C](https://www.includehelp.com/c/copying-of-integer-value-to-character-buffer-and-vice-versa-in-c.aspx){:target="_blank"}

