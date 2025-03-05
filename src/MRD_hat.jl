### MRD_hat
# estimate mean relative difference (MRD) between two sets of data

### Dependencies
#DataFrames, GLM,

## TODO
# test the function

function MRD_hat(out_df::DataFrame, id_var::Symbol, outcome_model)
    

#When using the predict function and I have a DF that has an observation at timepoint 1 and 5, will it correctl predict the 
#    (__cumulative__) outcome probability at timepoint 5?

    #### distinguish between S here and cumulative (to return for debug)
    out_df.treatment_first .= 0
    out_df.S_0 .= 1 .- predict(outcome_model, out_df)

    out_df.treatment_first .= 1
    out_df.S_1 .= 1 .- predict(outcome_model, out_df)

    # cumulative product per trial and ID (cumulative hazard)
    ## not_Y_0 to S_0 and not_Y_1 to S_1 (survival)
    group = groupby(out_df, [:trialnr, id_var])
    transform!(group, [:S_0, :S_1] .=> cumprod, renamecols=false)

    # calculate cumulative incidence at every timeopoint over all trials and calculate MRD_hat.
    ##
    group = groupby(out_df, [:fup])
    MRD_hat = combine(group, [:S_0, :S_1] .=> mean)
    MRD_hat.MRD_hat .= MRD_hat.S_1_mean .- MRD_hat.S_0_mean 

    return MRD_hat
end