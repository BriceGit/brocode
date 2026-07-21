-- Contexte : Projet RFM (Olist) — calcul de la Récence par client
-- Utilisée le : jour projet SQL, semaine 3 wagon 2321

WITH recency_data AS (
  SELECT
    c.customer_unique_id,
    -- Écart en jours entre la commande la plus récente du dataset et la dernière commande du client
    DATE_DIFF(
      (SELECT MAX(DATE(order_purchase_timestamp)) FROM `global-sun-501608-b1.olist.olist_orders`),
      MAX(DATE(o.order_purchase_timestamp)),
      DAY
    ) AS recency_days
  FROM `global-sun-501608-b1.olist.olist_orders` AS o
  INNER JOIN `global-sun-501608-b1.olist.olist_customers` AS c
    ON o.customer_id = c.customer_id
  -- WHERE o.order_status = 'delivered' -----> Essayer avec et sans. Cela doit être un choix conscient et doit être expliqué en méthodologie lors de la présentation d'analyse.
  GROUP BY c.customer_unique_id
),

recency_segmented AS (
  SELECT
    customer_unique_id,
    recency_days,
    CASE
      WHEN NTILE(4) OVER (ORDER BY recency_days DESC) = 4 THEN 'R4_Very_Recent'
      WHEN NTILE(4) OVER (ORDER BY recency_days DESC) = 3 THEN 'R3_Recent'
      WHEN NTILE(4) OVER (ORDER BY recency_days DESC) = 2 THEN 'R2_Late'
      WHEN NTILE(4) OVER (ORDER BY recency_days DESC) = 1 THEN 'R1_Inactive'
    END AS cat_recency
  FROM recency_data
)

-- On joint la récence avec ta table précédemment sauvegardée
SELECT
  base.*,
  r.recency_days,
  r.cat_recency
FROM `global-sun-501608-b1.olist.olist_customers_aggregated_cat` AS base
LEFT JOIN recency_segmented AS r
  ON base.customer_unique_id = r.customer_unique_id;
