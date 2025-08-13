-------- 
SELECT *
FROM public.thread_supplierproduct
WHERE expected_code = '014570'
ORDER BY id ASC LIMIT 100
;

--------- Main SQL -------
SELECT DISTINCT
--     data.sku AS sku Will cause duplicates
	ti.shop_title
	,pr.category_title
	,pr.title --- Select the most frquent used title by SKU
	,DATE((ti.transacted_at at time zone 'UTC') at time zone 'Australia/Melbourne') as transacted_date
	,ti.price_sell
	,ROUND(AVG(ti.total_margin),2) AS AVG_Margin
	,ROUND(AVG(ti.price_sell - ti.total_margin),2) AS AVG_Cost
    ,COALESCE(SUM(ti.quantity), 0) AS total
--     string_agg(DISTINCT lookup_product_id::text, ',') AS lookup_product_id --- Join all EK together
FROM (
	---- Product table
    SELECT DISTINCT
        tp.thread_id AS thread_id,
        tp.sku AS sku,
        COALESCE(tp.title, '--------') AS title,
        tp.equivalent_key AS lookup_product_id
    FROM thread_product tp
	
    -- We use `thread_equivalent_lookup` to filter out soft deleted products
    JOIN thread_equivalent_lookup tel 
		ON 	tel.id = tp.thread_id 
			AND tel.thread_type = 'product' 
			AND tel.deleted_at IS NULL
    WHERE
        -- Only get products that are in the Reddrop group
        tp.shop_id IN 
			(
            SELECT *
            FROM get_shop_ids_in_group(('8114733b-10fc-4c6e-861e-dba80714607c')::UUID)
        	)
		AND
		tp.title IN
					(
					'STR M/P MAGNUM CLASS  4S 428ML 0.428l'
					,'COCA COLA 1.25l'
					,'BEST BUY FULL CREAM MILK 2l'
					,'PAS M/MALLOWS VAN/RSPBRY 0.28kg'
					)
	) data

-- Join with transaction items to get the total sales.
-- We use LEFT JOIN to include products that have not been sold to lets us use COALESCE and set the total to 0.
INNER JOIN 
	(
	----- Transaction Table
    SELECT 	*
    FROM transaction_items_partitioned
    WHERE
        -- We use the timezone this way cos `transacted_at` is stored in UTC and this doesn't require us to convert the date range causing a full table scan
        -- TODO - Change this to the date range you want to look at
        transacted_at BETWEEN (('2022-11-01 00:00:00+10:00'::timestamptz) AT TIME ZONE 'UTC')::timestamp 
						  AND (('2023-10-31 23:59:59+10:00'::timestamptz) AT TIME ZONE 'UTC')::timestamp
        -- Exclude voided and returned transactions
        AND is_returned <> TRUE
        AND is_void <> TRUE
        -- Filter by Reddrop group
--         AND shop_id IN 
-- 			(
-- 			'065643c9-48f9-4ed9-bd65-3bf821f6dfcb' --'Mansfield FoodWorks'
--         	)
		AND product_title IN
						   				(
										'STR M/P MAGNUM CLASS  4S 428ML 0.428l'
										,'COCA COLA 1.25l'
										,'BEST BUY FULL CREAM MILK 2l'
										,'PAS M/MALLOWS VAN/RSPBRY 0.28kg'
						   				)
-- 		AND category_title IN
-- 			(
-- 			'200 - SOFT DRINKS'
-- 			,'201 - SOFT DRINKS, BOTTLED'
-- 			,'202 - SOFT DRINKS, CANNED'
-- 			,'207 - SOFT DRINKS, SINGLE'
-- 			,'208 - SOFT DRINKS, MIXERS'
-- 			,'1491 - SOFT DRINKS & MIXERS'
-- 			,'SOFT DRINKS'
-- 			,'SOFT DRINKS, BOTTLED'
-- 			,'SOFT DRINKS, CANNED'
-- 			,'SOFT DRINKS, MIXERS'
-- 			,'SOFT DRINKS, SINGLE'
-- 			,'SOFT DRINKS & MIXERS'
-- 			,'190 - MILK AND CREAM'
-- 			,'191 - MILKS POWDERED'
-- 			,'192 - MILKS AND CREAM CANN'
-- 			,'047 - FRESH MILK FLAVOURED'
-- 			,'047 - MILK FRESH, FLAVOURE'
-- 			,'076 - MILK, FRESH'
-- 			,'MILK FRESH, FLAVOURE'
-- 			,'MILK, FRESH'
-- 			,'MILK AND CREAM'
-- 			,'MILKS AND CREAM CANN'
-- 			,'MILKS POWDERED'
-- 			,'140 - CONFECTIONERY'
-- 			,'141 - CONFECTIONERY'
-- 			,'141 - CONFECTIONERY, CHEWI'
-- 			,'148 - CONFECTIONERY'
-- 			,'CONFECTIONERY'
-- 			)
	) ti 
	ON ti.product_id = data.thread_id

