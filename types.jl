using DataStructures
using StructArrays
using Base.Order: ForwardOrdering, ReverseOrdering

# Contains all metadata from a sim step to be returned back to main to be used for analysis
struct MetaData
    time_elapsed::Float64
    market_price::Float64
    sample_traders::Vector{Trader} # one trader from each trader group to be representative of the group. Should probably be changed to be a statistical representation of each group.
end


# Abstract strategy struct that will be the parent of all strategy types.
abstract type AbstractStrategy end
struct NaiveRebalance <: AbstractStrategy end
struct NaiveMarketMake <: AbstractStrategy end

struct Position
    # sid::Int # security identifier, for use when there are multiple assets
    units::Float64 # number of units acquired
    price::Float64 # per unit price at which the position was acquired
end

# The general purpose Trader struct. All market participants will be traders including the market marker who I control.
struct Trader{S <: AbstractStrategy}
    id::Int
    strategy::S # A placeholder for the strategy that the trader will be assigned at instantiation. Will take a strategy struct of its own type that is a sub-type of AbstractStrategy as a parameter when instantiation.
    wealth::Float64 # The equity value of the trader. They will start with some baseline value what will change overtime as they trade.
    demand::Float64 # The traders demand for the security at time t. Currently evolves over time to follow a random walk.
    cash::Float64

    # for now positions are never removed from the portfolio but are just canceled out by new posittions.
    # This is just one less thing to implement for me and also could be useful for post sim analysis
    positions::StructArray{Position}
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

struct ResultOrder <: AbstractOrder
    trader_id::Int
    units::Float64 # how many units the trader's position should change by
    price::Float64 # price at which the trade occured
end

mutable struct Exchange
    asks::PriorityQueue{LimitOrder, Float64, ForwardOrdering}
    bids::PriorityQueue{LimitOrder, Float64, ReverseOrdering{ForwardOrdering}}
    market_price::Float64
end

Exchange(starting_market_price::Float64) = Exchange(
    PriorityQueue{LimitOrder, Float64}(),
    PriorityQueue{LimitOrder, Float64}(Base.Order.Reverse),
    starting_market_price
)
