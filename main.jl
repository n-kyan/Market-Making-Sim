using Random
using Plots
gr()

include("types.jl")
include("logic.jl")

function main()

    num_sim_steps = 10
    num_npc_traders = 1
    rng = Xoshiro(67)
    starting_market_price = 10.0
    exchange = Exchange(starting_market_price)

    trader_build_specs = [
        (1, NaiveMarketMake()),
        (num_npc_traders, NaiveRebalance())
        ]

    traders = trader_factory(trader_build_specs)

    sim_meta_data = StructArray{MetaData}(undef, num_sim_steps)
    
    println("=== Starting Simulation ===")
    for i in 1: num_sim_steps
        println("Sim Step $i")
        sim_meta_data[i] = step_sim(exchange, traders, rng)
    end
    println("=== Simulation Complete ===")

    
    analyze_sim_metadata(sim_meta_data)
end

main()