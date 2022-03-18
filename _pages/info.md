---
layout: page
toc: false
title: Participant Info
short_title: Info
sidebar: true
icon: fa fa-calendar
order: 2
---

## Registration

* [Registration](https://docs.google.com/forms/d/e/1FAIpQLSdR_B5BpST4Y49ZJmp2Dbjb4mZJ_PC3l9bpBY8yWXB4egV-jw/viewform?usp=sf_link) (The contest is open to both industry and academia.)


## Target Platform 

The 2022 contest will use the [Ultra 96 v2 development board](http://zedboard.org/product/ultra96-v2-development-board).
  
You should use the PYNQ 2.7 image, available at <http://www.pynq.io/board.html>. Direct download [link](https://bit.ly/u96v2_v2_7). 

### Legacy Ultra96v1 Support
In 2019, we used the Ultra96 v1 board. If you have this board, you may choose to continue to use it instead of purchasing a v2 board (or you may use both for your testing); however, you should be aware of the potential issues:
  * The WiFi module and the power regulators on the board have changed, which will likely result in different power usage measurements than an identical design running on the v2 board. 
  * The Ultra96v1 board typically shipped with a 2A power supply; however, if your design uses multiple software cores plus substantial amount of FPGA fabric, this may not be sufficient. A larger 4A power supply can be purchased from AVNET for $19.99.

## Links & Resources

### Contest Framework
The base design framework is provided here: <https://github.com/jgoeders/dac_sdc_2022>. This repository contains specifications for how your design should connect to our testing infrastructure.

### Training Dataset
Link to download training dataset: <https://byu.box.com/s/hdgztcu12j7fij397jmd68h4og6ln1jw>

### Frequently Asked Questions
  * [FAQs]({% link _pages/faq.md %})

### Previous Contest Winning Designs
  * 2021: <https://github.com/jgoeders/dac_sdc_2021_designs>
  * 2020: <https://github.com/jgoeders/dac_sdc_2020_designs>
  * 2019: <https://github.com/xyzxinyizhang/2019-DAC-System-Design-Contest>
  * 2018: <https://github.com/xyzxinyizhang/2018-DAC-System-Design-Contest>


## Q&A Platform
We will be using Piazza as a Q&A platform for the contest. Sign up using this link: <piazza.com/dac_2018/summer2022/dacsdc2022>.
