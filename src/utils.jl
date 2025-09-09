
```
Checks for gaps in a sequence of integers, used to see if there are missing time points.
```
function has_gap(seq::Vector{<:Integer})
    return any(diff(sort(seq)) .!= 1)
end

function newdata(newdata::DataFrame, max_fup::Union{Int64,Int32})
    newdata = filter(row -> row.fup == 0, newdata)
    n_baseline = nrow(newdata)
    
    followup_times = 0:max_fup
    repeat!(newdata, inner = length(followup_times))
    newdata.fup = repeat(followup_times, outer = n_baseline)
    
    return newdata
end


# add check, add warning, add error
```
Function to check if the necessary columns are in the dataframe. Not implemented in wrapper functions yet.
```
function check_data(df::DataFrame, id_var::Symbol, outcome::Symbol, treatment::Symbol, period::Symbol, eligible::Symbol, censored::Union{Symbol,Nothing})
    if id_var ∉ names(df)
        error("The id variable is not in the data.")
    end
    if outcome ∉ names(df)
        error("The outcome variable is not in the data.")
    end
    if treatment ∉ names(df)
        error("The treatment variable is not in the data.")
    end
    if period ∉ names(df)
        error("The period variable is not in the data.")
    end
    if eligible ∉ names(df)
        error("The eligible variable is not in the data.")
    end
    if !isnothing(censored) && censored ∉ names(df)
        error("The censored variable is not in the data.")
    end
end

function check_covariates(df::DataFrame, covariates::Array{Symbol,1})
    for cov in covariates
        if cov ∉ names(df)
            error("The covariate $cov is not in the data.")
        end
    end
end

# add check, add warning, add error


```
Drops missing from columns with Union{T, Missing} type if there are no missing values. Was necessary during the simulation study, as missing type (when there were no missings in the variable) in variables caused issues with some functions.
```
function drop_missing_union!(df::DataFrame)
    for col in names(df)
        # Check if the column type is Union{T, Missing}
        eltype(df[!, col]) <: Union{Missing, Any} || continue
        
        # If the column has no missing values, convert it to its non-missing type
        if !any(ismissing, df[!, col])
            df[!, col] = convert(Vector{nonmissingtype(eltype(df[!, col]))}, df[!, col])
        end
    end
    return df
end