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
    outcome::Symbol,
    treatment::Symbol,
    period::Symbol,
    eligible::Symbol,
    ipcw::Bool = false,
    censored::Union{Symbol,Nothing} = nothing,
    covariates::Array{Symbol,1},
    #model::String,
    #method::String,
    save_w_model::Bool = false)

    # rename columns to standard names
    if isnothing(censored)
        rename!(df, outcome => :outcome, 
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

    # apply weighting
    if ipcw == true
        if save_w_model == true
            df, model_num, model_denom = IPCW(df, covariates, save_w_model)
        else
            df = IPCW(df, covariates)
        end
    end

    

    # Emulate Trials
    cat_name = []
    for cov_cat in covariates
        if isa(df[!, cov_cat], CategoricalArray)
            push!(cat_name, cov_cat)
        end
    end


    ## convert to arrow
    df = convert_to_arrow(df)
    ## emulate trials
    #df = dict_to_df(seqtrial(df, covariates))
    df = seqtrial(df, covariates)


    cat_name = ["$(cov)_first" for cov in cat_name] # add _first to each covariate
    if !isempty(cat_name)
        for cov_cat in cat_name
            df[!, cov_cat] = CategoricalArray(df[!, cov_cat])
        end
    end
    
    ## cumulative product of IPCW per id and trialnr
    #####QUICKFIX FOR KEEPING CATEGORICAL 
    # Check if covariate is categorical, if yes save name
    #cat_name_new = []
    #for covv in covariates
    #    if isa(df[!, covv], CategoricalArray)
    #        push!(cat_name_new, covv)
    #    end
    #end

    if ipcw == true
        df = combine(groupby(df, [:id, :trialnr]), All(), :IPCW => (x -> cumprod(x)) => :IPCW)
    end
    
    # convert categorical variables back to categorical
    #if !isnothing(cat_name_new)
    #    for covvv in cat_name_new
    #        df[!, covvv] = CategoricalArray(df[!, covvv])
    #    end
    #end

    #### QUICKFIX END

    ## outcome model (ALWAYS ADJUST FOR COVARIATES)
    # create formula string
    # add _first to each covariate
    covariates = ["$(cov)_first" for cov in covariates]
    formula_string = "outcome ~ treatment_first + $(join(covariates, " + ")) + trialnr + (trialnr^2) + fup + (fup^2)"

    # fit model
    if ipcw == true
        out_model = glm(eval(Meta.parse("@formula $formula_string")), df, Binomial(), LogitLink(), wts = df.IPCW)
    else
        out_model = glm(eval(Meta.parse("@formula $formula_string")), df, Binomial(), LogitLink())        
    end
    


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

