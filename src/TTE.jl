#### TTE: Target Trial Emulation wrapper function

## NOTE:! outcome model right now always adjusts for covariates.

## TODO
# - add example (when the function is ready and example DF is created)
# - covariate adjsutment of MSM, add option or something

"""
    TTE(df::DataFrame, outcome::Symbol, treatment::Symbol, period::Symbol, eligible::Symbol, censored::Symbol, covariates::Array{Symbol,1}, save_w_model::Bool = false)

This is a wrapper function to emulates target trials using the sequential trial emulation method.

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
function TTE(df::DataFrame;
    id_var::Symbol,
    outcome::Symbol,
    treatment::Symbol,
    period::Symbol,
    eligible::Symbol,
    ipcw::Bool = false,
    censored::Union{Symbol,Nothing} = nothing,
    covariates::Array{Symbol,1},
    #model::String,
    method::String = "ITT",
    save_w_model::Bool = false,
    fill_missing_timepoints::Bool = false,
    estimate_surv::Bool = true,
    B::Int = 500,
    use_arrow = false)

    # rename columns to standard names
    if isnothing(censored)
        rename!(df, 
        outcome => :outcome,
        treatment => :treatment, 
        period => :period, 
        eligible => :eligible)
    else
        rename!(df, outcome => :outcome, 
        treatment => :treatment, 
        period => :period, 
        eligible => :eligible,
        censored => :censored)
    end

    # save function arguments
    args = Dict(
        :id_var => id_var,
        :outcome => outcome,
        :treatment => treatment,
        :period => period,
        :eligible => eligible,
        :ipcw => ipcw,
        :censored => censored,
        :covariates => covariates,
        :save_w_model => save_w_model,
        :use_arrow => use_arrow
    )

    ## test if there are missing timepoints
    if fill_missing_timepoints == true
        error("Filling missing timepoints is not implemented yet.")
    elseif fill_missing_timepoints == false
        group = groupby(df, id_var)
        for g in group
            if has_gap(Vector(g[!, :period]))
                error("There are missing timepoints, which leads to an incorrect computation of the (cumulative survival probability (?)). \n
                Please make sure that there are no missing timepoints. \n
                For using a last observation carried forward approach, please use the argument 'fill_missing_timepoints'.")
            end
        end
    end

    # copy df
    df_run = copy(df)

    # Order by ID and period to ensure the loop is going through the data correctly
    sort!(df, [id_var, :period]) 

    # apply weighting
    if method == "ITT"
        if save_w_model == true
            df_out, out_model, model_num, model_denom = ITT(df_run; args...)
        else
            df_out, out_model = ITT(df_run; args...)
        end
    elseif method == "PP"
        error("PP not implemented yet.")
    end

    if estimate_surv        
        MRD_hat_PE = MRD_hat(df_out, id_var, out_model)
        MRD_hat_CI = BS_CI(df, B, MRD_hat_PE, args)
    end
    
    


    # rerename columns for final output
    if isnothing(censored)
        rename!(df, 
        :outcome => outcome,
        :treatment => treatment, 
        :period => period, 
        :eligible => eligible)
    else
        rename!(df, :outcome => outcome, 
                :treatment => treatment, 
                :period => period, 
                :eligible => eligible)
    end
    

    if save_w_model == true && estimate_surv == true
        return df_out, out_model, model_num, model_denom, MRD_hat_CI
    elseif save_w_model == true && estimate_surv == false
        return df, out_model, model_num, model_denom
    elseif save_w_model == false && estimate_surv == true
        return df_out, out_model, MRD_hat_CI
    else
        return df_out, out_model
    end
end

