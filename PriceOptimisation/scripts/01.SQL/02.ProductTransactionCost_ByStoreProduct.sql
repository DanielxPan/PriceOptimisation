
------------------------- Cost from the most recent txn, 35 mins --------------------------------------

WITH Prod_Max_Date AS
(
		--- Join the last txn date from transaction_items
		SELECT DISTINCT
			max_dates.Store,
			max_dates.Product,
			tti.product_id,
			tti.updated_at AS last_txn,
			tti.price_sell - tti.price_margin AS Cost_Txn
		FROM txn_thread_transaction_items tti
		JOIN (
			
		--- Find the last txn date from transaction_items
				SELECT
					p.Store,
					p.Product,
					tti.product_id,
					MAX(updated_at) AS max_updated_at
				FROM txn_thread_transaction_items tti
				JOIN 
				--- Join active products from the targeted shop
					(
					SELECT DISTINCT 
						tsp.title AS Store,
						tp.id AS product_id
						,tp.title AS Product
					FROM thread_product tp
					JOIN view_active_thread t ON t.id = tp.id  -- Ensure Active
					JOIN relationships rshp 
							ON (rshp.child_id, rshp.child_type, rshp.parent_type) 
							= (tp.id, tp.thread_type, 'shop') 
							AND
							rshp.parent_id IN (
												SELECT *
            									FROM get_shop_ids_in_group(('8114733b-10fc-4c6e-861e-dba80714607c')::UUID)
-- 												'065643c9-48f9-4ed9-bd65-3bf821f6dfcb', -- Mansfield
-- 												'2f87a805-5002-4933-b532-3c9c2baa7ee5', -- Ripponlea Grocer
-- 												'90aab575-bfa1-41c6-a875-a8a1cc5367d0', -- East Ivanhoe FoodWorks
-- 												'b1b9d92f-ee82-4aeb-8d98-fb6cf1ea77e3', -- Brighton Grocer
-- 												'c705bdb7-1e55-4f61-b4dc-b845147ad9e7' -- Griffith FoodWorks
											)  -- Shop Filter
					JOIN thread_shop tsp 
						ON tsp.id = rshp.parent_id -- Step to Supplier
						
						WHERE tp.title IN
						   				(
							   			'STR M/P MAGNUM CLASS  4S 428ML 0.428l'
										,'COCA COLA 1.25l'
										,'BEST BUY FULL CREAM MILK 2l'
										,'PAS M/MALLOWS VAN/RSPBRY 0.28kg'
						   				)

					) p ON tti.product_id = p.product_id
				WHERE 
					updated_at BETWEEN ('2022-11-01'::timestamp) AND ('2023-10-31'::timestamp)
					AND is_returned <> TRUE
					AND is_void <> TRUE
				GROUP BY 1,2,3
			) max_dates ON 
				tti.product_id = max_dates.product_id 
			AND tti.updated_at = max_dates.max_updated_at			
)

SELECT	DISTINCT
		pmd.Store,
		pmd.Product
		,pmd.Cost_Txn
FROM Prod_Max_Date pmd
JOIN 
--- Find the last txn date by title
	(
	SELECT DISTINCT
					Store,
					Product,
					MAX(last_txn) AS last_txn
	FROM Prod_Max_Date
	GROUP BY 1,2
	) pd ON 
				pmd.Product = pd.Product 
			AND pmd.last_txn = pd.last_txn
			AND  pmd.Store = pd.Store
;
