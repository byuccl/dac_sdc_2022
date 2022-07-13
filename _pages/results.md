---
layout: page
toc: false
title: Results
sidebar: true
icon: fas fa-medal
order: 6
---
## Final Results

|Rank|Team Name|FPS|IoU|FPS Penalty|IoU Penalty|Energy(J)|Energy Score|Total Score|
|-----|----|----:|----:|----:|----:|----:|----:|----:|
|1|SEUer|2,020.6|0.703|1.00|1.00|36.7|5.198|19.239|
|2|ultrateam|2,266.2|0.703|1.00|1.00|40.3|5.333|18.752|
|3|InvolutionNet|712.8|0.708|1.00|1.00|144.6|7.176|13.935|
|4|UBPercept|593.5|0.704|1.00|1.00|202.1|7.659|13.057|
|5|404NotFound|492.6|0.699|1.00|1.00|259.3|8.018|12.409|
|6|super-capacitor|386.2|0.708|1.00|1.00|289.6|8.178|12.228|
|7|Monday*|379.8|0.703|1.00|1.00|291.8|8.189|12.212|
|8|BoatingWithoutPaddle|293.7|0.699|1.00|1.00|309.0|8.271|12.029|
|9|TmpSEU*|363.9|0.702|1.00|1.00|354.1|8.468|11.809|
|10|SoutheastASIC|401.5|0.703|1.00|1.00|355.6|8.474|11.801|
|11|GoLukeGo|298.7|0.700|1.00|1.00|400.4|8.645|11.567|
|12|seuplayers|404.8|0.688|1.00|0.94|327.8|8.357|11.248|
|13|TouchFish|349.0|0.709|1.00|1.00|612.6|9.259|10.801|
|14|txh|351.2|0.709|1.00|1.00|629.6|9.298|10.755|
|15|CCAI_ZJU|250.9|0.695|1.00|0.98|586.7|9.196|10.602|
|16|whatever*|154.0|0.680|1.00|0.90|883.5|9.787|9.196|
|17|BIT_gd|56.0|0.725|1.00|1.00|3,143.7|11.618|8.607|
|18|gd_BIT|54.5|0.725|1.00|1.00|3,566.6|11.800|8.474|
|19|Vienna EML|528.5|0.620|1.00|0.60|312.7|8.289|7.239|
|20|YoLook|507.9|0.593|1.00|0.47|260.8|8.027|5.793|
|21|LU_CORPS|283.5|0.596|1.00|0.48|540.7|9.079|5.287|
|22|dpu_b2304_yolox_pybind|136.2|0.597|1.00|0.49|976.3|9.931|4.884|
|23|MTC|534.9|0.568|1.00|0.34|249.5|7.963|4.270|
|24|YJY*|14.5|0.737|0.48|1.00|8,587.0|13.068|3.699|
|25|ShinyRosy*|7.3|0.714|0.24|1.00|26,144.5|14.674|1.667|
|26|sephjiang*|7.3|0.714|0.24|1.00|26,764.1|14.708|1.663|

**Could not run (notebook crashes):** dpu_b1600_yolox, dpu_b1600_yolox_pybind,dpu_b2304_yolox

\* = from preliminary submission

** Results and ranking of top 3 winning teams will be announced in person at the DAC conference (teams currently listed alphabetically).

## June Submission Results

|Rank|Team Name|FPS|IoU|FPS Penalty|IoU Penalty|Energy(J)|Energy Score|Total Score|
|-----|-----|-----|-----|-----|-----|-----|-----|-----|
|1|TmpSEU|363.910|0.702|1.00|1.00|354.1|8.468|11.809|
|2|UBPercept|546.250|0.703|1.00|1.00|359.9|8.491|11.777|
|3|SoutheastASIC|405.160|0.703|1.00|1.00|422.9|8.724|11.462|
|4|Monday|405.200|0.703|1.00|1.00|487.1|8.928|11.201|
|5|ultrateam|390.750|0.666|1.00|0.83|275.5|8.106|10.239|
|6|seuplayers|414.920|0.675|1.00|0.88|468.0|8.870|9.864|
|7|SEUer|460.130|0.675|1.00|0.88|509.6|8.993|9.730|
|8|whatever|153.950|0.680|1.00|0.90|883.5|9.787|9.196|
|9|InvolutionNet|171.270|0.667|1.00|0.84|833.7|9.703|8.605|
|10|CCAI_ZJU|21.520|0.711|0.72|1.00|6,540.7|12.675|5.659|
|11|Vienna EML|64.830|0.623|1.00|0.62|2,610.4|11.350|5.418|
|12|YJY|14.500|0.737|0.48|1.00|8,587.0|13.068|3.699|
|13|YoLook|231.210|0.560|1.00|0.30|928.8|9.859|3.043|
|14|TouchFish|8.020|0.697|0.27|0.99|18,995.2|14.213|1.853|
|15|txh|7.960|0.688|0.27|0.94|16,426.3|14.004|1.781|
|16|BoatingWithoutPaddle|104.760|0.454|1.00|0.10|1,410.1|10.462|0.956|
|17|MTC|63.780|0.391|1.00|0.10|1,649.5|10.688|0.936|
|18|BIT_gd|55.270|0.412|1.00|0.10|3,128.7|11.611|0.861|

**Notes:**
- **BIT_gd_plus**: ValueError: could not broadcast input array from shape (64,360,640,3) into shape (40,360,640,3)
- **super-capacitor**: On last batch: ValueError: 500 images provided, but 960 object locations returned.
- **whatever**: .hwh filename needs to match .bit filename
- **TouchFish**: print(toc-tic) undefined
- **txh**: print(toc-tic) undefined

## May Submission Results

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



## March Submission Results

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

