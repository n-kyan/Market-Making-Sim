using DataStructures: level
using DataStructures
using StructArrays

function insert_order!(lob::LimitOrderBook, o::LimitOrder)

    price_book = lob.bids ? o.side == Bid : lob.asks

    level = price_book[o.price]
    
    if price_level.head == nothing
        price_level.head = LimitOrderNode(o, nothing, nothing)
        price_level.tail = price_level.head
    else
        price_level.tail.next = LimitOrderNode(o, price_level.tail, nothing)
    end
end

function edit_order!(o::LimitOrder, new_units=o.units, new_price=o.price)

    if new_units < o.units && new_price == o.price
        o = LimitOrder(o.trader_id, o.order_id, new_units, o.price, o.side)
    else
        delete!(price_level, o.price)
        insert!(price_level, LimitOrder(o.trader_id, nothing, new_units, new_price, o.side))
    end
	return nothing
end

function get_best_price_level(price_book::SortedDict)
    if isempty(price_book)
        level = nothing
    else
        price, level = first(price_book)
    return level
end

function crosses_spread(level::PriceLevel, o::LimitOrder)

    if o.side == Bid
	    if level.price > o.price return false
		else return true
		end
	else # o.side == Ask
        if level.price < o.price return false
        else return true
        end
end

function process_order!(lob::LimitOrderBook, o::LimitOrder)

    trades = Vector{ReportOrder}()

	if o.side == Bid
	    price_book = lob.asks
	else # o.side == Ask
	    price_book = lob.bids

	while o.units > 0
	    price_level = get_best_price_level(price_book)
		if price_level == nothing break end
		if !crosses_spread(price_level, o) break end

		while (price_level.head != nothing) and (o.units > 0)
            maker_order = level.head.order

            units_traded = min(curr_order.units, o.units)
            push!(trades,
                TradeReport(
                    maker_order.trader_id,
                    o.trader_id,
                    units_traded,
                    price_level.price,
                    maker.side
                )
            )

            o = LimitOrder(o, -units_traded)
            maker_order = LimitOrder(maker_order, -units_traded)

            if maker_order.units == 0.0
                remove_order!(maker_order)
            end
        end
        
        if is.empty(price_level)
            delete!(price_book, price_level.price)
        end
    end

    if o.units > 0
        insert_order!(lob, o)
    end

    return trades