### MRD_hat
# estimate mean relative difference (MRD) between two sets of data

### Dependencies
#DataFrames, GLM,

## TODO
# test the function

function MRD_hat(out_df::DataFrame, id_var::Symbol, outcome_model)
    
    # get highest followup time
    max_fup = maximum(out_df[!, :fup])
    df_est = newdata(out_df, max_fup)


    #### distinguish between S here and cumulative (to return for debug)
    df_est.treatment_first .= 0
    df_est.S_0 .= 1 .- predict(outcome_model, df_est)

    df_est.treatment_first .= 1
    df_est.S_1 .= 1 .- predict(outcome_model, df_est)

    # cumulative product per trial and ID (cumulative hazard)
    ## not_Y_0 to S_0 and not_Y_1 to S_1 (survival)
    group = groupby(df_est, [:trialnr, id_var])
    transform!(group, [:S_0, :S_1] .=> cumprod, renamecols=false)

    # calculate cumulative incidence at every timeopoint over all trials and calculate MRD_hat.
    ##
    group = groupby(df_est, [:fup])
    MRD_hat = combine(group, [:S_0, :S_1] .=> mean)
    MRD_hat.MRD_hat .= MRD_hat.S_1_mean .- MRD_hat.S_0_mean 

    return MRD_hat
end