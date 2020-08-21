---
layout: page
toc: true
title: TCP Client v3
number: 3
---

> If debugging is the process of removing software bugs, then programming must be the process of putting them in. 
> 
> Edsger Dijkstra

## Overview

For this lab, you will be building off what you did in the previous two lab. You will want to use your previous code as a starting point. The major difference is that we will be creating a [binary protocol](https://en.wikipedia.org/wiki/Binary_protocol). What this means is that instead of using ASCII, we will be using binary. I know what you are thinking: ASCII is binary! And you are right! In fact, this protocol will still have ASCII characters to represent the text of the message. However, for the action and message length fields, we will be using binary.

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

We are very concerned about wasted space, so we are going to be packing these bits in tight!

The mapping from text action to binary acction is as follows:

| Action       | Binary Value |
| ------------ | ------------ |
| `uppercase`  | 0x01         |
| `lowercase`  | 0x02         |
| `title-case` | 0x04         |
| `reverse`    | 0x08         |
| `shuffle`    | 0x10         |

All other values are reserved and should not be used ☠️.

The response will be formated as:

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

When dealing with binary formats, you have to be careful what kind of [endianness](https://en.wikipedia.org/wiki/Endianness) you use. You don't know what architecture the server is running so you can't assume it is the same as yours. The server also can't assume anything. To deal with this, all networking protocols are formatted in big-endianness (called network order).


### Command-line Interface (CLI)

You're program will take the same input file as the previous lab. So from the command-line interface perspective, you do not have to modify anything. This lab only touches the protocol part.

### Technical Debt

At this point of the CLI and protocol, you might have incurred some [technical debt](https://en.wikipedia.org/wiki/Technical_debt). Since this lab is on the lighter side, this is your chance to pay it back. Take some time to understand how all of the different parts come together. Having a clear understanding of this will be helpful in future labs. Take time to make sure your code is clean and understandable. Run [Valgrind](https://www.valgrind.org).


## Objectives

- Understand the difference between a binary protocol and a text-based protocol.

- Implement a binary protocol.

- Get more practice with bit bashing.


## Requirements

- The name of your program must be named `tcp_client`.

- No modifications to `tcp_client.h` are allowed.

- Everything about the command-line interface must stay the same.

- You must build off of the previous lab (meaning that you have to keep the pipelining).

- Your program must handle *any size* input, up to the allowable limit of the protocol.

- Use the binary version of the protocol.

- Ensure no errors are reported by Valgrind.

## Resources

- [`htonl`, `htons`, `ntohl`, `ntohs`](https://linux.die.net/man/3/htonl)

- [The Valgrind Quick Start Guide](https://www.valgrind.org/docs/manual/quick-start.html#quick-start.mcrun)

- [Copying integer value to character buffer and vice versa in C](https://www.includehelp.com/c/copying-of-integer-value-to-character-buffer-and-vice-versa-in-c.aspx)
