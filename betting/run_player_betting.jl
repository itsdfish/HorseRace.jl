############################################################################################################
#                                         load packages
############################################################################################################
cd(@__DIR__)
using Pkg 
Pkg.activate("..")
using Revise, Random, HorseRace
using Plots, Distributions, GLM
using DataFrames
include("functions.jl")
############################################################################################################
#                                         run simulation
###########################################################################################################
Random.seed!(52023)
n_players = 6
outcome = map(_ -> run_sim(;n_players), 1:10_000)
outcome = vcat(outcome...)
outcome = reduce(vcat, transpose.(outcome))
df = DataFrame(outcome, :auto)
cols = [string("h$h") for h ∈ 2:7]
push!(cols, "payoff")
rename!(df, cols)

model = @formula(payoff ~ h2 + h3 + h4 + h5 + h6 + h7)
ols = lm(model, df)

funcs = (guess,rank_approx)
money = 20.0
outcomes = map(_ -> sim_player_bet(;n_players, funcs, ols, money), 1:10000)
outcomes = reduce(vcat, outcomes)
mean(outcomes, dims = 1)