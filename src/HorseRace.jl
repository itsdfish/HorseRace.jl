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
    export scratch!
    export simulate!
    export split_pot!
    export get_winner
    export remove_cards!

    include("structs.jl")
    include("functions.jl")
end
