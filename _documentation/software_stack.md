---
layout: page
toc: false
title: Software Stack
indent: 0
---

<img src = "{% link media/software_stack.png %}" width="1100">


## UIO Configuration 



| Device        | Device File           |
|---------------|-----------------------|
| leds_gpio     | `/dev/uio2`           |
| btns_gpio     | `/dev/uio3`           |
| switches_gpio | `/dev/uio4`           |
| rgbleds_gpio  | `/dev/uio5`           |
| user_intc     | `/dev/uio6`           |

## Header File 

The [system.h](https://github.com/byu-cpe/ecen427_student/blob/master/userspace/drivers/system.h) header file provides many useful *#define* statements for your convenience.