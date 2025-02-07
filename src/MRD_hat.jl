### MRD_hat
# estimate mean relative difference (MRD) between two sets of data

### Dependencies
#DataFrames, GLM,


function MRD_hat(out_df::DataFrame, outcome_model)
    
```
When using the predict function and I have a DF that has an observation at timepoint 1 and 5, will it correctl predict the 
    (__cumulative__) outcome probability at timepoint 5?
```

    out_df.treatment_first .= 0
    out_df.Y_0 .= 1 .- predict(outcome_model, out_df)

    out_df.treatment_first .= 1
    out_df.Y_1 .= 1 .- predict(outcome_model, out_df)

    # cumulative product per trial and ID (cumulative hazard)
    group = groupby(out_df, [:trialnr, :id])
    transform!(group, [:Y_0, :Y_1] .=> cumprod, renamecols=false)

    # 1- mean??
    MRD_hat = mean(out_df.Y_1) - mean(out_df.Y_0)

    return MRD_hat
end