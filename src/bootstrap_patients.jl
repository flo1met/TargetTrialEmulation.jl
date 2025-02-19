### bootsrap_patients


# dependencies 


## TODO
# 1. Add documentation
# 2. Add tests
# 3. add ID identifier in TTE function


```
Function BS Patients
```
function bootstrap_sample(df::DataFrame, id_col::Symbol)
    n = length(unique(df[!, id_col]))  # Number of unique IDs
    df_bs = DataFrame(
        bs_id = sample(unique(df[!, id_col]), n, replace=true),  # Sample IDs with replacement
        ID_new = 1:n  # Assign new sequential IDs
    )

    # Merge bootstrap IDs with the original dataset
    df_bootstrapped = innerjoin(df_bs, df, on=:bs_id => id_col)

    return df_bootstrapped
end

```
Function BS Point Estimate and Confint
```
function BS_CI(df::DataFrame, B, id_var::Symbol, covariates::Array{Symbol,1})
    # Estimate Point Estimate
    df_run = copy(df)
    df_new, out_model = TTE(df_run, 
        id_var = id_var,
        outcome = :outcome, 
        treatment = :treatment, 
        period = :period, 
        eligible = :eligible, 
        ipcw = true,
        censored = :censored,
        covariates = covariates, 
        save_w_model = false
    )

    MRD_hat_PE = MRD_hat(df_new, id_var, out_model)

    # Bootstrap
    ## Initialize dictionary of length of follow-up to store MRD_hat
    BS = [[MRD] for MRD in MRD_hat_PE.MRD_hat]

    ## BS loop
    for i in 2:B
        df_bs = bootstrap_sample(df, id_var)
        df_new, out_model = TTE(df_bs, 
            id_var = :ID_new,
            outcome = :outcome, 
            treatment = :treatment, 
            period = :period, 
            eligible = :eligible, 
            ipcw = true,
            censored = :censored,
            covariates = covariates, 
            save_w_model = false
        )

        MRD_hat_BS = MRD_hat(df_new, :ID_new, out_model)
        
        ## Append MRD_hat_BS to BS
        for i in 1:length(MRD_hat_BS.MRD_hat)
            append!(BS[i], MRD_hat_BS.MRD_hat[i])
        end
    end

    
    

    # Calculate CI
    MRD_hat_PE.CIlow .= 2 .* MRD_hat_PE.MRD_hat .- map(x -> quantile(x, 0.975), BS)
    MRD_hat_PE.CIhigh .= 2 .* MRD_hat_PE.MRD_hat .- map(x -> quantile(x, 0.025), BS)

    return MRD_hat_PE
end
