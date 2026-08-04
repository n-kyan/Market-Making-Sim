using Random
using Plots
gr()

include("types.jl")
include("logic.jl")

function main()

    num_sim_steps = 10
    num_npc_traders = 1
    rng = Xoshiro(67)
    exchange = Exchange()
    traders = Vector{StructArray{<:Trader}}
    # order_log = Vector{Vector{Order}}()
    starting_market_price = 10.0
    market_price_log = Vector{Float64}(starting_market_price)
    
    append!(traders, make_traders(num_npc_traders, NaiveRebalance()))
    append!(traders, make_traders(1, NaiveMarketMake()))

    
    println("=== Starting Simulation ===")
    for i in 1: num_sim_steps
        println("Sim Step $i")
        push!(market_price_log, step_sim(exchange, traders, rng))
    end
    println("=== Simulation Complete ===")

    plot(market_price_log)
end

main()