using DataStructures: next
using DataStructures

struct Fill # for when a trade happens sucessfully
    t::Int
    trader_id::Int
    units::Float64
    price::Float64
end

struct ExecutionReport # for when an order is processed sucessfully
    got_filled::Bool
    cost_basis::Float64
    units::Float64
end

mutable struct LimitOrderNode
    order::LimitOrder
    prev::Union{LimitOrderNode, Nothing}
    next::Union{LimitOrderNode, Nothing}
end
    
mutable struct PriceLevel
    price::Float64
    head::Union{LimitOrderNode, Nothing}
    tail::Union{LimitOrderNode, Nothing}
    total_volume::Float64

    PriceLevel(price) = new(price, nothing, nothing, 0)
end

mutable struct LimitOrderBook

    asks::SortedDict{Float64, PriceLevel}
    bids::SortedDict{Float64, PriceLevel, Base.Order.Reverse}
    orders::Dict{Int, LimitOrderNode}
    
end

mutable struct Exchange

    lob::LimitOrderBook
    market_price::Float64
    fill_log::StructArray{Fill}

    Exchange(starting_market_price) = new(
        LimitOrderBook(),
        starting_market_price
    )
end





fills = StructArray{Fill}(undef, 0)


struct MarketSnapshot

    last_trade_price::Float64
    asks::SortedDict{Float64, PriceLevel}
    bids::SortedDict{Float64, PriceLevel, Base.Order.Reverse}
    
end