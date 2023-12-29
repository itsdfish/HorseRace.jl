############################################################################################################
#                                         load packages
############################################################################################################
cd(@__DIR__)
using Pkg 
Pkg.activate("..")
using DataFrames
using Distributions
using Flux 
using HorseRace
using Random
using Revise
using Plots 

function collect_data(game, player)
    x = zeros(Float32, 6)
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
outcome = map(_ -> run_sim(;n_players), 1:100_000)
outcome = vcat(outcome...)
outcome = hcat(outcome...)
train_x = outcome[1:6,:]
train_y = outcome[end,:]'
train_data = Flux.Data.DataLoader((train_x, train_y), batchsize=5_000)
###################################################################################################
#                                        Create Network
###################################################################################################
# 6 nodes in input layer, 3 hidden layers, 1 node for output layer
model = Chain(
    Dense(6, 5, tanh),
    Dense(5, 5, tanh),
    Dense(5, 1, identity)
)

# loss function
loss_fn(a, b) = Flux.huber_loss(model(a), b) 

# optimization algorithm 
opt = ADAM(0.001)

n_epochs = 100
train_loss = zeros(n_epochs)
test_loss = zeros(n_epochs)

for i ∈ 1:n_epochs
    Flux.train!(loss_fn, Flux.params(model), train_data, opt)
    train_loss[i] = loss_fn(train_x, train_y)
end

plot(train_loss)