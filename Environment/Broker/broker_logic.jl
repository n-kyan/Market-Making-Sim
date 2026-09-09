function initialize_account(b::Broker, t::Trader{NaiveMarketMake})
    cash = 100.0
    wealth = cash
    return Account(t.id, cash, 0.0, 0.0, 0.0, wealth)
end

function initialize_account(b::Broker, t::Trader{NaiveRebalance})
    cash = 100.0
    wealth = cash
    return Account(t.id, cash, 0.0, 0.0, 0.0, wealth)
end

function open_accounts!(b::Broker, ts::Vector{StructArrau{<:Trader}})

    accounts = Vector{Account}
    
    for trader_group in ts
        for t in trader_group
            push!(accounts, initialize_account(b, t))
        end
    end

    return StructArray(accounts)
end

function passes_order_gateway(a::Account, o::LimitOrder)

    is_valid = false

    if o.side == Bid
	    if (a.cash - a.encumbered_cash) >= (o.units * o.price)
			is_valid = true
        end  

	else # o.side == Ask
        if (a.units - a.encumbered_units) >= (o.units)
            is_valid = true
        end  
	end
end

function validate_orders(b::Broker, raw_orders::Vector{LimitOrder})

    valid_orders = Vector{LimitOrder}()
    id = 1
    for o in raw_orders
        account = b.accounts[o.trader_id]
        
        if passes_order_gateway(account, o)
            o.order_id = id
            id += 1
            push!(valid_orders, o)
        end
    end
    return valid_orders
end

function reconcile_portfolios(b::Broker, ::trade_reports)
	
end


row(b::Broker, trader_id::Int) = trader_id            # dense IDs; change here if that stops holding

available_cash(b, id)  = b.accounts.cash[row(b,id)]  - b.accounts.encumbered_cash[row(b,id)]
available_units(b, id) = b.accounts.units[row(b,id)] - b.accounts.encumbered_units[row(b,id)]
position(b, id)        = b.accounts.units[row(b,id)]
wealth(b, id)          = b.accounts.wealth[row(b,id)]