-- SELECT * FROM `olist_project.orders` LIMIT 10;

-- SELECT
--   o.order_id,
--   o.customer_id,
--   c.customer_unique_id,
--   o.order_purchase_timestamp,
--   p.payment_value
-- FROM `olist_project.orders` o
-- LEFT JOIN `olist_project.payments` p ON o.order_id = p.order_id
-- LEFT JOIN `olist_project.customers` c ON o.customer_id = c.customer_id
-- WHERE o.order_status = 'delivered'
-- LIMIT 20;

CREATE OR REPLACE VIEW `olist_project.olist_rfm_base` AS
SELECT
  o.order_id,
  c.customer_unique_id,
  o.order_purchase_timestamp,
  SUM(p.payment_value) AS total_order_value
FROM `olist_project.orders` o
LEFT JOIN `olist_project.payments` p ON o.order_id = p.order_id
LEFT JOIN `olist_project.customers` c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY o.order_id, c.customer_unique_id, o.order_purchase_timestamp;

CREATE OR REPLACE VIEW `olist_project.olist_rfm_calc` AS
WITH customer_rfm AS (
  SELECT
    customer_unique_id,
    DATE('2018-09-01') AS analysis_date, -- Snapshot date (after latest order)
    DATE(MAX(order_purchase_timestamp)) AS last_order_date,
    COUNT(DISTINCT order_id) AS frequency,
    SUM(total_order_value) AS monetary
  FROM `olist_project.olist_rfm_base`
  GROUP BY customer_unique_id
)

SELECT
  customer_unique_id,
  analysis_date,
  last_order_date,
  -- Calculate Recency (days since last order)
  DATE_DIFF(analysis_date, last_order_date, DAY) AS recency,
  frequency,
  monetary
FROM customer_rfm;

-- SELECT * 
-- FROM `olist_project.olist_rfm_calc` 
-- LIMIT 10;

CREATE OR REPLACE VIEW `olist_project.olist_rfm_scores` AS
SELECT
  customer_unique_id,
  recency,
  frequency,
  monetary,
  -- Lower recency is better, so we sort ASC (smallest days = highest score)
  NTILE(4) OVER (ORDER BY recency ASC) AS recency_score,
  -- Higher frequency is better, so we sort DESC
  NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_score,
  -- Higher monetary is better, so we sort DESC
  NTILE(4) OVER (ORDER BY monetary DESC) AS monetary_score
FROM `olist_project.olist_rfm_calc`;

-- SELECT * 
-- FROM `olist_project.olist_rfm_scores` 
-- LIMIT 20;

CREATE OR REPLACE VIEW `olist_project.olist_rfm_total` AS
SELECT
  *,
  -- Combine scores (e.g., '4-3-4' means Recency=4, Frequency=3, Monetary=4)
  CONCAT(CAST(recency_score AS STRING), '-', 
         CAST(frequency_score AS STRING), '-', 
         CAST(monetary_score AS STRING)) AS rfm_total_score
FROM `olist_project.olist_rfm_scores`;


CREATE OR REPLACE TABLE `olist_project.olist_rfm_segments` AS
SELECT
  *,
  CASE 
    -- Champions: Best customers who buy recently and often
    WHEN recency_score = 4 AND frequency_score >= 3 THEN 'Champions'
    
    -- Loyal: Great customers who need a little attention
    WHEN recency_score >= 3 AND frequency_score >= 2 THEN 'Loyal Customers'
    
    -- Promising: New or one-time buyers with potential
    WHEN recency_score >= 3 AND frequency_score = 1 THEN 'Promising'
    
    -- Need Attention: Used to buy regularly but slowing down
    WHEN recency_score = 2 AND frequency_score >= 3 THEN 'Need Attention'
    
    -- At Risk: Were great but haven't bought recently
    WHEN recency_score = 1 AND frequency_score >= 3 THEN 'At Risk'
    
    -- Cannot Lose Them: Big spenders who haven't bought recently
    WHEN recency_score = 1 AND monetary_score >= 3 THEN 'Cannot Lose Them'
    
    -- Lost: Inactive customers with low historical value
    WHEN recency_score = 1 AND frequency_score = 1 THEN 'Lost'
    
    -- Hibernating: Inactive but might return
    WHEN recency_score = 2 AND frequency_score = 1 THEN 'Hibernating'
    
    -- Everything else
    ELSE 'Other'
  END AS customer_segment
FROM `olist_project.olist_rfm_total`;

SELECT 
  customer_segment,
  COUNT(*) AS customer_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM `olist_project.olist_rfm_segments`
GROUP BY customer_segment
ORDER BY customer_count DESC;
