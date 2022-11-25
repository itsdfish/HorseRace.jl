using SafeTestsets

@safetestset "deal" begin
    using HorseRace
    using Test
    n_players = 4
    players = Dict(id => Player() for id ∈ 1:n_players) 
    deal!(players)
    for (id,p) ∈ players 
        @test length(p.cards) == 11
    end
end

@safetestset "scratch!" begin
    using HorseRace
    using Test
    n_players = 4
    players = Dict(id => Player() for id ∈ 1:n_players) 
    horses = init_horses()
    game = Game(;horses)
    deal!(players)
    scratch!(game, players)
    for i ∈ 1:4 
        money = game.units * i 
        horse = filter(h -> h.money == money, collect(values(horses)))
        @test length(horse) == 1
    end
end

@safetestset "split_pot!" begin
    using HorseRace
    using Test
    n_players = 3
    players = Dict(id => Player() for id ∈ 1:n_players) 
    horses = init_horses()
    game = Game(;horses)
    players[1].cards = [1]
    players[2].cards = [1,1,1]
    players[3].cards = [3]
    game.pot = 12.0
    win_id = 1
    split_pot!(game, players, win_id)

    @test players[1].money == 3
    @test players[2].money == 9
    @test players[3].money == 0
end

@safetestset "exchange!" begin
    using HorseRace
    using Test
    using HorseRace: exchange!

    n_players = 3
    players = Dict(id => Player() for id ∈ 1:n_players) 
    horses = init_horses()
    game = Game(;horses)
    money = 3.0

    @test game.pot == 0
    @test players[1].money == 0

    exchange!(game, players[1], money)
    @test game.pot == money
    @test players[1].money == -money
end

@safetestset "simulate!" begin
    using HorseRace
    using Test
    using Random
    
    n_players = 4
    players = Dict(id => Player() for id ∈ 1:n_players) 
    horses = init_horses()
    game = Game(;horses)
    deal!(players)
    scratch!(game, players)
    ids = shuffle!(collect(keys(players)))
    simulate!(game, players, ids)
    win_id = get_winner(horses)
    @test win_id ∈ [2:12;]
end