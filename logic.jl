using StructArrays
using Random

function step_sim(exchange::Exchange, traders::Vector{StructArray{<:Trader}}, rng::AbstractRNG)

    for trader_group in traders
        step_demand!(trader_group)
    end
    orders = get_orders(traders, exchange)
    shuffle!(rng, orders)
    result_orders = send_orders!(exchange, orders)
    update_positions!(exchange, traders, result_orders)

    return exchange.market_price
end

function step_demand!(ts::StructArray{<:Trader})

    step_size = 0.01

    for i in eachindex(ts)

        up = rand(Bool) # determines if the walk will move up or down by the step_size

        # Algorithm to randomly walk the demmand based on up.
        # Bounded to [0.0, 1.0] so demand can never be negative or greater than 1 since it is a proportion of wealth.

        if up
            new_demand = ts.demand[i] + step_size
        else # down
            new_demand = ts.demand[i] - step_size
        end

        if new_demand >= 1.0 || new_demand <= 0
            new_demand = clamp(new_demand, 0.0, 1.0)
        end
        ts.demand[i] = new_demand
    end
end


function step_demand!(ts::StructArray{<:Trader{NaiveMarketMake}})
    # do nothing
    return nothing
end

function calc_net_units(ps::StructArray{Position})
    net_units = 0.0
    for i in eachindex(ps)
        net_units += ps.units[i]
    end
    return net_units
end

function execute_strategy(tg::StructArray{<:Trader{NaiveRebalance}}, e::Exchange)

    mp = e.market_price
    orders = Vector{MarketOrder}()

    for i in eachindex(tg)

        desired_asset_amt = (tg.wealth[i] * tg.demand[i]) / mp
        current_asset_amt = calc_net_units(tg.positions[i])
        asset_order_amt = desired_asset_amt - current_asset_amt

        push!(orders, MarketOrder(tg.id[i], asset_order_amt, asset_order_amt > 0 ? Bid : Ask))

        # temporary print code to see how orders evolves over time
        println("Trader ID: $(tg.id[i])")
        println("positions: $(tg.positions[i])")
        println("Curr Asset Amt: $current_asset_amt")

        println("Asset Demand: $(tg.demand[i])")
        println("Asset Order: $asset_order_amt")
        println()

    end
    return orders
end

function execute_strategy(tg::StructArray{<:Trader{NaiveMarketMake}}, e::Exchange)

    orders = Vector{LimitOrder}()
    half_spread = e.market_price * 0.1

    for i in eachindex(tg)
        units = 0.1 * tg.cash[i]

        push!(orders, LimitOrder(tg.id[i], units, e.market_price + half_spread, Ask))
        push!(orders, LimitOrder(tg.id[i], units, e.market_price - half_spread, Bid))
    end
    return orders
end

function get_orders(ts::Vector{StructArray{<:Trader}}, e::Exchange)

    orders = Vector{AbstractOrder}()

    for trader_group in ts

        append!(orders, execute_strategy(trader_group, e))

    end
    return orders
end

# Will need to be updated when multiple assets are supported
function calc_wealth(t::Trader, market_price::Float64)

    net_units = calc_net_units(t.positions)

    return t.cash + (net_units * market_price)
end


function make_trader_group(id::Int, count::Int, strategy::NaiveRebalance)

    cash = 100.0
    wealth = cash
    demand = 0.5

    trader_group = Vector{Trader{NaiveRebalance}}()
    for i in 1:count
        positions = StructArray{Position}(undef, 0)
        push!(trader_group, Trader(id, strategy, wealth, demand, cash, positions))
        id += 1
    end
    return StructArray(trader_group)
end

function make_trader_group(id::Int, count::Int, strategy::NaiveMarketMake)

    cash = 100.0
    wealth = cash
    demand = 0.0

    trader_group = Vector{Trader{NaiveMarketMake}}()
    for i in 1:count
        positions = StructArray{Position}(undef, 0)
        push!(trader_group, Trader(id, strategy, wealth, demand, cash, positions))
        id += 1
    end
    return StructArray(trader_group)
