### bootsrap_patients


# dependencies 


## TODO
# 1. Add documentation
# 2. Add tests
# 3. add ID identifier in TTE function

function bootstrap_patients(df::DataFrame, B, id_var::Symbol)
    #initialize MRD_B 
    MRD_B = []

    unique_ids = unique(df[!, id_var]) # get unique IDs

    n = length(unique_ids) # number of unique IDs -> n

    for i in 1:B
        
        df_bs = DataFrame() # initialize DF 

        df_bs.bs_id = sample(1:n, n, replace = true) # sample n IDs with replacement   
        df_bs.ID_new .= 1:n # new IDs

        df_new = leftjoin(df_bs, df, on = [:bs_id => ID])

        TTE(df_new, outcome, treatment, period, eligible, censored, covariates, save_w_model = false)

        MRD_B[i] = MRD_hat(df_new, out_model)
    end

    CI = [2*mean(MRD_B) - quantile(MRD_B, 0.975), 2*mean(MRD_B) - quantile(MRD_B, 0.025)]

    return CI   
end