------------------------- Cost from the deal tables, 3 mins --------------------------------------
SELECT DISTINCT
	tsp.title AS Store,
    ts.title AS Supplier,
    tc.title AS Category,
	t.equivalent_key AS EQK,
    tp.title AS Product,
-- 	tp.sku, Will cause duplicates
    tp.unit_price AS Price_Product,
    tp.unit_price_cost AS Cost_Normal,
    td.title AS Deal_Title,
    td.price AS Cost_Deal,
	COALESCE(td.price, tp.unit_price_cost) AS Fixed_Cost,
    td.minimum_qty,
    td.event_start,
    td.event_end
FROM thread_product tp -- Start at Product
JOIN view_active_thread v ON v.id = tp.id  -- Ensure Active
JOIN public.thread t on t.id = tp.id
JOIN relationships rshp 
		ON (rshp.child_id, rshp.child_type, rshp.parent_type) 
		= (tp.id, tp.thread_type, 'shop') 
		AND
        rshp.parent_id IN (	-- All store
							SELECT *
            				FROM get_shop_ids_in_group(('8114733b-10fc-4c6e-861e-dba80714607c')::UUID)
-- 							'065643c9-48f9-4ed9-bd65-3bf821f6dfcb', -- Mansfield
-- 						   	'2f87a805-5002-4933-b532-3c9c2baa7ee5', -- Ripponlea Grocer
-- 							'90aab575-bfa1-41c6-a875-a8a1cc5367d0', -- East Ivanhoe FoodWorks
-- 							'b1b9d92f-ee82-4aeb-8d98-fb6cf1ea77e3', -- Brighton Grocer
-- 							'c705bdb7-1e55-4f61-b4dc-b845147ad9e7' -- Griffith FoodWorks
						  )  -- Shop Filter
JOIN relationships rbp ON (rbp.child_id, rbp.child_type, rbp.parent_type) 
							= (tp.id, tp.thread_type, 'baseproduct')
						   -- Product Title Filter
                           AND tp.title IN
						   				(
							   			'STR M/P MAGNUM CLASS  4S 428ML 0.428l'
										,'COCA COLA 1.25l'
										,'BEST BUY FULL CREAM MILK 2l'
										,'PAS M/MALLOWS VAN/RSPBRY 0.28kg'
						   				)
JOIN thread_shop tsp 
	ON tsp.id = rshp.parent_id -- Step to Supplier
JOIN relationships rc 
	ON (rc.child_id, rc.child_type, rc.parent_type) = (tp.id, tp.thread_type, 'category')
JOIN thread_category tc 
	ON tc.id = rc.parent_id 
	-- Category Filter
-- 		AND tc.title IN	(
-- 						'200 - SOFT DRINKS'
-- 						,'201 - SOFT DRINKS, BOTTLED'
-- 						,'202 - SOFT DRINKS, CANNED'
-- 						,'207 - SOFT DRINKS, SINGLE'
-- 						,'208 - SOFT DRINKS, MIXERS'
-- 						,'1491 - SOFT DRINKS & MIXERS'
-- 						,'SOFT DRINKS'
-- 						,'SOFT DRINKS, BOTTLED'
-- 						,'SOFT DRINKS, CANNED'
-- 						,'SOFT DRINKS, MIXERS'
-- 						,'SOFT DRINKS, SINGLE'
-- 						,'SOFT DRINKS & MIXERS'
-- 						,'190 - MILK AND CREAM'
-- 						,'191 - MILKS POWDERED'
-- 						,'192 - MILKS AND CREAM CANN'
-- 						,'047 - FRESH MILK FLAVOURED'
-- 						,'047 - MILK FRESH, FLAVOURE'
-- 						,'076 - MILK, FRESH'
-- 						,'MILK FRESH, FLAVOURE'
-- 						,'MILK, FRESH'
-- 						,'MILK AND CREAM'
-- 						,'MILKS AND CREAM CANN'
-- 						,'MILKS POWDERED'
-- 						,'140 - CONFECTIONERY'
-- 						,'141 - CONFECTIONERY'
-- 						,'141 - CONFECTIONERY, CHEWI'
-- 						,'148 - CONFECTIONERY'
-- 						,'CONFECTIONERY'
-- 						)
JOIN thread_baseproduct tbp 
		ON tbp.id = rbp.parent_id  -- Step to Base Product
JOIN relationships rpd 
	ON (rpd.child_id, rpd.child_type, rpd.parent_type) = (tbp.id, tbp.thread_type, 'deal')
JOIN thread_deal td 
		ON td.id = rpd.parent_id 
		AND NOW() BETWEEN td.event_start AND td.event_end  -- Step to Deal
JOIN relationships rs 
		ON (rs.child_id, rs.child_type, rs.parent_type) = (td.id, td.thread_type, 'supplier')
JOIN thread_supplier ts 
		ON ts.id = rs.parent_id -- Step to Supplier
ORDER BY tsp.title
;
