---
layout: lab
toc: true
title: MQTT Client
number: 7
repo: https://github.com/byu-ecen493r-classroom/lab7.git
---

> Programs must be written for people to read, and only incidentally for machines to execute.
> 
> Harold Abelson

## GitHub Classroom

The GitHub Classroom link is posted as the topic of the Slack channel for the lab. You must use this link to accept the lab assignment. Once you have accepted the lab, the template repository you need to start the lab can be found [here](https://github.com/byu-ecen493r-classroom/lab6.git){:target="_blank"}.

## Overview

For this lab, you will be writing an [MQTT](https://mqtt.org){:target="_blank"} client. MQTT is a different type of application layer protocol from what you have seen in the past. It will be worth your time to understand how it works before you dive into implementing a client. We will discuss it in lecture, but it is worth reading some [articles](https://www.hivemq.com/blog/how-to-get-started-with-mqtt/){:target="_blank"} and/or watching some [videos](https://youtu.be/LKz1jYngpcU){:target="_blank"}. It is a fairly complex protocol when you get into the details of how it works.

To use MQTT, you need a couple of pieces of information:

- **Hostname**. This is the hostname of the broker. (In MQTT, they call the server a broker.)
- **Port number**. This is the port number that the broker is bound to. For MQTT, the standard ports are 1883 and 8883.
- **Client ID**. A string to uniquely represent the client that has connected to the broker.
- **Topic**. The topic that you are subscribing to or publishing to. Topics are just strings but are typically hierarchical. Different namespaces are separated by slashes `/`. For example, in home automation, if you want to communicate with a light, the topic might be `home/upstairs/bedroom/light`. A topic is needed to publish or subscribe to.
- **Message**. The message you want to publish (if applicable).
- **Username and password** *(optional)*. Brokers can require that clients provide a username and password. Without a username and password, clients are anonymous. The username can be the same as the client ID.

We will not be using a username and password for this lab.

### Protocol

You will be using the [Paho MQTT C Client Library](https://www.eclipse.org/paho/index.php?page=clients/c/index.php){:target="_blank"}. This library comes in two flavors, classic (blocking) and async (non-blocking). For this lab, you must use the async version. 

To use this library, you need to install it on your computer. To do so, follow these [instructions](https://github.com/eclipse/paho.mqtt.c#build-instructions-for-gnu-make). As the instructions say, you need to have the OpenSSL development package installed. You can install it by running,

```
apt-get install libssl-dev
```

The library is installed on the Embedded Lab computers, but _not_ on the CAEDM computers.

We will be going back to our old-faithful protocol. It will work the following way: A client will publish a message with a topic set to `<netid>/<action>`. The payload of the message will be the text you want to transform. For example, if you want to uppercase the text, "Networking is the best!" and your NetID is [le0nh4rt](https://en.wikipedia.org/wiki/Squall_Leonhart), then you would publish to the topic `le0nh4rt/uppercase` and the message would be "Networking is the best!". Your client must subscribe to `le0nh4rt/response` to get the response, which in this example would be "NETWORKING IS THE BEST!".

**Note**: We are trying to fit a request/response protocol into a publisher/subscriber model. Though it happens all the time, it is not ideal and slightly unintuitive. We are doing this to combine something you are familiar with something new. In the next lab, you will see the full power and beauty of a publisher/subscriber protocol.

### CLI

The only arguments for this lab are NetID, action, message. The NetID will be used for the topic that you publish and subscribe to. The action and message will be the same as the previous labs. Similar to earlier labs, your client must take a hostname and port number. The default port number should be 1883, and the default host should be `localhost`. The provided NetID will also be used for the client ID. You must use the following usage pattern:

```
Usage: mqtt_client [--help] [-v] [-h HOST] [-p PORT] NETID ACTION MESSAGE

Arguments:
 NETID The NetID of the user.
 ACTION Must be uppercase, lowercase, title-case,
 reverse, or shuffle.
 MESSAGE Message to send to the server

Options:
 --help
 -v, --verbose
 --host HOSTNAME, -h HOSTNAME
 --port PORT, -p PORT
```

Here is a demonstration of the client:

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/vcE0FdQGQB8" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Objectives

- Learn MQTT and how to use it.

- Get experience with integrating a 3rd party library.

- Get experience with asynchronous code.

## Requirements

- No .h file is provided in this lab. Feel free to structure the code however you would like. Good luck! 

- The name of your program must be named `mqtt_client`.

- Your program must have the following usage pattern (provided above) and parse all of the options and arguments correctly.

- The default port must be `1883`, and the default hostname must be `localhost`.

- Your application must print the response to `stdout`. All other class norms must be followed (e.g., print errors to `stderr`, correct return codes, etc.).

- Your client must subscribe and publish using QoS of 1.


## Testing

I have provided an MQTT broker at lundrigan.byu.edu:1883. You can use it to test your client. 

You can also install [`mosquitto`](https://mosquitto.org), a popular open-source MQTT broker. Using mosquitto, you can test locally on your machine. You might consider installing `mosquitto-clients`, which gives you [`mosquitto_pub`](https://mosquitto.org/man/mosquitto_pub-1.html) and [`mosuquitto_sub`](https://mosquitto.org/man/mosquitto_sub-1.html), which are clients to publish and subscribe with.


## Submission

To submit your code, push it to your Github repository. Tag the commit you want to be graded with a tag named `final`.


## Resources

- [Paho MQTT C Client Documentation](https://www.eclipse.org/paho/files/mqttdoc/MQTTClient/html/index.html){:target="_blank"}

- [MQTTClient.h Documentation](https://www.eclipse.org/paho/files/mqttdoc/MQTTClient/html/_m_q_t_t_client_8h.html#a203b545c999beb6b825ec99b6aea79ab){:target="_blank"}

- [Asynchronous publication example](https://www.eclipse.org/paho/files/mqttdoc/MQTTClient/html/pubasync.html){:target="_blank"}

- [Asynchronous subscription example](https://www.eclipse.org/paho/files/mqttdoc/MQTTClient/html/subasync.html){:target="_blank"}

