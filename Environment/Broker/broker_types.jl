# Immutable element type so StructArray gives SoA columns you mutate as b.accounts.cash[i]
struct Account
    trader_id::Int
    cash::Float64
    units::Float64             # signed net position; negative = short
    encumbered_cash::Float64   # reserved by resting bids
    encumbered_units::Float64  # reserved by resting asks
    wealth::Float64 # The equity value of the trader. They will start with some baseline value what will change overtime as they trade.
end

# A resting order the broker knows about, keyed by exchange-assigned order_id
struct OpenOrder
    order_id::Int
    trader_id::Int
    units::Float64             # remaining
    price::Float64
    side::Side
end

mutable struct Broker
    accounts::StructArray{Account}   # row i == trader_id i (IDs dense from 1)
    open_orders::Dict{Int, OpenOrder}
    allow_shorts::Bool
end