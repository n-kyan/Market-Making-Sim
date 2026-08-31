using DataStructures: next
using DataStructures


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
    