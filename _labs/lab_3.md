---
layout: page
toc: true
title: HTTP Server
lab: 3
---

### Overview

Now that you have your TCP client and server written, you are not that far away from having an HTTP client and server! HTTP is just a text-based protocol that runs on top of TCP sockets. To convert your TCP client/server to an HTTP client/server, you must implement an HTTP parser. Easy, right?

### Objectives


### Requirements

- Provide a command-line option to change the port your server is listening on.

- Provide a command-line option to change the amount of bytes the receiver can receive. Your program should work with any receive size greater than zero. By receive size, I mean the variable `len` in `recv(sock, buf, len, 0)`.

- Multiple requests must be handled at once (see the Testing section for how to test this).

- Using a web browser, going to [`http://localhost:8080/page.html`](http://localhost:8080/page.html) and the webpage should load (assuming you set your server to listen on port 8080).

- If you request a file and it does not exist (e.g. [`http://localhost:8080/fdfasd.html`](http://localhost:8080/fdfasd.html)), a proper error message is returned (`HTTP/1.1 404 File Not Found`)

- The program must be written in C or Rust (only using std::net or async_std::net)

- Must be able to handle a call to recv with no full request, one and a half requests, and multiple requests

- Must be able to handle any *send and receive* buffer size

- Need to be able to handle any file (no hard coding file names)


### Pass Off


### Resources

