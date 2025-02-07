module TargetTrialEmulation

"""
    TargetTrialEmulation.jl

A Julia package for performing target trial emulation. Provides tools for sequential target trial emulation,
inverse propensity weighting, artificial censoring, and more.
"""

# depenencies
using DataFrames
using Arrow
using GLM
using StatsModels
using Distributions
using CategoricalArrays
using StatsBase


# export
export  art_censor,
        convert_to_arrow,
        dict_to_df,
        IPCW,
        IPTW,
        ITT,
        seqtrial,
        TTE,
        bootstrap_patients,
        MRD_hat

# include
include("art_censor.jl")
include("convert_to_arrow.jl")
include("dict_to_df.jl")
include("IPCW.jl")
include("IPTW.jl")
include("ITT.jl")
include("seqtrial.jl")
include("TTE.jl")
include("bootstrap_patients.jl")
include("MRD_hat.jl")

end
