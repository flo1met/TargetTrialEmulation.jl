## todo: change rda to text file
## todo: !!are types of variables being contained!!
## todo: minimal df to test?


using TargetTrialEmulation
using Test
using DataFrames
using CSV
using GLM
using CategoricalArrays

test_df = CSV.read("../data/data_censored_sequential.csv", DataFrame)
df = CSV.read("../data/data_censored.csv", DataFrame)

df[!, :x1] = categorical(df.x1)
df[!, :x2] = Vector{Float64}(df.x2)
df[!, :x3] = categorical(df.x3)
df[!, :x4] = Vector{Float64}(df.x4)
df[!, :age] = Vector{Int64}(df.age)
df[!, :outcome] = Vector{Int64}(df.outcome)
df[!, :treatment] = Vector{Int64}(df.treatment)
df[!, :period] = Vector{Int64}(df.period)
df[!, :eligible] = Vector{Int64}(df.eligible)
df[!, :censored] = Vector{Int64}(df.censored)

out_df = seqtrial(df, :id, [:x1, :x2, :x3, :x4, :age])

#sort the dfs
out_df = sort(out_df, [:id, :trialnr])
test_df = sort(test_df, [:id, :trial_period])

#### todo fix tests for cat array vs errors
@testset "sequential Target Trial Emulation" begin
    #compare the two dfs
    @test nrow(out_df) == nrow(test_df)
    @test out_df.id == test_df.id
    @test out_df.trialnr == test_df.trial_period
    # @test isapprox(out_df.x1_first, test_df.x1, atol = 0.01)
    @test isapprox(out_df.x2_first, test_df.x2, atol = 0.01) # cat array vs vector
    # @test isapprox(out_df.x3_first, test_df.x3, atol = 0.01)
    @test isapprox(out_df.x4_first, test_df.x4, atol = 0.01) # cat array vs vector
    @test out_df.age_first == test_df.age
    @test out_df.outcome == test_df.outcome
    @test out_df.treatment_first == test_df.assigned_treatment
    @test out_df.fup == test_df.followup_time
end
# R outcome model test
m_out = glm(@formula(outcome ~ x1_first + x2_first + x3_first + x4_first + age_first + treatment_first + fup + fup^2 + trialnr + trialnr^2), out_df, Binomial(), LogitLink())
m_test = glm(@formula(outcome ~ x1 + x2 + x3 + x4 + age + assigned_treatment + followup_time + followup_time^2 + trial_period + trial_period^2), test_df, Binomial(), LogitLink())

## todo: add test for SEs
@testset "outcome model parameters" begin
    @test isapprox(coef(m_out), coef(m_test), atol = 0.0001)
end


##  seqtrial
## IPCW
## integration test


### create seperate test file
# test censoring models

## test agaisnt weight vector

# test if weights are the same
## test with TTE function

df = CSV.read("../data/data_censored.csv", DataFrame)

out_df_wts, out_model = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = true,
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    save_w_model = false,
    estimate_surv = false
)

@testset "IPCW" begin
    @test isapprox(test_df.weight, out_df_wts.IPCW, atol = 0.0001)
end




    #### stays here
## test if variable types are contained when running the function
## define colum types in the begining of the test
## copy x3 as num and treat as num 
@testset "Variable Type" begin
    @test out_df.x1 isa CategoricalVector{Int64}
    @test out_df.x1_first isa CategoricalVector{Int64}
    @test typeof(out_df.x2) == Vector{Float64}
    @test typeof(out_df.x2_first) == Vector{Float64}
    @test typeof(out_df.x3) == CategoricalArray{Int64, 1, UInt32, Int64, CategoricalValue{Int64, UInt32}, Union{}}
    @test typeof(out_df.x3_first) == CategoricalArray{Int64, 1, UInt32, Int64, CategoricalValue{Int64, UInt32}, Union{}}
    @test typeof(out_df.x4) == Vector{Float64}
    @test typeof(out_df.x4_first) == Vector{Float64}
    @test typeof(out_df.age) == Vector{Int64}
    @test typeof(out_df.age_first) == Vector{Int64}
    @test typeof(out_df.outcome) == Vector{Int64}
    @test typeof(out_df.treatment) == Vector{Int64}
    @test typeof(out_df.treatment_first) == Vector{Int64}
    @test typeof(out_df.period) == Vector{Int64}
    @test typeof(out_df.eligible) == Vector{Int64}
    @test typeof(out_df.censored) == Vector{Int64}
end

####### TODO: 
# import models from R output




