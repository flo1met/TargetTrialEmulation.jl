# Replicate getting started TrialEmulation

This guide replicates the results of the getting started guide of the TrialEmulation R package (https://causal-lda.github.io/TrialEmulation/articles/Getting-Started.html).

## Required Data

To get started a longitudinal dataset must be created containing:

- time period
- patient identifier
- treatment indicator
- outcome indicator
- censoring indicator
- eligibility indicator for a trial starting in each time period
- other covariates relating to treatment, outcome, or informative censoring to be used in the models for weights or the outcome

An example dataset is provided in the data folder (`trial_example.csv`).

## Setup and Installation

```julia
using CSV
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays
using DataFrames
using GLM
using StatsModels
```

## Load and Prepare Data

```julia
# Load the data
data = CSV.read("data/trial_example.csv", DataFrame)

# Convert the categorical variables to categorical arrays
data[!, :catvarA] = CategoricalVector(data.catvarA)
data[!, :catvarB] = CategoricalVector(data.catvarB)
```

**Output:**
```
#48400×12 DataFrame
   Row │ Column1  id     eligible  period  outcome  treatment  catvarA  catvarB  catvarC  nvarA  nv ⋯
       │ Int64    Int64  Int64     Int64   Int64    Int64      Int64    Int64    Int64    Int64  In ⋯
───────┼─────────────────────────────────────────────────────────────────────────────────────────────
     1 │       1    202         1     310        0          0        0        2        0      0     ⋯
     2 │       2    202         1     311        0          1        0        2        1      0      
     3 │       3    202         1     312        0          1        0        2        1      0      
     4 │       4    202         1     313        0          1        0        2        1      0      
     5 │       5    202         0     314        0          1        0        2        1      0     ⋯
   ⋮   │    ⋮       ⋮       ⋮        ⋮        ⋮         ⋮         ⋮        ⋮        ⋮       ⋮       ⋱
 48396 │   48396    436         1     319        0          0        2        7        7      0      
 48397 │   48397    436         1     320        0          0        2        7        7      0      
 48398 │   48398    436         1     321        0          0        2        7        7      0      
 48399 │   48399    436         1     322        0          0        2        7        7      0     ⋯
 48400 │   48400    436         1     323        0          0        2        7        7      0      
```

## Perform Sequential Target Trial Emulation

```julia
# Perform sequential TTE
df_out, model = TTE(data, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = false,
    covariates = [:catvarA, :catvarB, :nvarA, :nvarB, :nvarC],
    estimate_surv = false
)
```

**Output:**
```
(1939053×20 DataFrame
     Row │ Column1  id     eligible  period  outcome  treatment  catvarA  catvarB  catvarC  nvarA   ⋯
         │ Int64    Int64  Int64     Int64   Int64    Int64      Cat…     Cat…     Int64    Int64   ⋯
─────────┼───────────────────────────────────────────────────────────────────────────────────────────
       1 │   15771     54         1      56        0          0  7        7              7      0   ⋯
       2 │   15772     54         1      57        0          0  7        7              7      0    
       3 │   15773     54         1      58        0          0  7        7              7      0    
       4 │   15774     54         1      59        0          0  7        7              7      0    
       5 │   15775     54         1      60        0          0  7        7              7      0   ⋯
    ⋮    │    ⋮       ⋮       ⋮        ⋮        ⋮         ⋮         ⋮        ⋮        ⋮       ⋮     ⋱
 1939049 │   45729    497         0     370        0          1  2        2              0      1    
 1939050 │   45730    497         0     371        0          1  2        2              0      1    
 1939051 │   45731    497         0     372        0          1  2        2              0      1    
 1939052 │   28870    498         1     298        0          0  0        1              0      0   ⋯
 1939053 │   28871    498         0     299        1          0  0        1              0      0    
```

## Model Results

```julia
# View the model results
model
```

**Output:**
```
outcome ~ 1 + treatment_first + catvarA_first + catvarB_first + nvarA_first + nvarB_first + nvarC_first + trialnr + :(trialnr ^ 2) + fup + :(fup ^ 2)

Coefficients:
────────────────────────────────────────────────────────────────────────────────────────
                        Coef.   Std. Error       z  Pr(>|z|)      Lower 95%    Upper 95%
────────────────────────────────────────────────────────────────────────────────────────
(Intercept)       -3.21473     0.141249     -22.76    <1e-99   -3.49158      -2.93789
treatment_first   -0.272859    0.0465543     -5.86    <1e-08   -0.364104     -0.181615
catvarA_first: 1   0.297954    0.0280241     10.63    <1e-25    0.243028      0.35288
catvarA_first: 2   0.152392    0.0386187      3.95    <1e-04    0.0767007     0.228083
catvarA_first: 3  -7.0565      4.71633       -1.50    0.1346  -16.3003        2.18732
catvarA_first: 7   0.412817    0.0374838     11.01    <1e-27    0.33935       0.486284
catvarB_first: 1  -0.404773    0.111554      -3.63    0.0003   -0.623415     -0.186131
catvarB_first: 2  -0.431478    0.115413      -3.74    0.0002   -0.657683     -0.205272
catvarB_first: 3  -2.44022     0.335247      -7.28    <1e-12   -3.09729      -1.78315
catvarB_first: 7  -0.716172    0.112353      -6.37    <1e-09   -0.936381     -0.495963
nvarA_first       -0.085538    0.00767413   -11.15    <1e-28   -0.100579     -0.070497
nvarB_first        0.00535222  0.000316493   16.91    <1e-63    0.00473191    0.00597254
nvarC_first       -0.0420198   0.000875977  -47.97    <1e-99   -0.0437367    -0.0403029
trialnr            0.00172638  0.000600524    2.87    0.0040    0.000549378   0.00290339
trialnr ^ 2        1.27073e-6  1.48447e-6     0.86    0.3920   -1.63878e-6    4.18024e-6
fup                0.00285457  0.000520769    5.48    <1e-07    0.00183388    0.00387526
fup ^ 2           -6.90401e-6  2.26778e-6    -3.04    0.0023   -1.13488e-5   -2.45924e-6
────────────────────────────────────────────────────────────────────────────────────────)```