end

function trader_factory(build_specs::Vector{Tuple{Int, <:AbstractStrategy}})
    traders = Vector{StructArray{<:Trader}}()
    id = 1

    for (count, strategy) in build_specs
        push!(traders, make_trader_group(id, count, strategy))
        id += count
    end
    return traders
end

# Currently the trader can only make market orders
function process_order!(e::Exchange, order::MarketOrder)

    result_orders = Vector{ResultOrder}()

    if order.side == Bid

        if isempty(e.asks)
            return result_orders
        end

        best_ask = dequeue!(e.asks) # min ask from min heap

        if order.units < best_ask.units # partial consumption
            units_traded = order.units
            remaining_book_units = best_ask.units - units_traded

            # Make a limit order to represent the remaining volume
            remaining_limit_order = LimitOrder(best_ask.trader_id, remaining_book_units, best_ask.price, Ask)
            enqueue!(e.asks, remaining_limit_order, remaining_limit_order.price)

        elseif order.units > best_ask.units # partial fill
            units_traded = best_ask.units
            remaining_order_units = order.units - units_traded

            # No need to make a limit order for remaining limit order volume since it was fully consumed
            # Rather, need to make a new market order with the remaining demand from the original market order
            remaining_market_order = MarketOrder(order.trader_id, remaining_order_units, Bid)
            append!(result_orders, process_order!(e, remaining_market_order))

        else # full fill, full consumption
            units_traded = order.units

            # No need for further processing
        end

        push!(result_orders, ResultOrder(order.trader_id, units_traded, best_ask.price))
        push!(result_orders, ResultOrder(best_ask.trader_id, -units_traded, best_ask.price))
        e.market_price = best_ask.price

    else # order.side = Ask

        if isempty(e.bids)
            return result_orders
        end

        best_bid = dequeue!(e.bids) # max bid from max heap

        if order.units < best_bid.units # partial consumption
            units_traded = order.units
            remaining_book_units = best_bid.units - units_traded

            # Make a limit order to represent the remaining volume
            remaining_limit_order = LimitOrder(best_bid.trader_id, remaining_book_units, best_bid.price, Bid)
            enqueue!(e.bids, remaining_limit_order, remaining_limit_order.price)

        elseif order.units > best_bid.units # partial fill
            units_traded = best_bid.units
            remaining_order_units = order.units - units_traded

            # No need to make a limit order for remaining limit order volume since it was fully consumed
            # Rather, need to make a new market order with the remaining demand from the original market order
            remaining_market_order = MarketOrder(order.trader_id, remaining_order_units, Ask)
            append!(result_orders, process_order!(e, remaining_market_order))

        else # full fill, full consumption
            units_traded = order.units

            # No need for further processing
        end

        push!(result_orders, ResultOrder(order.trader_id, -units_traded, best_bid.price))
        push!(result_orders, ResultOrder(best_bid.trader_id, units_traded, best_bid.price))
        e.market_price = best_bid.price

    end

    return result_orders
end

# Currently limit orders are reserved for the trader that represents myself
function process_order!(e::Exchange, order::LimitOrder)
    if order.side == Bid
        enqueue!(e.bids, order, order.price)
    else # order.side == Ask
        enqueue!(e.asks, order, order.price)
    end
    # Will eventually need to add support to the case when two limit orders cross
    return Vector{ResultOrder}()
end


function send_orders!(e::Exchange, orders::Vector{<:AbstractOrder})

    result_orders = Vector{ResultOrder}()

    for order in orders
        append!(result_orders, process_order!(e, order))
    end

    return result_orders
end


function update_positions!(e::Exchange, traders::Vector{StructArray{<:Trader}}, result_orders::Vector{ResultOrder})
    for order in result_orders
        for tg in traders
            i = findfirst(==(order.trader_id), tg.id)
            if i !== nothing
                push!(tg.positions[i], Position(order.units, order.price))
                tg.cash[i] -= order.units * order.price
                tg.wealth[i] = calc_wealth(tg[i], e.market_price)
                break
            end
        end
    end
end
