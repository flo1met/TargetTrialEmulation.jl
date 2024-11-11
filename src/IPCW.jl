#### IPCW: stabilised inverse probability of censor weighting to adjust for ____ bias introduced by censoring

# necessary packages:
# GLM, StatsModels, DataFrames, Distributions

## todo: make it a ! function
## generalize formula creation

function IPCW(df::DataFrame, covariates::Array{Symbol,1})
    # initialise IPW column
    df[!, :IPCW] = ones(Float64, nrow(df))

    df_eligible = filter(row -> row.eligible == 1, df)
    df_eligible = filter(row -> row.outcome == 0, df)

    # create formula string
    formula_string_d = "censored == 0 ~ $(join(covariates, " + ")) + period + (period^2)"

    # create model
    model_num = glm(@formula(censored == 0 ~ period + (period^2)), df_eligible, Binomial(), LogitLink())
    model_denom = glm(eval(Meta.parse("@formula $formula_string_d")), df_eligible, Binomial(), LogitLink())
    
    prd_num = predict(model_num, df)
    prd_denom = predict(model_denom, df)

    # calculate inverse propensity weights with ifelse
    df[!, :IPCW] .= Float64.(ifelse.(df.censored .== 0, (prd_num ./ prd_denom), 0))

    # truncate weights at 99th percentile
    #df[!, :IPW] = ifelse.(df.IPW .> quantile(df.IPW, 0.99), quantile(df.IPW, 0.99), df.IPW)

    # delete models and weights
    prd_num = nothing
    prd_denom = nothing
    #model_num = nothing
    #model_denom = nothing
    
    # return weighting models and df
    return df, model_num, model_denom
end