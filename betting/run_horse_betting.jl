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

funcs = (max_hedge,max_hedge,max_hedge,max_ev)
money = 20.0
outcomes = map(_ -> sim_horse_bet(;n_players, funcs, money), 1:10000)
outcomes = reduce(vcat, outcomes')
mean(outcomes, dims = 1)