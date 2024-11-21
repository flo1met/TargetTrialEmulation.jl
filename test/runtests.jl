using TargetTrialEmulation
using Test
using DataFrames
using CodecBzip2
using RData
using CSV
using GLM

test_df = CSV.read("../data/seq_emulated_data_censored.csv", DataFrame)
df = RData.load("../data/data_censored.rda")["data_censored"]
out_df = dict_to_df(seqtrial(df, [:x1, :x2, :x3, :x4, :age]))

#sort the dfs
out_df = sort(out_df, [:id, :trialnr])
test_df = sort(test_df, [:id, :trial_period])

@testset "sequential Target Trial Emulation" begin
    #compare the two dfs
    @test nrow(out_df) == nrow(test_df)
    @test out_df.id == test_df.id
    @test out_df.trialnr == test_df.trial_period
    @test isapprox(out_df.x1, test_df.x1, atol = 0.01)
    @test isapprox(out_df.x2, test_df.x2, atol = 0.01)
    @test isapprox(out_df.x3, test_df.x3, atol = 0.01)
    @test isapprox(out_df.x4, test_df.x4, atol = 0.01)
    @test out_df.age == test_df.age
    @test out_df.outcome == test_df.outcome
    @test out_df.baseline_treatment == test_df.assigned_treatment
    @test out_df.fup == test_df.followup_time
end

m_out = glm(@formula(outcome ~ x1 + x2 + x3 + x4 + age + baseline_treatment + fup + fup^2 + trialnr + trialnr^2), out_df, Binomial(), LogitLink())
m_test = glm(@formula(outcome ~ x1 + x2 + x3 + x4 + age + assigned_treatment + followup_time + followup_time^2 + trial_period + trial_period^2), test_df, Binomial(), LogitLink())

@testset "outcome model parameters" begin
    @test isapprox(coef(m_out), coef(m_test), atol = 0.0001)
end
