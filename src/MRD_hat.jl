### MRD_hat
# estimate mean relative difference (MRD) between two sets of data

### Dependencies
#DataFrames, GLM,

## TODO
# test the function

function MRD_hat(out_df::DataFrame, id_var::Symbol, outcome_model)
    

#When using the predict function and I have a DF that has an observation at timepoint 1 and 5, will it correctl predict the 
#    (__cumulative__) outcome probability at timepoint 5?

    # change name Y to not_Y_0 and Y_1 to not_Y_1
    out_df.treatment_first .= 0
    out_df.Y_0 .= 1 .- predict(outcome_model, out_df)

    out_df.treatment_first .= 1
    out_df.Y_1 .= 1 .- predict(outcome_model, out_df)

    # cumulative product per trial and ID (cumulative hazard)
    ## not_Y_0 to S_0 and not_Y_1 to S_1 (survival)
    group = groupby(out_df, [:trialnr, id_var])
    transform!(group, [:Y_0, :Y_1] .=> cumprod, renamecols=false)

    # calculate cumulative incidence at every timeopoint over all trials and calculate MRD_hat.
    ##
    group = groupby(out_df, [:fup])
    MRD_hat = combine(group, [:Y_0, :Y_1] .=> mean)
    MRD_hat.MRD_hat .= MRD_hat.Y_1_mean .- MRD_hat.Y_0_mean

    # add CI (prob. wrong)
    #MRD_hat.CI_low .= 2*MRD_hat.MRD_hat .- quantile(MRD_hat.MRD_hat, 0.975)
    #MRD_hat.CI_high .= 2*MRD_hat.MRD_hat .- quantile(MRD_hat.MRD_hat, 0.025)

    return MRD_hat
end