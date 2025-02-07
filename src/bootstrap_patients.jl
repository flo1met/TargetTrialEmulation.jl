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
        
        # todo: df_bs = df[shuffle(1:n), :] # sample n IDs with replacement ?
        # todo: enhance code, annotate
        df_bs = DataFrame() # initialize DF 

        df_bs.bs_id = sample(1:n, n, replace = true) # sample n IDs with replacement   
        df_bs.ID_new .= 1:n # new IDs

        df_bs_expanded = DataFrame()

        for (new_id, old_id) in zip(df_bs.ID_new, df_bs.bs_id)
            df_subset = df[df.id .== old_id, :]
            df_subset[!, :id_new] .= new_id
            append!(df_bs_expanded, df_subset)
        end
        
        # todo: save orig call, use this and set save_w_model = false
        # todo: df_new = df_bs_expanded
        
        df_new, out_model = TTE(df_bs_expanded, 
            outcome = :outcome, 
            treatment = :treatment, 
            period = :period, 
            eligible = :eligible, 
            ipcw = true,
            censored = :censored,
            covariates = [:x1, :x2, :x3, :x4, :age], 
            save_w_model = false
        )

        push!(MRD_B, MRD_hat(df_new, out_model))
    end

    CI = [2*mean(MRD_B) - quantile(MRD_B, 0.975), 2*mean(MRD_B) - quantile(MRD_B, 0.025)]

    return CI   
end