---
layout: page
toc: false
title: Evaluation
sidebar: true
icon: fas fa-sort-numeric-down
order: 4
---

The design is solely evaluated by the total energy consumption; however, there are minimum thresholds on accuracy and throughput.  If these minimums are not met, penalties are applied.

### Accuracy 

Accuracy is measured using IoU (Intersection over Union). A good example of IoU can be found at <https://www.pyimagesearch.com/2016/11/07/intersection-over-union-iou-for-object-detection/>.

The minimum accuracy should be 0.7, otherwise a penalty is applied.

### Throughput. 

The design should achieve at least 30 FPS, otherwise a penatly is applied.

### Scoring Function

The score for a team is calculated as follows:

**Score = 10^2 / log2(Energy) × Max(ReLU([1 - 5 × ReLU(0.7 - IoU)]), 0.1) × ReLU([1 - ReLU(1 - FPS / 30)])**

ReLU is a non-linear function that helps apply the penalty: ReLU(x) = (x > 0) ? x : 0.