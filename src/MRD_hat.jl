### MRD_hat
# estimate mean relative difference (MRD) between two sets of data

### Dependencies
#DataFrames, GLM,


function MRD_hat(out_df::DataFrame, outcome_model)
    
    out_df.treatment_first .= 0
    out_df.Y_0 .= predict(outcome_model, out_df)

    out_df.treatment_first .= 1
    out_df.Y_1 .= predict(outcome_model, out_df)

    n = nrow(out_df)

    MRD_hat = 1/n * sum(out_df.Y_1) - 1/n * sum(out_df.Y_0)

    return MRD_hat
end