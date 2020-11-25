---
layout: lab
toc: true
title: Chat Client
number: 8
repo: https://github.com/byu-ecen493r-classroom/lab8.git
---

> Consistency underlies all principles of quality.
> 
> Frederick P. Brooks, Jr.

## GitHub Classroom

The GitHub Classroom link is posted as the topic of the Slack channel for the lab. You must use this link to accept the lab assignment. Once you have accepted the lab, the template repository you need to start the lab can be found [here](https://github.com/byu-ecen493r-classroom/lab8.git){:target="_blank"}.

## Overview

For this lab, you will be writing a chat client using [MQTT](https://mqtt.org){:target="_blank"}. Your chat client will need to be able to chat with other students through the MQTT broker. There are two parts to this lab, the "protocol" (how to format the payload) and the user interface.


### Protocol

Like the previous lab, you will be using MQTT as the main protocol. However, for this to work with other students, we need to standardize some way of formatting the MQTT message's payload and topic. There are two different topic sets: `<netid>/message` where all messages get published and `<netid>/status` where all status updates get published.

Your chat client will subscribe to two topics: `+/message` and `+/status`. These topics will allow you to receive all messages that are published from any NetID (including your own...). When you want to send a message, and assuming your NetId is "le0nh4rt", your client will publish to `le0nh4rt/message`, and when you want to update your status, you will publish to `le0nh4rt/status`.

The payload for the `<netid>/message` publications must contain [`json`](https://www.json.org/json-en.html){:target="_blank"} data with the following keys:

- `timestamp`: The time the message was published, formatted as the [epoch time (or Unix time)](https://en.wikipedia.org/wiki/Unix_time){:target="_blank"}.
- `name`: The name of the person sending the message. This is optionally provided as an argument to your interface. If no name is provided, you must use your NetID.
- `message`: The message you are sending.

For example, if you are publishing a message, "Hello world" at 8:13:00 AM on Nov 24, 2020, then the payload would be the following:

```json
{"timestamp": 1606230780, "name": "Dr. Phil", "message": "Hello world"}
```

The payload for the `<netid>/status` publications must contain `json` data with the following keys:

- `name`: The name of the person sending the message.
- `online`: An integer showing if the person is online or not. 0 for offline and any other value for online.

For example, to update your status to online the payload of the status update would be:

```json
{"name": "Dr. Phil", "online": 1}
```

You must publish an "online" message when you start your client and register a [last will](https://mntolia.com/mqtt-last-will-testament-explained-with-examples/){:target="_blank"} with the broker that publishes an "offline" message when you disconnect. To make the status messages more useful, you must set the retain flag for all status message publications.

To parse the JSON payload, we will be using a JSON parser called [frozen](https://github.com/cesanta/frozen){:target="_blank"}. It is provided in the `src` folder.

### User Interface

This interface will be different from any other lab. Rather than using a command-line interface, you will be building a graphical interface. You have a couple of options for how you want to approach this interface:

1. I have provided a simple [ncurses](https://en.wikipedia.org/wiki/Ncurses){:target="_blank"} interface for you to use in the lab. You have to plug in the MQTT code into the interface, and then you are done. This approach is the simplest way to complete the lab.

2. For extra credit, you can create your own, more advanced user interface. It can be based on my ncurses example, or you can create your own from scratch. You can use any programming language you would like for this lab. However, this does come with some risk since you will have to develop all of the interface code and MQTT code using a different library from the previous lab.

Regardless of which option you choose, you must provide the following usage pattern:

```
Usage: chat [--help] [-v] [-h HOST] [-p PORT] [-n NAME] NETID

Arguments:
 NETID The NetID of the user.

Options:
 --help
 -v, --verbose
 --host HOSTNAME, -h HOSTNAME
 --port PORT, -p PORT
 --name NAME, -n NAME
```

If no name is provided, then use NETID as the name.

## Objectives

- Build something that interfaces with other people's code.

- Get exposure to integrating with UI code or writing your own UI code.

- Learn how to parse JSON and format time strings.

- Have fun!


## Requirements

- The name of your program must be named `chat`. If you choose a non-complied language, you must provide a bash script called `chat` that runs your program. You can use [`$@`](https://stackoverflow.com/a/3816747){:target="_blank"} to pass all of the arguments from the bash script to your program.

- Your program must have the usage pattern provided above and parse all of the options and arguments correctly.

- The default port must be `1883`, and the default hostname must be `localhost`.

- Your client must be able to work with other chat clients.

- Your client must subscribe and publish using QoS of 1.

- Your client must publish an "online" status message when first connecting to the broker and register a last will to publish an "offline" status for when your client disconnects.

- Your status messages must set the retain flag to `true`.

- Your user interface must show the following information:
  - Messages that have been sent and received. It must include the time the message was sent, the name of the person that sent the message, and the message itself. The timestamp must be human-readable and not in epoch time format.
  - Show when people have left or joined the chat server. This can be inline with the chat messages.

- For extra credit, you can add the following or improve on the previous requirements:
  - +10 points: Make a more advanced GUI (using something other than ncurses), that has the same functionality as above.
  - +5 points: Mark that the message was delivered.
  - +5 points: Show who is online/offline. Instead of putting these messages inline with the chats, it should be off to the side with lists of names and an indication of who is offline/online. For example, you could have a list of names and green circles next to people that are online and red circles next to people who are offline.
  - +5 points: Automatically reconnect to the chat server if you get disconnected.
  - +5 points: Have some kind of status indicator showing if you are online or offline (assuming that your client can reconnect automatically).

## Testing

The chat server will be hosted at lundrigan.byu.edu:1883.

One good way of testing your chat client is to bring up multiple instances of your client. That way, you can see how it responds to people coming online and offline.

If you use ncurses, your log messages will not work because ncurses has taken over the screen. To get around this issue, you can write your log messages to a file. This can be set up using the following code:

```c
  log_file = fopen("log.txt", "w");
  log_add_fp(log_file, LOG_TRACE);
```


## Submission

To submit your code, push it to your Github repository. Tag the commit you want to be graded with a tag named `final`.


## Resources

- [Converting epoch time to human-readable time](https://www.epochconverter.com/programming/c){:target="_blank"}

- [Time string formatting](http://www.cplusplus.com/reference/ctime/strftime/){:target="_blank"}

- [Ncurses documentation](https://tldp.org/HOWTO/NCURSES-Programming-HOWTO/index.html){:target="_blank"}