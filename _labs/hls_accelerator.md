---
layout: lab
toc: true
title: "Lab 7: Creating a Hardware Accelerator with HLS"
short_title: HLS Accelerator
number: 7
---

## Overview
In this final lab, you will create another piece of custom digital hardware, which will be capable of modifying the graphics on the screen in an accelerated manner.  Rathen than relying on the processor to draw each pixel of the graphics, you will be able to issue a command to your hardware accelerator to do this for you.

Your harwdare accelerator will need the ability to change memory values in the pixel buffer.  This means that it will act as a *master* on the system bus, with the ability to initiate read and write operations.  This is also means that this hardware will be much more complex than your PIT device, which was a *slave* device, and could only wait and repond to requests initiated by a master device (the processor).

Fortunately, we are going to make use of a modern digital design technology, *High-Level Synthesis (HLS)*, which will automatically create our Verilog digital circuit from a far simpler C-code description.

<p style="text-align:center;">
<img src="{% link media/labs/hls_bus.png %}" class="center"></p>

## Describing Functionality in C Code

The functionality of your hardware accelerator is described by the `copy_bitmap_region` function, defined in *bitmap_accelerator.h*:

```
// Draw a rectangular region of pixels at (dest_x, dest_y), of size (width, height).
// Two modes are supported:
//    1. If fill_from_const is True, then the region is filled with a single
//        color, where RGB = (const_R, const_G, const_B)
//    2. If fill_from_const is False, then the pixels are copied from another
//        location in the frame buffer, at (src_x, src_y).  This allows you to 
//        quickly draw the same sprite several times.
void copy_bitmap_region(uint8_t *frame_buffer, uint16_t src_x, uint16_t src_y,
                        uint16_t dest_x, uint16_t dest_y, uint16_t width,
                        uint16_t height, bool fill_from_const, uint8_t const_R,
                        uint8_t const_G, uint8_t const_B);
```

Create a *bitmap_accelerator.c* file where you implement this function.  Some test code is provided to you in *bitmap_accelerator_test.c* to ensure that you implement it correctly.  This will be used in the next step.

## Vitis HLS



