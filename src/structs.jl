struct Dice 
    n::Int 
    sides::Int 
end

function Dice(;n=2, sides=6)
    return Dice(n, sides)
end

mutable struct Horse
    max_steps::Int 
    steps::Int 
    scratched::Bool 
    money::Float64
end

function Horse(;steps=0, max_steps, scratched=false)
    return Horse(max_steps, steps, scratched, 0.0)
end

mutable struct Player
    money::Float64
    cards::Vector{Int}
end

function Player(;money=0.0, cards = Int[])
    return Player(money, cards)
end

mutable struct Game{T} 
    dice::Dice 
    pot::Float64
    units::Float64
    horses::Dict{T,Horse}
end

function Game(; pot=0.0, dice=Dice(), units=.25, horses)
    return Game(dice, pot, units, horses)
end

