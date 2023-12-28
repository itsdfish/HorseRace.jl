module HorseRace
    using Random
    using StatsBase 
    export Game
    export Horse
    export Dice 
    export Player 
    export play 
    export init_horses
    export deal!
    export roll
    export move!
    export no_winner
    export scratch!
    export simulate!
    export split_pot!
    export compute_payoff
    export get_winner
    export remove_cards!

    include("structs.jl")
    include("functions.jl")
end
