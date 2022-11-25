function deal!(players)
    deck = repeat(2:12, inner=4)
    shuffle!(deck)
    ids = shuffle!(collect(keys(players)))
    while true 
        for id ∈ ids 
            card = pop!(deck)
            push!(players[id].cards, card)
            isempty(deck) ? (return nothing) : nothing
        end
    end
end

function remove_cards!(players)
    for (id,p) ∈ players
        empty!(p.cards)
    end
    return nothing 
end

function scratch!(game, players)
    (;units,horses) = game
    Θ = [1,2,3,4,5,6,5,4,3,2,1] / 32
    ids = sample(2:12, Weights(Θ), 4, replace=false)
    for i ∈ 1:4
        money = i * units 
        id = ids[i]
        horses[id].scratched = true
        horses[id].money = money
        for (k,p) ∈ players 
            if has_card(p, id)
                exchange!(game, p, money)
            end
        end
    end 
end

function roll(dice)
    return sum(rand(1:dice.sides, dice.n))
end

function move!(horse)
    horse.steps += 1
    return nothing 
end

function no_winner(horse)
    return horse.steps ≠ horse.max_steps
end

function get_winner(horses)
    for (id,h) ∈ horses 
        !no_winner(h) ? (return id) : nothing 
    end
    return 0 
end

function split_pot!(game, players, win_id)
    for (k,p) ∈ players 
        c = sum(p.cards .== win_id)
        p.money += (c / 4) * game.pot
    end
end

function init_horses()
    _max_steps = [3,6,8,11,14,17,14,11,8,6,3]
    ids = 2:12
    return Dict(id => Horse(;max_steps) for (id,max_steps) ∈ zip(ids,_max_steps))
end 

function count(horse, card)
    return count(x -> x == card, horse.cards)
end

function has_card(player, card)
    return card ∈ player.cards
end    

function exchange!(game, player, money)
    player.money -= money
    add_to_pot!(game, money)
    return nothing
end

function add_to_pot!(game, money)
    game.pot += money 
    return nothing 
end

function simulate!(game, players, ids)
    racing = true
    while racing
        racing = play_round(game, players, ids)
    end
end

function play_round(game, players, ids)
    racing = true
    for id ∈ ids 
        racing = play(game, players[id])
        !racing ? (return racing) : nothing
    end
    return racing
end

function play(game, player)
    outcome = roll(game.dice)
    horse = game.horses[outcome]
    if horse.scratched
        exchange!(game, player, horse.money)
    else 
        move!(horse)
    end
    return no_winner(horse)
end