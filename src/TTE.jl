#### TTE: Target Trial Emulation wrapper function

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
        df, model_num, model_denom = IPCW(df, covariates)
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

    return df, out_model
end

