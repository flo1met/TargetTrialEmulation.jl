# Getting Started Vignette

This vignette will guide you through a first example of using the TargetTrialEmulation.jl package to perform sequential target trial emulation. 
To perform sequential target trial emulation, you will need to have a dataset with the following columns:
- `:id` - a unique patient identifier
- `:time` - the time at which the individual is observed
- `:treatment` - a binary indicator of whether the individual was treated
- `:outcome` - a binary indicator of whether the individual experienced the event of interest
- `:censor` - a binary indicator of whether the individual was censored
- `:eligible` - a binary indicator of whether the individual was eligible for treatment at each time point
- (optional) `:covariate1`, `:covariate2`, ... - additional covariates that you would like to adjust for

In this example, we will use a simulated dataset that is included in the package.

## Installation

To install the package, run the following command in the Julia REPL:

```julia
using Pkg
Pkg.add(url="https://github.com/flo1met/TargetTrialEmulation.jl")
```

## Load Packages

```julia
using TargetTrialEmulation
using DataFrames
using CSV
using CategoricalArrays
```

## Load the data and recode categorical variables

```julia
data = CSV.read("data/trial_example.csv", DataFrame)
data[!, :catvarA] = CategoricalArray(data.catvarA)
data[!, :catvarB] = CategoricalArray(data.catvarB)
```
## Perform sequential Target Trial Emulation

To perform sequential Target Trial Emulation we can use the wrapper function `TTE`. 
```julia
df_out, model = TTE(data, 
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = false,
    covariates = [:catvarA, :catvarB, :nvarA, :nvarB, :nvarC])
```

As an output we get the extended dataframe `df_out` and the fitted model `model`.
We can inspect the dimensions of the output dataframe.
```julia
size(df_out)
```

The resulting model is the following:
```julia
model
```





