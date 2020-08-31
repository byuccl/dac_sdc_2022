---
layout: lab
toc: true
title: HTTP Server
number: 5
repo: https://github.com/byu-ecen493r-classroom/lab5.git
---

> Computer Science is no more about computers than astronomy is about telescopes.
> 
> Edsger W. Dijkstra

## Overview

Now that you have written TCP client and a TCP server, it is time to graduate to a real protocol: HTTP! As you know, HTTP is just a text-based protocol that runs on top of TCP sockets. The previous lab built the groundwork for your HTTP server. Now instead of parsing my made-up protocol, you will be parsing HTTP. Your HTTP server will support `GET` requests. When your server receives a `GET` request, it will determine the file that is being requested, and return it. By the end of this lab, your server should be able to host a full website on it.

There are two parts to this project, the HTTP parsing and CLI.

### HTTP Parsing
Assuming you did the previous lab correctly, you will just need to modify the logic that parses a request and builds a response—all of the TCP related logic can stay the same. The HTTP request and response format are pure ASCII so a lot of the work and tooling you have built around parsing the other protocol still apply.

For your server, you can assume that all requests and responses will be in `HTTP/1.1`.

### Command-line Interface (CLI)

Only one modification needs to be made to the CLI of your server from the previous lab. You need to add an option that allows you to pass in the folder that your server will look for files. What I mean by this is when someone requests `http://localhost:8080/test.jpg`, where should your server look for `test.jpg`? It could look relative to the root directory, but that is a big security problem because then the person requesting has access to your whole hard drive. Instead, an option will be provided that makes all requests relative to that folder. For example you could run the server,

```
bin/http_server -f ./www
```

Then all requests would be relative to the `www` folder. The previous request would try to access a file at `www/test.jpg`.



## Objectives

- Get experience with the HTTP protocol.

- Get more experience with file IO.


## Requirements

- No modifications to `http_server.h` are allowed.

- The name of your program must be named `http_server`.

- `http_server` accepts no arguments, and four options:

```
Usage: http_server [--help] [-v] [-p PORT] [-f FOLDER]

Options:
  -h, --help
  -v, --verbose
  --port PORT, -p PORT
  --folder FOLDER, -f FOLDER
```

- The default port must be `8080`.

- The default folder must be `.`.

- Your server must be able to *parse* all request types (`POST`, `PUT`, etc.), however, you only need to service `GET` requests. If a request type other than `GET` is received, you must return a `405 Method Not Allowed` error. 

- You are only required to respond with one header, `Content-Length`, which contains the size of the response file. You are welcome to support other response headers, such as `Content-Type`, `Last-Modified`, etc.

- Your server must be able to server a webpage to Chrome.

- If a request for a file does not exit, a proper error message must be returned (`404 File Not Found`).

- If any other error occurs, the [appropriate error code/message](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html){:target="_blank"} must be returned.


## Testing

You can follow the same tools as the previous lab. You can also add [httpie](https://httpie.org){:target="_blank"} or [curl](https://curl.haxx.se){:target="_blank"} to your repertoire. They will create a valid HTTP request for you to test your server against. Once you have refined your lab, you can use a web browser to make sure your response is well formed and the data you are returning is correct.


## Resources

- [`strtok`](https://linux.die.net/man/3/strtok){:target="_blank"}

- HTTP
  - [HTTP Specification](https://tools.ietf.org/html/rfc7230){:target="_blank"}
  - [Wikipedia](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Message_format){:target="_blank"}

- [File IO](https://man7.org/linux/man-pages/man3/fopen.3.html){:target="_blank"}

- [Max size of file name and path](https://serverfault.com/a/306726){:target="_blank"}

