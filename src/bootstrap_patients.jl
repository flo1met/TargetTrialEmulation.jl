### bootsrap_patients


# dependencies 


## TODO
# 1. Add documentation
# 2. Add tests
# 3. add ID identifier in TTE function


```
Function BS Patients
```
function bootstrap_sample(df::DataFrame, id_var::Symbol)
    n = length(unique(df[!, id_var]))  # Number of unique IDs
    df_bs = DataFrame(
        bs_id = sample(unique(df[!, id_var]), n, replace=true),  # Sample IDs with replacement
        ID_new = 1:n  # Assign new sequential IDs
    )

    # Merge bootstrap IDs with the original dataset
    df_bootstrapped = innerjoin(df_bs, df, on=:bs_id => id_var)

    return df_bootstrapped
end

```
Function BS Point Estimate and Confint
```
function BS_CI(df::DataFrame, B::Int64, MRD_hat_PE, args)
    id_var = args[:id_var]
    save_BS = args[:save_BS]
    failed_iterations = 0

    # Bootstrap
    ## Initialize list of vectors of length of follow-up to store MRD_hat
    BS = [[MRD] for MRD in MRD_hat_PE[!, :MRD_hat]]

    ## BS loop
    for i in 1:B
        print("\rIteration: ", i, "/", B) # log iteration
        flush(stdout)

        try
            df_bs = bootstrap_sample(df, id_var)
            args[:id_var] = :ID_new # overwrite id_var with new ID
            df_new, out_model = ITT(df_bs; args...)

            MRD_hat_BS = MRD_hat(df_new, :ID_new, out_model)

            ## Append MRD_hat_BS to BS
            ### Save length of vector for each follow-up time? To see the "real amount" of BS samples
            for i in 1:length(MRD_hat_BS.MRD_hat)
                append!(BS[i], MRD_hat_BS.MRD_hat[i])
            end

        catch e
            failed_iterations += 1
            @warn "Bootstrap iteration $i failed with error: $e"
        end

    end
        
        if failed_iterations > 0
            @warn "$failed_iterations out of $B bootstrap iterations failed. For more informations see the warning messages."
        end


    
    

    # Calculate CI
    MRD_hat_PE.CIlow_emp .= 2 .* MRD_hat_PE.MRD_hat .- map(x -> quantile(x, 0.975), BS)
    MRD_hat_PE.CIhigh_emp .= 2 .* MRD_hat_PE.MRD_hat .- map(x -> quantile(x, 0.025), BS)
    MRD_hat_PE.BS_PE = map(x -> mean(x), BS)
    MRD_hat_PE.CIlow_pct .= map(x -> quantile(x, 0.025), BS)
    MRD_hat_PE.CIhigh_pct .= map(x -> quantile(x, 0.975), BS)
    #MRD_hat_PE.CI = confint(BS[1], BCaConfInt(0.95)) # BCa CI for first follow-up time

    if save_BS == true
        return MRD_hat_PE, BS
    else
        return MRD_hat_PE
    end
end



```
Bias Corrected and Accelerated Confidence Intervals
```
function BCa(df::DataFrame, B::Int64, MRD_hat_PE, args)
    
end