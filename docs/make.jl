using Documenter, TargetTrialEmulation, DataFrames

makedocs(
    modules = [TargetTrialEmulation],
    sitename = "TargetTrialEmulation.jl Documentation",
    authors = "Florian Metwaly"
)

deploydocs(
    repo = "github.com/flo1met/TargetTrialEmulation.jl.git",
)