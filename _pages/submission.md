---
layout: page
toc: false
title: Submission Instructions
short_title: Submission
sidebar: true
icon: fas fa-upload
order: 5
---

## Preliminary Submissions
You can optionally submit your design for the preliminary submissions (see [schedule]({% link _pages/schedule.md %})). This allows you to check that your solutions is working on our evaluation platform. 

### Requirements:

1. Submit the following files:
  * Your Jupyter notebook (*.ipynb)
  * Hardware files (*.bit and *.hwh)
  * Any other files we need to run your design (ie a weights file)
  * DO NOT submit the *dac_sdc.py* file.  

1. Your notebook should be structured as explained in the example notebook provided (dac_sdc.ipynb).
  * Leave the `sys.path.append(os.path.abspath("../common"))` statement in the notebook so that the official dac_sdc.py file can be located.
1. Your notebook must run without error using the *Run All Cells* command in Jupyter.
1. Do not hardcode any file paths. 
1. If you are using the v1 board, be sure to fix the power rail names before submission. 
1. Place all of your files in a single zip archive and submit it.

## Final Submission
For the final submission, follow the instructions above. In addition:

1. Submit all source files for your design, in a zip archive.
1. Your design must be available, open-source, and in working condition in order to be considered for an award. You are permitted to use publicly available closed source tools and IP (Xilinx's DPU); however, all of your work (any modifications and configurations to commercial, closed-source tools), must be accessible.

## Submission Links

* Preliminary Submission 1 (closed): <https://forms.gle/TsHpkMgRSU5MFMN27>
* Preliminary Submission 2 (by May 8th): <https://forms.gle/y8uWDDditrSHQRGJ9>
