




# Abstract strategy struct that will be the parent of all strategy types.
abstract type AbstractStrategy end

struct NaiveRebalance <: AbstractStrategy
    demand::Float64 # The traders demand for the security at time t. Currently evolves over time to follow a random walk.
end

struct NaiveMarketMake <: AbstractStrategy

end

# The general purpose Trader struct. All market participants will be traders including the market marker who I control.
struct Trader{S <: AbstractStrategy}
    id::Int
    strategy::S # A placeholder for the strategy that the trader will be assigned at instantiation. Will take a strategy struct of its own type that is a sub-type of AbstractStrategy as a parameter when instantiation.
    wealth::Float64 # The equity value of the trader. They will start with some baseline value what will change overtime as they trade.
    cash::Float64
    units::Float64
end