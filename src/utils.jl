function has_gap(seq::Vector{<:Integer})
    return any(diff(sort(seq)) .!= 1)
end

function newdata(newdata::DataFrame, max_fup::Int64)
    newdata = filter(row -> row.fup == 0, newdata)
    n_baseline = nrow(newdata)
    
    followup_times = 0:max_fup
    repeat!(newdata, inner = length(followup_times))
    newdata.fup = repeat(followup_times, outer = n_baseline)
    
    return newdata
end