############################################################################################################
#                                         load packages
############################################################################################################
cd(@__DIR__)
using Pkg 
Pkg.activate("..")
using Revise, Random, HorseRace
using StatsBase, StatsPlots, DataFrames
############################################################################################################
#                                         define simulation
############################################################################################################
function race!()  
    horses = init_horses()
    ids = sample(2:12, 4, replace=false)
    map(id -> delete!(horses, id), ids)
    game = Game(;horses)
    rolls = 0
    while true   
        rolls += 1
        outcome = roll(game.dice)
        if outcome ∈ keys(horses)
            horse = game.horses[outcome]
            move!(horse)
            has_won(horse) ? (return outcome, rolls) : nothing
        end
    end
end
############################################################################################################
#                                         run simulation
############################################################################################################
Random.seed!(454)

results = map(_ -> race!(), 1:100_000)
winners = map(x -> x[1], results)
rolls = map(x -> x[2], results)
############################################################################################################
#                                         plot results
############################################################################################################
pyplot()

dice_rolls = map(x -> roll(game.dice), 1:100_000)
histogram(dice_rolls, xlabel="horse number", xticks = 2:12,
    ylabel="roll probability", normalize=:probability,
    leg=false, color = RGB(124/256, 161/256, 134/256),
    yaxis = font(12), xaxis =font(12),
    size=(600,400), dpi=300)
savefig("dice_roll.png")

histogram(winners, xlabel="horse number", xticks = 2:12,
    ylabel="win probability", normalize=:probability,
    leg=false, color = RGB(124/256, 161/256, 134/256),
    yaxis = font(12), xaxis =font(12),
    size=(600,400), dpi=300)
savefig("win_prob.png")

df = DataFrame(winners=winners, rolls=rolls)
moments = combine(groupby(df, :winners), :rolls => mean, :rolls => std)
df_half = filter(x -> x.winners ∉ [8:12;], df)
@df df_half histogram(:rolls, group=:winners, alpha=.7, norm=true,
    xlabel = "rolls to win", ylabel = "density",
    yaxis = font(12), xaxis =font(12), size=(600,400), dpi=300)
savefig("roll_distribution.png")

# nums = [3,6,8,11,14,17,14,11,8,6,3]
# Θ = nums ./ 32

# function joint(Θ, nums, win_idx, n)
#     prob = 1.0
#     for i ∈ 1:length(nums)
#         if i == win_idx
#             prob *= pdf(NegativeBinomial(nums[i], Θ[i]), n - nums[i])
#         else
#             prob *= 1 - cdf(NegativeBinomial(nums[i], Θ[i]), n - nums[i])
#         end
#     end
#     return prob
# end

# mapreduce(x -> joint(Θ, nums, 1, x), +, 3:1000)