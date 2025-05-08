"""
    ITT(df::DataFrame)

Estimate intention-to-treat effect.

# Keyword Arguments

- `df::DataFrame`: DataFrame with columns `:id`, `:period`, `:eligible`, `:treatment`.

# Output

- `model`: GLM model.

# Example

"""

#### ITT: estimate intetion-to-treat effect

# necessary packages
#

## todo
# - add example (when the function is ready and example DF is created)

function ITT(df::DataFrame;
    id_var::Symbol,
    outcome::Symbol,
    treatment::Symbol,
    period::Symbol,
    eligible::Symbol,
    ipcw::Bool = false,
    censored::Union{Symbol,Nothing} = nothing,
    covariates::Array{Symbol,1},
    #model::String,
    save_w_model::Bool = false,
    use_arrow = false,
    save_BS = false)

    # apply weighting
    if ipcw == true
        if save_w_model == true
            df, model_num, model_denom = IPCW(df, covariates, save_w_model)
        else
            df = IPCW(df, covariates)
        end
    end

    # Emulate Trials
    cat_name = []
    for cov_cat in covariates
        if isa(df[!, cov_cat], CategoricalArray)
            push!(cat_name, cov_cat)
        end
    end

    

    ## convert to arrow
    if use_arrow == true
        df = convert_to_arrow(df, id_var)
    end

    ## emulate trials
    df = seqtrial(df, id_var, covariates)


    cat_name = ["$(cov)_first" for cov in cat_name] # add _first to each categorical covariate
    if !isempty(cat_name)
        for cov_cat in cat_name
            df[!, cov_cat] = CategoricalArray(df[!, cov_cat])
        end
    end

    if ipcw == true
        # set IPCW to 1 if fup == 0
        df[!, :IPCW] = ifelse.(df.fup .== 0, 1.0, df.IPCW)
        df = combine(groupby(df, [id_var, :trialnr]), All(), :IPCW => (x -> cumprod(x)) => :IPCW)
    end

    ## outcome model (ALWAYS ADJUST FOR COVARIATES)
    # create formula string
    # add _first to each covariate
    covariates = ["$(cov)_first" for cov in covariates]
    formula_string = "outcome ~ treatment_first + $(join(covariates, " + ")) + trialnr + (trialnr^2) + fup + (fup^2)"

    # fit model
    if ipcw == true
        out_model = glm(eval(Meta.parse("@formula $formula_string")), df, Binomial(), LogitLink(), wts = df.IPCW)
    else
        out_model = glm(eval(Meta.parse("@formula $formula_string")), df, Binomial(), LogitLink())        
    end

    if save_w_model == true
        return df, out_model, model_num, model_denom
    else
        return df, out_model
    end

end