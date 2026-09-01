using Random
# gr()

# Types
include("types.jl")
include("Exchange/exchange_types.jl")
include("Traders/trader_types.jl")

# Logic
include("Exchange/limit_order_book.jl")
include("Traders/noise_trading.jl")

include("logic.jl")

function main()

    # === Settings ===
    num_sim_steps = 10
    num_npc_traders = 1
    starting_market_price = 10.0
    trader_build_specs = [
        (1, NaiveMarketMake()),
        (num_npc_traders, NaiveRebalance())
        ]

    exchange = Exchange(starting_market_price)
    traders = trader_factory(trader_build_specs)
    # === End ==

    sim_meta_data = StructArray{MetaData}(undef, num_sim_steps)
    rng = Xoshiro(67)
    
    println("=== Starting Simulation ===")
    start = time_ns()
    for i in 1: num_sim_steps
        println("Sim Step $i")
        sim_meta_data[i] = step_sim(exchange, traders, rng)
    end
    elapsed = (time_ns() - start) /1e9
    println("=== Simulation Complete | $elapsed seconds elapsed ===")

    
    analyze_sim_metadata(sim_meta_data)
end

main()