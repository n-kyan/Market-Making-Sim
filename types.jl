using DataStructures
using StructArrays

# Orders
@enum Side Bid Ask
abstract type AbstractOrder end

struct MarketOrder <: AbstractOrder
    trader_id::Int
    units::Float64 # units of the security desired
    side::Side
end

struct LimitOrder <: AbstractOrder
    trader_id::Int
    order_id::Union{Int, Nothing}
    units::Float64
    price::Float64
    side::Side

    LimitOrder(o::LimitOrder, change_in_units) = new(o.trader_id, order_id, o.units + units_aquired, o.price, o.side)
end

struct TradeReport
    maker_id::Int
    taker_id::Int
    units::Float64 # how many units the trader's position should change by
    price::Float64 # price at which the trade occured
    maker_side::Side
    TradeReport(trader_id) = new(trader_id, nothing, 0, 0)
end



# Contains all metadata from a sim step to be returned back to main to be used for analysis
struct MetaData
    time_elapsed::Float64
    market_price::Float64
    sample_traders::Vector{Trader} # one trader from each trader group to be representative of the group. Should probably be changed to be a statistical representation of each group.
end