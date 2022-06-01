---
layout: page
toc: false
title: Results
sidebar: true
icon: fas fa-medal
order: 6
---

# March Submission Results

|Rank|Team Name|FPS|IoU|FPS Penalty|IoU Penalty|Energy(J)|Energy Score|Total Score|
|-----|-----|-----|-----|-----|-----|-----|-----|-----|
|1|Monday|363.000|0.708|1.00|1.00|378.0|8.562|11.679|
|2|ultrateam|287.090|0.708|1.00|1.00|458.8|8.842|11.310|
|3|ShinyRosy|7.340|0.714|0.24|1.00|26,144.5|14.674|1.667|
|4|sephjiang|7.340|0.714|0.24|1.00|26,764.1|14.708|1.663|
|5|TouchFish|5.690|0.714|0.19|1.00|25,104.4|14.616|1.298|
|6|CCAI_ZJU|5.690|0.711|0.19|1.00|28,521.3|14.800|1.282|
|7|TmpSEU|370.570|0.478|1.00|0.10|349.8|8.450|1.183|
|8|Vienna EML|12.790|0.366|0.43|0.10|13,105.6|13.678|0.312|

LU_CORPS: Kernel crashes after a long while (about 40-50k images). Tried 3 times.


# May Submission Results

|Rank|Team Name|FPS|IoU|FPS Penalty|IoU Penalty|Energy(J)|Energy Score|Total Score|
|-----|-----|-----|-----|-----|-----|-----|-----|-----|
|1|Monday|379.840|0.703|1.00|1.00|291.8|8.189|12.212|
|2|TmpSEU|358.610|0.478|1.00|0.10|350.6|8.454|1.183|
|3|ultrateam|360.140|0.478|1.00|0.10|401.8|8.650|1.156|
|4|InvolutionNet|241.050|0.332|1.00|0.10|689.6|9.430|1.060|
|5|SoutheastASIC|226.020|0.454|1.00|0.10|698.4|9.448|1.058|

**Notes:**
- **InvolutionNet**: Your team has some power measurement code that contained a bug, please make sure to remove first next time.
- **BIT_gd**: Error "TypeError: __init__() got an unexpected keyword argument 'batch_size', OSError: libopencv_imgcodecs.so.3.2: cannot open shared object file: No such file or directory"
- **mit_hanlab**: ModuleNotFoundError: No module named 'pynq_dpu'. We've installed the DPU using `pip3 install pynq-dpu` and it's still not working. Please advise.
- **super-capacitor**: OSError: libopencv_imgcodecs.so.3.4: cannot open shared object file: No such file or directory. (We installed libopencv-imgcodecs4.2 but looks like your code relies on version 3.4
- **UT-IS21**: Notebook crashes during 1st batch.

