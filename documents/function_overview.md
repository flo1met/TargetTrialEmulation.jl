## TTE.jl: 

Wrapper function for performing sequential Target Trial Emulation. 

### Keyword agruments
    - df::DataFrame: Dataframe containing observational dataset
    - id_var::Symbol: Patient ID variable
    - outcome::Symbol: Otcome variable
    - treatment::Symbol: Treatment variable
    - period::Symbol: Variable inidcating timepoint of observation
    - eligible::Symbol: Eligibility variable
    - ipcw::Bool: True/False, use censor weighting?
    - censored::Union{Symbol,Nothing}: if ipcw = True, censor variable
    - covariates::Array{Symbol,1}: Array of covariates for model
    - method::String: ITT/PP: indicating type of analysis, PP will give error as not implemented yet
    - save_w_model::Bool: True/False, save weighting model
    - fill_missing_timepoints::Bool: True/False, fill missing timepoints for patients, True will give warning as not implemented yet
    - estimate_surv::Bool: True/False, estimate survival curves (True will start bootstrapping)
    - B::Int: N of bootstrap iterations
    - use_arrow::Bool: True/False,convert data to arrow file prior to analysing
    - save_BS::Bool: True/False, save bootstrap sample (used for visualisation of bootstrap samples, should in future be used for implementing BCa)

### Output
    - df_out: sequentially emulated dataset
    - out_model: outcome model
    - model_num: numerator weighting model
    - model_denom: denominator weighting model (for more info, see documentation of R package)
    - MRD_hat_CI: MRD estimate + CIs (percentile and empirical)
    - BS: Bootstrap samples

## ITT.jl

Wrapper function for Intention To Treat analysis.
Used within TTE.jl

### Keyword agruments

See TTE.jl

### Output
    - df
    - out_model
    - model_num
    - model_denom

## PP.jl

Incomplete wrapper function for Per-Protocol analysis. 

## seqtrial.jl and seqtrial_tv.jl

Function to extend the dataset according to sequential TTE.
seqtrial.jl fixes covariates and treatment to baseline.
seqtrial_tv.jl: time varying covariates, necessary for PP analysis.

### Keyword agruments
    - df::DataFrame: Dataframe containing observational dataset
    - id_var::Symbol: Patient ID variable
    - covariates::Array{Symbol,1}: Array of covariates for model

### Output
    - df: extended dataframe

## IPCW.jl and IPTW.jl

Function calculating Inverse Probability of Treatment/Censoring Weight.
Should be merged to one function by generalising the formula generation.

### Keyword agruments
    - df::DataFrame: Dataframe containing observational dataset
    - covariates::Array{Symbol,1}: Array of covariates for model
    - save_w_model::Bool: True/False, save weighting model

### Output
    - df: df with added weight column
    - model_num: numerator weighting model
    - model_denom: denominator weighting model (for more info, see documentation of R package)

## MRD_hat.jl

Function to estimate MRD estimate.

### Keyword agruments
    - df::DataFrame: Dataframe containing observational dataset
    - id_var::Symbol: Patient ID variable
    - covariates::Array{Symbol,1}: Array of covariates for model

### Output
    - MRD_hat: MRD estimate

## bootstrap_patients.jl

Includes two funcitons necessary to perform bootstrap. There is an existing bootstrapping package in Julia, but it does not support time-to-event data.


### bootstrap_sample
Function to create a bootstrap sample of patients.

#### Keyword agruments
    - df::DataFrame: Dataframe containing observational dataset
    - id_var::Symbol: Patient ID variable

#### Output
    - df_bs: bootstrap sample

### BS_CI
Function to calculate CIs based on bootstrap samples.

#### Keyword agruments
    - df::DataFrame: 
    - B::Int64: 
    - MRD_hat_PE: Original MRD estimate
    - args: Keyword arguments passed to TTE.jl

#### Output
    - MRD_hat_CI: MRD estimate + CIs (percentile and empirical)
    - BS: Bootstrap samples

### art_censor.jl
Function to artificially censor patients after deviation from assigned treatment strategy. Necessary for PP analysis.
Input is the dataset after applying seqtrial_tv.jl, output is the same dataset with added censoring variable.

### convert_to_arrow.jl

Function to convert dataframe to arrow file. Used to reduce memory usage when dataset is large. Data usage is lower (see appendix in thesis), but speed is not necessarily improved.

### dict_to_df.jl
Function to convert dictionary to dataframe. Not used anymore can be deleted.

### utils.jl
Utility functions. Explained in file.




