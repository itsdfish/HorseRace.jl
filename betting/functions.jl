function collect_data(game, player)
    x = indicator(player)
    win_id = get_winner(game.horses)
    payoff = compute_payoff(game, player, win_id)
    push!(x, payoff)
    return x
end

function indicator(player)
    x = fill(0.0, 6)
    for i ∈ 2:7
        j = 14 - i  
        x[i-1] += sum((i .== player.cards) .|| (j .== player.cards))
    end
    return x
end

function run(;n_players)
    players = Dict(id => Player() for id ∈ 1:n_players)
    horses = init_horses()
    game = Game(;horses)
    deal!(players)
    scratch!(game, players)
    ids = shuffle!(collect(keys(players)))
    simulate!(game, players, ids)
    return game,players
end

function run_sim(;n_players)
    game,players = run(;n_players)
    return map(p -> collect_data(game, p), values(players))
end

function sim_player_bet(;n_players, funcs, kwargs...)
    game,players = run(;n_players)
    bets = fill(0.0, length(players), length(funcs))
    for (i,f) ∈ enumerate(funcs) 
        f(game, players, bets, i; kwargs...)
    end
    win_id = get_winner(game.horses)
    winnings = fill(0.0, length(players))
    for (i,p) ∈ players 
        winnings[i] = compute_payoff(game, p, win_id)
    end
    total_bet = sum(bets)
    win_prop = winnings ./ game.pot 
    bet_prop = bets ./ sum(bets, dims=2)
    replace!(x -> isnan(x) ? 0.0 : x, bet_prop)
    # println("bets $(DataFrame(bets,:auto))")
    # println("winnings $winnings")
    return sum(bet_prop .* win_prop * total_bet, dims=1)
end

function rank_approx(game, players, bets, id; ols, money, kwargs...)
    preds = fill(0.0, length(players))
    labels = map(s -> string("h$s"), 2:7)
    for (v,p) ∈ players
        x = indicator(p)
        df = DataFrame(x', :auto)
        rename!(df, labels)
        preds[v] = predict(ols, df)[1]
    end
    idx = sortperm(preds, rev=true)
    n = 2
    for i ∈ 1:n
        bets[idx[i],id] = money / n
    end
    return nothing 
end

function guess(game, players, bets, id;  money, kwargs...)
    n = length(players)
    for i ∈ 1:n
        bets[i,id] = money / n
    end
    # i = rand(1:n)
    # bets[i,id] = money
    return nothing 
end

function sim_horse_bet(;n_players, funcs, kwargs...)
    game,players = run(;n_players)
    bets = fill(0.0, 12, length(funcs))
    for (i,f) ∈ enumerate(funcs) 
        f(game, bets, i; kwargs...)
    end
    win_id = get_winner(game.horses)
    total_bet = sum(bets)
    bet_prop = bets[win_id,:] ./ sum(bets[win_id,:])
    # println("bets $(DataFrame(bets,:auto))")
    # println("winnings $winnings")
    return bet_prop * total_bet
end

function max_hedge(game, bets, id;  money, kwargs...)
    n = 0
    for (k,h) ∈ game.horses
        if !h.scratched
            n += 1
            bets[k,id] = money
        end
    end
    bets[:,id] ./= n
    return nothing 
end

function max_ev(game, bets, id;  money, kwargs...)
    horses = game.horses
    if !horses[2].scratched
        bets[2,id] = money
    elseif !horses[12].scratched
        bets[12,id] = money
    elseif !horses[4].scratched
        bets[4,id] = money
    elseif !horses[10].scratched 
        bets[10,id] = money
    elseif !horses[3].scratched
        bets[3,id] = money
    elseif !horses[11].scratched 
        bets[11,id] = money
    end
    return nothing
end