---- Select the most frquent used category_title by SKU
INNER JOIN 
	(
    SELECT
		sku AS sku
		,MODE() within GROUP (ORDER BY title DESC) AS title --- Select the most frquent used title by SKU
		,category_title

    FROM thread_product tp
	INNER JOIN
		(
			SELECT 	product_id
					,MODE() within GROUP (ORDER BY category_title DESC) AS category_title
			FROM transaction_items_partitioned
			WHERE
				-- We use the timezone this way cos `transacted_at` is stored in UTC and this doesn't require us to convert the date range causing a full table scan
				-- TODO - Change this to the date range you want to look at
				transacted_at BETWEEN (('2022-11-01 00:00:00+10:00'::timestamptz) AT TIME ZONE 'UTC')::timestamp 
								  AND (('2023-10-31 23:59:59+10:00'::timestamptz) AT TIME ZONE 'UTC')::timestamp
				-- Exclude voided and returned transactions
				AND is_returned <> TRUE
				AND is_void <> TRUE
				-- Filter by Reddrop group
-- 				AND shop_id IN 
-- 					(
-- 					'065643c9-48f9-4ed9-bd65-3bf821f6dfcb', -- Mansfield
-- 					'2f87a805-5002-4933-b532-3c9c2baa7ee5', -- Ripponlea Grocer
-- 					'90aab575-bfa1-41c6-a875-a8a1cc5367d0', -- East Ivanhoe FoodWorks
-- 					'b1b9d92f-ee82-4aeb-8d98-fb6cf1ea77e3', -- Brighton Grocer
-- 					'c705bdb7-1e55-4f61-b4dc-b845147ad9e7' -- Griffith FoodWorks
-- 					)
				AND product_title IN
						   				(
										'STR M/P MAGNUM CLASS  4S 428ML 0.428l'
										,'COCA COLA 1.25l'
										,'BEST BUY FULL CREAM MILK 2l'
										,'PAS M/MALLOWS VAN/RSPBRY 0.28kg'
						   				)
-- 				AND category_title IN
-- 					(
-- 					'200 - SOFT DRINKS'
-- 					,'201 - SOFT DRINKS, BOTTLED'
-- 					,'202 - SOFT DRINKS, CANNED'
-- 					,'207 - SOFT DRINKS, SINGLE'
-- 					,'208 - SOFT DRINKS, MIXERS'
-- 					,'1491 - SOFT DRINKS & MIXERS'
-- 					,'SOFT DRINKS'
-- 					,'SOFT DRINKS, BOTTLED'
-- 					,'SOFT DRINKS, CANNED'
-- 					,'SOFT DRINKS, MIXERS'
-- 					,'SOFT DRINKS, SINGLE'
-- 					,'SOFT DRINKS & MIXERS'
-- 					,'190 - MILK AND CREAM'
-- 					,'191 - MILKS POWDERED'
-- 					,'192 - MILKS AND CREAM CANN'
-- 					,'047 - FRESH MILK FLAVOURED'
-- 					,'047 - MILK FRESH, FLAVOURE'
-- 					,'076 - MILK, FRESH'
-- 					,'MILK FRESH, FLAVOURE'
-- 					,'MILK, FRESH'
-- 					,'MILK AND CREAM'
-- 					,'MILKS AND CREAM CANN'
-- 					,'MILKS POWDERED'
-- 					,'140 - CONFECTIONERY'
-- 					,'141 - CONFECTIONERY'
-- 					,'141 - CONFECTIONERY, CHEWI'
-- 					,'148 - CONFECTIONERY'
-- 					,'CONFECTIONERY'
-- 					)
			GROUP BY 1
		) ti
		ON ti.product_id = tp.thread_id
    WHERE
        -- Only get products that are in the Reddrop group
        tp.shop_id IN 
			(
            SELECT *
            FROM get_shop_ids_in_group(('8114733b-10fc-4c6e-861e-dba80714607c')::UUID)
        	)
	GROUP BY 1, 3
	) pr 
	ON pr.sku = data.sku
-- Group by SKU
GROUP BY 1,2,3,4,5
-- Sort by total sales
ORDER BY 1,2,3,4 ASC
;
