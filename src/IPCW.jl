#### IPCW: stabilised inverse probability of censor weighting to adjust for bias introduced by censoring

# necessary packages:
# GLM, StatsModels, DataFrames, Distributions

## generalize formula creation
## filtering for eligible subjects: summerschool yes, trialEMulation no: what to do, option?

function IPCW(df::DataFrame, covariates::Array{Symbol,1}, save_w_model::Bool = false)
    # initialise IPW column
    df[!, :IPCW] = ones(Float64, nrow(df))

    # filter/dont filter for eligible subjects
    #df_eligible = filter(row -> row.eligible == 1, df)
    #df_eligible = filter(row -> row.outcome == 0, df)
    #df_eligible = df

    # create formula string
    formula_string_d = "censored == 0 ~ $(join(covariates, " + ")) + period + (period^2)"

    # fit model
    model_num = glm(@formula(censored == 0 ~ period + (period^2)), df, Binomial(), LogitLink())
    model_denom = glm(eval(Meta.parse("@formula $formula_string_d")), df, Binomial(), LogitLink())
    
    prd_num = predict(model_num, df)
    prd_denom = predict(model_denom, df)

    # calculate inverse propensity weights with ifelse
    df[!, :IPCW] .= (prd_num ./ prd_denom)

    # return weights instead of DF


    # truncate weights at 99th percentile
    #df[!, :IPW] = ifelse.(df.IPW .> quantile(df.IPW, 0.99), quantile(df.IPW, 0.99), df.IPW)
    
    # return weighting models and df
    if save_w_model == true
        return df, model_num, model_denom
    else
        return df
    end
end