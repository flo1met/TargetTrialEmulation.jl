module TargetTrialEmulation

# depenencies
using DataFrames
using Arrow
using GLM
using StatsModel
using Distributions


# export
export  art_censor,
        convert_to_arrow,
        dict_to_df,
        IPCW,
        IPTW,
        ITT,
        seqtrial,
        TTE

# include
include("art_censor.jl")
include("convert_to_arrow.jl")
include("dict_to_df.jl")
include("IPCW.jl")
include("IPTW.jl")
include("ITT.jl")
include("seqtrial.jl")
include("TTE.jl")

end
