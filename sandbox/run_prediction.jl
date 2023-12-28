############################################################################################################
#                                         load packages
############################################################################################################
cd(@__DIR__)
using Pkg 
Pkg.activate("..")
using DataFrames
using Distributions
using HorseRace
using GLM
using Random
using Revise
using Plots 
using GLM 

function collect_data(game, player)
    x = fill(0.0, 6)
    for i ∈ 2:7
        j = 14 - i  
        x[i-1] += sum((i .== player.cards) .|| (j .== player.cards))
    end
    win_id = get_winner(game.horses)
    payoff = compute_payoff(game, player, win_id)
    push!(x, payoff)
    return x
end

function run_sim(;n_players)
    players = Dict(id => Player() for id ∈ 1:n_players)
    horses = init_horses()
    game = Game(;horses)
    deal!(players)
    scratch!(game, players)
    ids = shuffle!(collect(keys(players)))
    simulate!(game, players, ids)
    win_id = get_winner(horses)
    split_pot!(game, players, win_id)
    return map(p -> collect_data(game, p), values(players))
end
############################################################################################################
#                                         run simulation
###########################################################################################################
Random.seed!(5202)
n_players = 4
outcome = map(_ -> run_sim(;n_players), 1:10_000)
outcome = vcat(outcome...)
outcome = reduce(vcat, transpose.(outcome))
df = DataFrame(outcome, :auto)
cols = [string("h$h") for h ∈ 2:7]
push!(cols, "payoff")
rename!(df, cols)

model = @formula(payoff ~ h2 + h3 + h4 + h5 + h6 + h7)
ols = lm(model, df)