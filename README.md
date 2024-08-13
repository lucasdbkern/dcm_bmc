# SPM_DCM_BMC
MATLAB scripts for generating simulated DCM subjects and performing Bayesian Model Comparison. 


Bayesian Model Comparison and Parametric Empirical Bayes for DCM Analysis
This project provides a MATLAB pipeline for performing Bayesian Model Comparison
 (BMC) and Parametric Empirical Bayes (PEB) + Bayesian Model Reduction(BMR) on
  Dynamic Causal Models (DCMs) for ERP data. 
  This codebase consists of two main workflows: BMC (Pipeline 1) and PEB+BMC (Pipeline 2).
  
Overview:
The purpose of this project is to compare different DCM models and assess their performance using different Bayesian Model Selection techniques. The pipeline generates multiple subjects by adding varying noise levels to parameters, timeseries and input and applies BMC and PEB+BMC to determine the best-fitting models.

The project includes the following key components:

erp_analysis.m: Script for importing and preprocessing ERP data, defining regions of interest (ROIs), and specifying the connectivity structure of the DCM models.

multiple_subject_bmc.m: Script for generating multiple subjects with different noise levels and performing BMC on each subject's DCM models.

group_level_value_with_spm_dcm_bmc.m: Script for creating a confusion matrix based on the BMC results across all subjects.

GCM_creator_for_PEB_confusion_matrix.m: Script for creating a Confusion Matrix for the PEB+BMC pipeline.

GCM_creator: Script for creating a Confusion Matrix. 

peb.m: Script for performing PEB analysis on the DCM models.

average_F_PEB_heatmap.m: Script for creating a confusion matrix based on the PEB+BMC results.

Prerequisites
To run this pipeline, you need to have MATLAB installed with the following toolboxes:

SPM12 (Statistical Parametric Mapping)

Pipeline 1: BMC
To run the BMC pipeline, follow these steps:

1. Run erp_analysis.m to preprocess the ERP data and specify the DCM models.
2. Run multiple_subject_bmc.m to generate multiple subjects and perform BMC on each subject's DCM models.
3. Run group_level_value_with_spm_dcm_bmc.m to create a confusion matrix based on the BMC results across all subjects.

The BMC pipeline will provide insights into the performance of different DCM models and help identify the best models for the given time series.

Pipeline 2: PEB+BMC
To run the PEB+BMC pipeline, follow these steps:

1. Run erp_analysis.m to preprocess the ERP data and specify the DCM models.
2. Run multiple_subject_bmc.m to generate multiple subjects and perform BMC on each subject's DCM models.
3. Run GCM_creator.m, it is necessary for 
4. Run GCM_creator_for_PEB_confusion_matrix.m to create a Confusion Matrix for the PEB+BMC pipeline.
5. Run peb.m to perform PEB analysis on the DCM models.
    Here it should be of note that you have to call PEB for all three cases:
    peb('Full'), peb('ORA'), peb('TRA')
6. Run average_F_or_P_heatmap.m to create a confusion matrix based on the PEB+BMC results.


Alternatively, you can just call: pipeline2.m for pipeline2, which will call execute steps 3 to 5 automatically. 

If you want to see the distributions of, for example, F or Pp values across subjects, call group_level_value.m


The PEB+BMC pipeline extends the BMC analysis by incorporating PEB to estimate the between-subject variability of model parameters and provide a more robust assessment of model performance.

DISCLAIMER: If you want to run both Pipelines, the first two steps have not to be rerun. 


Database Structure
The project assumes a specific database structure for storing the generated subject data and results. The main folder contains subfolders for each subject, following the naming convention subject_<number>. Each subject folder should include the generated DCM models and the corresponding analysis results.


Comments: Full, ORA and TRA refer to the Full Model, ORA to the model Once Removed connections in the A matrix (=ORA), as here the connections connecting the rSTG to iFG was turned off. 
    TRA refers to Twice Removed connections in the A matrix (=TRA), as the connections were removed even further: Only the lateral connections between hemispheres remain. 
    
