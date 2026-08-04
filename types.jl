using DataStructures
using StructArrays

# Abstract strategy struct that will be the parent of all strategy types.
abstract type AbstractStrategy end
struct NaiveRebalance <: AbstractStrategy end
struct NaiveMarketMake <: AbstractStrategy end

struct Position
    # sid::Int # security identifier, for use when there are multiple assets
    units::Float64 # number of units acquired
    price::Float64 # per unit price at which the position was acquired
end

struct Portfolio
    # for now positions are never removed from the portfolio but are just canceled out by new posittions.
    # This is just one less thing to implement for me and also could be useful for post sim analysis
    cash::Float64
    positions::Vector{Position}
end

# The general purpose Trader struct. All market participants will be traders including the market marker who I control.
struct Trader{S <: AbstractStrategy}
    id::Int
    strategy::S # A placeholder for the strategy that the trader will be assigned at instantiation. Will take a strategy struct of its own type that is a sub-type of AbstractStrategy as a parameter when instantiation.
    portfolio::Portfolio
    wealth::Float64 # The equity value of the trader. They will start with some baseline value what will change overtime as they trade.
    demand::Float64 # The traders demand for the security at time t. Currently evolves over time to follow a random walk.
end

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
    units::Float64
    price::Float64
    side::Side
end

struct ResultOrder <: Order
    trader_id::Int
    units_change::Float64 # how the trader's position should change
    price::Float64 # price at which the trade occured
end

struct Exchange
    asks::PriorityQueue{LimitOrder, Float64}
    bids::PriorityQueue{LimitOrder, Float64}
    market_price::Float64
end

Exchange() = Exchange(
    PriorityQueue{LimitOrder, Float64}(),
    PriorityQueue{LimitOrder, Float64}(Base.Order.Reverse)
)
