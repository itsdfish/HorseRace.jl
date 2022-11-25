############################################################################################################
#                                         load packages
############################################################################################################
cd(@__DIR__)
using Pkg 
Pkg.activate("..")
using Revise, Random, HorseRace
using Plots, Distributions 

function run_sim(;n_players, n_games)
    players = Dict(id => Player() for id ∈ 1:n_players)
    for _ ∈ 1:n_games
        horses = init_horses()
        game = Game(;horses)
        remove_cards!(players)
        deal!(players)
        scratch!(game, players)
        ids = shuffle!(collect(keys(players)))
        simulate!(game, players, ids)
        win_id = get_winner(horses)
        split_pot!(game, players, win_id)
    end
    return map(p -> p.money, values(players))
end
############################################################################################################
#                                         run simulation
###########################################################################################################
Random.seed!(65202)
n_players = 6
n_games = 1
outcome = map(_ -> run_sim(;n_players, n_games), 1:10_000)
outcome = vcat(outcome...)
############################################################################################################
#                                         plot results
###########################################################################################################
pyplot()
histogram(outcome, xlabel="winnings", ylabel="density", norm=true,
    leg=false, color = RGB(124/256, 161/256, 134/256),
    yaxis = font(12), xaxis =font(12), title = "1 game",
    size=(600,400), dpi=300)
savefig("payout_1_game.png")

σ1 = std(outcome)
f(σ, n) = sqrt(n * σ^2)
num_games = 2:8
σs = f.(σ1, num_games)
x = -30:.1:30
dens = map(σ -> pdf.(Normal(0, σ), x), σs)
dens = reduce(vcat, transpose.(dens))
labels = string.(num_games)
plot(x, dens', xlabel="winnings", ylabel="density",
    yaxis = font(12), xaxis = font(12), label = num_games',
    size=(600,400), dpi=300, legendtitle = "n games")
savefig("payout_n_games.png")
