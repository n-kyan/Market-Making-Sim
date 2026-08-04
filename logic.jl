using StructArrays
using Random

function step_sim(exchange, traders::Vector{StructArray{<:Trader}}, rng::AbstractRNG)
    
    step_demand!(traders)
    orders = get_orders(traders)
    shuffle!(rng, orders)
    result_orders = send_orders!(exchange, orders)
    reconcile_portfolios!(exchange, traders, result_orders)
    
    return exchange.market_price
end

function step_demand!(ts::StructArray{<:Trader})

    step_size = 0.01

    for i in eachindex(ts)
    
        up = rand(Bool) # determines if the walk will move up or down by the step_size

        # Algorithm to randomly walk the demmand based on up.
        # Bounded to [0.0, 1.0] so demand can never be negative or greater than 1 since it is a proportion of wealth.
        if ts.demand[i] == 1.0
            if up
                new_demand = 1.0
            else
                new_demand = 1.0 - step_size
            end
        elseif ts.demand[i] == 0.0
            if up
                new_demand = 0.0 + step_size
            else
                new_demand = 0.0
            end
        else
            if up
                new_demand = ts.demand[i] + step_size
            else
                new_demand = ts.demand[i] - step_size
            end
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

function calc_net_units(p::Portfolio)
    for position in p.positions
        net_units += position.units
    end
end

function execute_strategy(StructArray{<:Trader{NaiveRebalance}}, e::Exchange)

    mp = e.market_price
    
    asset_order_amt = 0.0
    desired_asset_amt = (ts.wealth[i] * ts.demand[i]) / mp
    current_asset_amt = calc_net_units(ts.portfolio[i])

    if current_asset_amt[i] != desired_asset_amt[i]
        asset_order_amt[i] = desired_asset_amt[i] - ts.asset[i]
    end
    orders = Vector{MarketOrder}(t.trader_id[i], asset_order_amt[i], asset_order_amt[i] > 0 ? Bid : Ask)
end

function execute_strategy(ts::StructArray{<:Trader{NaiveMarketMake}}, e::Exchange)

    orders = Vector{LimitOrder}()

    units = 0.1 * ts.portfolio.cash[i]

    append!(orders, [LimitOrder(trader_id[i], units[i], Ask) for i in eachindex(ts)])
    append!(orders, [LimitOrder(trader_id[i], units[i], Bid) for i in eachindex(ts)])

    return orders
end

function get_orders(ts::Vector{StructArray{<:Trader}}, e::Exchange)

    orders = Vector{Order}()

    for trader_group in ts

    
        orders = execute_strategy(trader_group)
            
        
        # temporary print code to see how orders evolves over time
        println("Trader ID: $(ts.id[i])")
        println("Cash: $(ts.cash[i])")
        println("Asset: $(ts.asset[i])")
        
        println("Asset Demand: $(ts.demand[i])")
        println("Asset Order: $asset_order_amt")
        println()

        append!(orders, Order(ts.id[i], asset_order_amt))
        
    end
    return orders
end


function make_traders(num_traders::Int, strategy::NaiveRebalance)
    
    wealth = 100.0
    asset = 0.0
    cash = wealth - asset
    demand = 0.5

    traders = [Trader(i, wealth, asset, cash, demand, strategy) for i in 1:num_traders]
    
    return StructArray(traders)
end

function make_traders(num_traders::Int, strategy::NaiveMarketMake)
    
    wealth = 100.0
    asset = 0.0
    cash = wealth - asset
    demand = 0.0

    traders = [Trader(i, wealth, asset, cash, demand, strategy) for i in 1:num_traders]
    
    return StructArray(traders)
end

# Currently the trader can only make market orders
function process_order(e::Exchange, order::MarketOrder)

    return_orders = Vector{Order}()

    if order.side == Bid
        
        if isempty(e.asks)
            return return_orders
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
            append!(return_orders, process_order(remaining_market_order))

        else # full fill, full consumption
            units_traded = order.units
            
            # No need for further processing
        end 
        
        push!(return_orders, ResultOrder(order.trader_id, units_traded, best_ask.price))
        push!(return_orders, ResultOrder(best_ask.trader_id, -units_traded, best_ask.price))
        exchange.market_price = best_ask.price
        
    else # order.side = Ask

        if isempty(e.bids)
            return return_orders
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
            remaining_market_order = MarketOrder(order.trader_id, remaining_order_units, Bid)
            append!(return_orders, process_order(remaining_market_order))

        else # full fill, full consumption
            units_traded = order.units
            
            # No need for further processing
        end
        
        push!(return_orders, ResultOrder(order.trader_id, -units_traded, best_bid.price))
        push!(return_orders, ResultOrder(best_bid.trader_id, units_traded, best_bid.price))
        exchange.market_price = best_bid.price
    
    end

    return return_orders
end

# Currently limit orders are reserved for the trader that represents myself
function process_order(exchange::Exchange, order::LimitOrder)
    if order.type == Bid
        enqueue!(e.bids, order, order.price)
    else # oreder.type == Ask
        enqueue!(e.asks, order, order.price)

    # Will eventually need to add support to the case when two limit orders cross
end


function send_orders(exchange::Exchange, orders::Vector{Order})

    result_orderes = Vector{Order}()

    for order in orders
        append!(result_orderes, process_order(order))     
    end

    return result_orderes
end

# Will need to be updated when multiple assets are supported
function calc_wealth(p::Portfolio, market_price::Float64)
    cash = p.cash

    net_units = calc_net_units(p)

    return p.cash + (net_units * market_price)
    
end

function reconcile_portfolios(exchange::Exchange, traders::Trader, result_orders::Vector{ResultOrder})

    
    for order in result_orders
        t = traders[order.trader_id]
        push!(t.portfolio, Position(order.units, order.price)
        t.portfolio.cash -= order.units * order.price
        t.wealth = calc_wealth(t.portfolio, exchange.market_price)
    end
end