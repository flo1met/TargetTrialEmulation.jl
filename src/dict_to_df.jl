#### dict_to_df
## TODO check if more efficient by using dict keys instead of trialnr variable

function dict_to_df(dict::Dict)
    return vcat(values(dict)...) # combine all DFs in dict
end