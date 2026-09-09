

function publish_snapshot(e::Exchange)
	return MarketSnapshot(e.market_price, e.lob.asks, e.lob.bids)
end

function process_order!(lob::LimitOrderBook, o::LimitOrder)

    execution_reports = Vector{ReportOrder}()

	if o.side == Bid
	    price_book = lob.asks
	else # o.side == Ask
	    price_book = lob.bids
	end

	while o.units > 0
	    price_level = get_best_price_level(price_book)
		if price_level == nothing break end
		if !crosses_spread(price_level, o) break end

		while (price_level.head != nothing) && (o.units > 0)
            maker_order = price_level.head.order

            units_traded = min(curr_order.units, o.units)
            push!(execution_reports,
                TradeReport(
                    maker_order.trader_id,
                    o.trader_id,
                    units_traded,
                    price_level.price,
                    maker.side
                )
            )

            o = LimitOrder(o, -units_traded)
            price_level.head.order = LimitOrder(maker_order, -units_traded)

            if maker_order.units == 0.0
                remove_order!(maker_order)
            end
        end

        if isempty(price_level)
            delete!(price_book, price_level.price)
        end
    end

    if o.units > 0
        insert_order!(lob, o)
    end

    return execution_reports
end

function handle_orders!(e::Exhange, orders::LimitOrder)

    execution_reports = Vector{TradeReports}()

    for order in orders
        append!(execution_reports, process_order!(e.lob, order))
    end

    return execution_reports
end

function receive_orders(e::Exchange, orders::Vector{LimitOrder})

    execution_reports = Vector{ExecutionReport}()

    for order in orders
        append!(execution_reports , process_order!(e.lob, order))
    end


end
