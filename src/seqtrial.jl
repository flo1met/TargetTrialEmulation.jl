"""
    seqtrial(df::DataFrame, covariates::Array{Symbol,1})

Set up treatment arms of sequential target trial.
Confounders are fixed to baseline values.

# Keyword Arguments

- `df::DataFrame`: DataFrame with columns `:id`, `:period`, `:eligible`, `:treatment`.
- `covariates::Array{Symbol,1}`: Array of covariates (that are in the DataFrame) to be fixed to baseline values.

# Output

- `trials_dict`: Dict with keys as period numbers and values as DataFrames with the following columns:
    - `:id`: ID of the patient.
    - `:period`: Timepoint of the observation.
    - `:eligible`: Indicator if patient is eligible.
    - `:treatment`: Indicator if patient is treated.
    - `:trialnr`: Trial number.
    - `:fup`: Follow-up time.
    - `:baseline_treatment`: Indicator if patient is treated at baseline.
    - `covariates`: Covariates fixed to baseline values.

# Example

```julia
using DataFrames
df = DataFrame(id = [1, 1, 2, 2, 3, 3, 4, 4],
               period = [1, 2, 1, 2, 1, 2, 1, 2],
               eligible = [1, 1, 1, 1, 1, 1, 1, 1],
               treatment = [0, 1, 0, 1, 0, 1, 0, 1],
               age = [20, 20, 30, 30, 40, 40, 50, 50])
covariates = [:age]
trials_dict = seqtrial(df, covariates)
```
"""

#### seqtrial: set up treatment arms of sequential target trial
# confounders fixed to baseline values

#### necessary packages
# Arrow, DataFrames,

## todo: make it a ! function
## todo: integrate censoring function before making final df
## todo: assigned treatment variable

## todo: i -> period_id
## todo: check if when fixing baseline cov, is it copying data? should we create 2 objects, time-fixed voc and time-varying cov
## todo: add trialnr column when stacking dicts to df
## todo: at the beginning, select only variables that are used to keep in DF, to safe memory space
## todo: rounding of covariates
## todo: categorical variables, check if they are copied correctly


function seqtrial(df::DataFrame, covariates::Array{Symbol,1})
    # Emulate Target Trials
    trials_dict = Dict{Int64, DataFrame}() # Create dict to save DFs
    
    for i in unique(df[!,:period])
        filt_tmp(eligible, period) = eligible == 1 && period == i # creates template for filtering
        elig_tmp = filter([:eligible, :period] => filt_tmp, df).id
        filt_tmp2(id, period) = in(id, elig_tmp) && period >= i # filters all ids that are eligible at timepoint i and all following timepoints of them
        trial_tmp = filter([:id, :period] => filt_tmp2, df)

        if isempty(trial_tmp)
            continue  # Skip this iteration if no eligible data is found
        end

        trial_tmp[!, :trialnr] .= i # add Trial Nr

        start_time = minimum(trial_tmp[!, :period]) # get start time
        trial_tmp[!, :fup] .= trial_tmp.period .- start_time # add follow-up-time
        #transform!(groupby(trial_tmp, :id), eachindex => :fup) # add follow-up-time

        sort!(trial_tmp, [:id, :period]) # sort for treatment assignment

        # add indicator for baseline treatment assignment by id
        trial_tmp[!, :baseline_treatment] .= 0
        grouped_df = groupby(trial_tmp, :id)
        for group in grouped_df
            if group.treatment[1] == 1
                group.baseline_treatment .= 1
            end

            # fix covariates to baseline values
            for cov in covariates
                group[!, cov] .= group[1, cov] 
            end
        end

        trials_dict[i] = trial_tmp
    end
    return trials_dict
end

