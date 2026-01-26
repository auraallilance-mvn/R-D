---
title: "Steel Plate Detection System"
description: "Computer vision model achieving 92% accuracy in steel plate defect detection using Roboflow AI platform."
category: "cv"
featured: false
featured_image: "/assets/projects/steel-detection.jpg"
gallery:
  - "/assets/projects/steel-samples.jpg"
  - "/assets/projects/steel-analysis.jpg"
technologies:
  - "Roboflow"
  - "Computer Vision"
  - "AI"
  - "Object Detection"
  - "Quality Control"
status: "completed"
start_date: "2023-06-10"
completion_date: "2023-09-15"
project_url: "https://universe.roboflow.com/milk-packet/steel-testing"
github_url: ""
demo_video: ""
features:
  - "Real-time defect detection"
  - "92% accuracy rate"
  - "Multiple defect type classification"
  - "Automated quality assessment"
  - "Integration with production lines"
challenges: "The main challenge was creating a diverse dataset with various defect types and lighting conditions. We overcame this by implementing data augmentation techniques and collecting samples from multiple steel manufacturing facilities."
results: "Achieved 92% accuracy in defect detection with processing speed of 15 FPS. The system can identify scratches, dents, rust, and surface irregularities with high precision."
future_work: "Planning to expand the model to detect more defect types and integrate with robotic sorting systems for automated quality control."
meta_description: "AI-powered steel plate defect detection system with 92% accuracy using computer vision and Roboflow platform."
tags:
  - "Computer Vision"
  - "AI"
  - "Quality Control"
  - "Manufacturing"
  - "Roboflow"
---

## Project Overview

The Steel Plate Detection System is an advanced computer vision solution designed to automatically identify and classify defects in steel plates during manufacturing processes. Using the Roboflow AI platform, this system achieves 92% accuracy in detecting various types of surface defects, significantly improving quality control efficiency.

## Technical Implementation

### Dataset Development
- **Image Collection**: 2,500+ high-resolution steel plate images
- **Defect Categories**: Scratches, dents, rust, surface irregularities, edge defects
- **Data Augmentation**: Rotation, scaling, brightness adjustment, noise addition
- **Annotation**: Precise bounding box labeling for each defect type

### Model Architecture
- **Framework**: YOLOv8 object detection model
- **Training Platform**: Roboflow Universe
- **Input Resolution**: 640x640 pixels
- **Classes**: 5 defect types + background
- **Training Data**: 80% training, 15% validation, 5% testing

### Performance Metrics
- **Overall Accuracy**: 92%
- **Precision**: 89%
- **Recall**: 94%
- **F1-Score**: 91%
- **Processing Speed**: 15 FPS on standard hardware

## Applications and Impact

This system has been successfully deployed in:
- **Steel Manufacturing Plants**: Real-time quality control
- **Automotive Industry**: Component inspection
- **Construction Materials**: Structural steel verification
- **Research Facilities**: Material science studies

The implementation has resulted in:
- 40% reduction in manual inspection time
- 25% improvement in defect detection rate
- Significant cost savings in quality control processes