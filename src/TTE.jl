"""
    TTE(df::DataFrame, outcome::Symbol, treatment::Symbol, period::Symbol, eligible::Symbol, censored::Symbol, covariates::Array{Symbol,1}, save_w_model::Bool = false)

This function emulates target trials using the sequential trial emulation method.

# Keyword Arguments
- `outcome::Symbol`: Outcome column.
- `treatment::Symbol`: Treatment column.
- `period::Symbol`: Period column.
- `eligible::Symbol`: Eligible column.
- `censored::Symbol`: Censored column.
- `covariates::Array{Symbol,1}`: Array of covariates (that are in the DataFrame) to be fixed to baseline values.
- `save_w_model::Bool`: Indicator if the weighting model should be saved.

# Output

- `df`: DataFrame with the following columns:
    - `:id`: ID of the patient.
    - `:period`: Timepoint of the observation.
    - `:eligible`: Indicator if patient is eligible.
    - `:treatment`: Indicator if patient is treated.
    - `:trialnr`: Trial number.
    - `:fup`: Follow-up time.
    - `:baseline_treatment`: Indicator if patient is treated at baseline.
    - `covariates`: Covariates fixed to baseline values.
- `out_model`: Outcome model.
- `model_num`: Numerator model (only if `save_w_model` is `true`).
- `model_denom`: Denominator model (only if `save_w_model` is `true`).

# Example

"""

#### TTE: Target Trial Emulation wrapper function

## TODO
# - add example (when the function is ready and example DF is created)


function TTE(df::DataFrame;
    outcome::Symbol,
    treatment::Symbol,
    period::Symbol,
    eligible::Symbol,
    censored::Symbol,
    covariates::Array{Symbol,1},
    #model::String,
    #method::String,
    save_w_model::Bool = false)

    # rename columns to standard names
    rename!(df, outcome => :outcome, 
                treatment => :treatment, 
                period => :period, 
                eligible => :eligible,
                censored => :censored)

    # apply weighting
    if save_w_model == true
        df, model_num, model_denom = IPCW(df, covariates, save_w_model)
    else
        df = IPCW(df, covariates)
    end

    # Emulate Trials
    ## convert to arrow
    df = convert_to_arrow(df)
    ## emulate trials
    df = dict_to_df(seqtrial(df, covariates))
    ## cumulative product of IPCW per id and trialnr
    df = combine(groupby(df, [:id, :trialnr]), All(), :IPCW => (x -> cumprod(x)) => :IPCW)
    
    ## outcome model
    out_model = glm(@formula(outcome ~ baseline_treatment + trialnr + (trialnr^2) + fup + (fup^2)), df, Binomial(), LogitLink(), wts = df.IPCW)


    # rerename columns for final output
    #rename!(df, :outcome => outcome, 
    #            :treatment => treatment, 
    #            :period => period, 
    #            :eligible => eligible)

    if save_w_model == true
        return df, out_model, model_num, model_denom
    else
        return df, out_model
    end
end

