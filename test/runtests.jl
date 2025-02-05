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

df[!, :x1] = CategoricalVector(df.x1)
df[!, :x3] = CategoricalVector(df.x3)

out_df = seqtrial(df, [:x1, :x2, :x3, :x4, :age])

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

# test censoring models
df_out, model, model_num, model_denom = TTE(df, 
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = true,
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    save_w_model = true
    )

## test if variable types are contained when running the function
@testset "Variable Type" begin
    @test typeof(df_out.x1_first) == CategoricalArray{Int64, 1, UInt32, Int64, CategoricalValue{Int64, UInt32}, Union{}}
    @test typeof(df_out.x2) == Vector{Float64}
    @test typeof(df_out.x3) == CategoricalArray
    @test typeof(df_out.x4) == Vector
    @test typeof(df_out.age) == Vector
    @test typeof(df_out.outcome) == Vector
    @test typeof(df_out.treatment) == Vector
    @test typeof(df_out.period) == Vector
    @test typeof(df_out.eligible) == Vector
    @test typeof(df_out.censored) == Vector
    @test typeof(df_out.w) == Vector
    @test typeof(df_out.w_model) == Vector
    @test typeof(model) == GLM.GeneralizedLinearModel
    @test typeof(model_num) == GLM.GeneralizedLinearModel
    @test typeof(model_denom) == GLM.GeneralizedLinearModel
end

####### TODO: 
# import models from R output




