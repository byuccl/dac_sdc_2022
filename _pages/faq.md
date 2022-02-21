---
layout: page
toc: false
title: Frequently Asked Questions
short_title: FAQ
sidebar: true
icon: fas fa-question
order: 3
---

### Q: Can I use a custom kernel image?
A: No. The evaluation platform will use the PYNQ v2.7 image for the Ultra96 v2, available at <http://www.pynq.io/board.html>. When you submit your files (jupyter notebook, bitstream, supporting files), we will copy them to the evaluation platform. Your solution must run on this platform, and cannot rely upon changes to the underlying system image.

However, if you need certain system packages via `apt`, you can make a note at the top of your notebook and we will install these packages.


### Q. Can you check if my design works on your platform?
A: We will accept preliminary submission multiple times.  See the [schedule]({% link _pages/schedule.md %}). If you submit at those times, we will provide you with preliminary results. Make sure to try your design during these preliminary submission times. If you submit your design for the final submission, and it doesn't work, we won't have time to contact you and get any fixes.

### Q. Do I need to use the PYNQ image?
A: Yes, the evaluation system will run your design using your jupyter notebook page that you submit. You need the PYNQ framework so that the evaluators can run your notebook. You are still able to add any IP/hardware modules you like to the base hardware system provided to you.

### Q. Can I use Xilinx's DPU / Vitis AI tools?
A: Yes. 