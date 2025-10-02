-- Monthly Sales Trend Analysis
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    MONTHNAME(order_date) AS month_name,
    SUM(amount) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS order_volume,
    ROUND(AVG(amount), 2) AS average_order_value,
    ROUND(SUM(amount) / COUNT(DISTINCT order_id), 2) AS revenue_per_order
FROM orders
WHERE order_date IS NOT NULL
GROUP BY 
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date)
ORDER BY 
    year DESC, 
    month DESC;
    
    -- Top 3 Months by Revenue
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    MONTHNAME(order_date) AS month_name,
    SUM(amount) AS monthly_revenue,
    COUNT(DISTINCT order_id) AS order_volume
FROM orders
GROUP BY 
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date)
ORDER BY monthly_revenue DESC
LIMIT 3;


-- Monthly Growth Rate (Month-over-Month)
WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        MONTHNAME(order_date) AS month_name,
        SUM(amount) AS revenue,
        LAG(SUM(amount)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS prev_month_revenue
    FROM orders
    GROUP BY 
        YEAR(order_date),
        MONTH(order_date),
        MONTHNAME(order_date)
)
SELECT 
    year,
    month,
    month_name,
    revenue,
    prev_month_revenue,
    CASE 
        WHEN prev_month_revenue IS NULL THEN NULL
        ELSE ROUND(((revenue - prev_month_revenue) / prev_month_revenue * 100), 2)
    END AS growth_percentage
FROM monthly_sales
ORDER BY year, month;

-- Yearly Sales Summary
SELECT 
    YEAR(order_date) AS year,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(amount) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_order_value,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT product_id) AS unique_products
FROM orders
GROUP BY YEAR(order_date)
ORDER BY year DESC;

-- Top Selling Product Each Month
SELECT 
    year,
    month,
    month_name,
    product_id,
    product_revenue
FROM (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        MONTHNAME(order_date) AS month_name,
        product_id,
        SUM(amount) AS product_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(order_date), MONTH(order_date) 
            ORDER BY SUM(amount) DESC
        ) as rank_position
    FROM orders
    GROUP BY 
        YEAR(order_date),
        MONTH(order_date),
        MONTHNAME(order_date),
        product_id
) ranked_products
WHERE rank_position = 1
ORDER BY year, month;

-- Top Customers by Total Spending
SELECT 
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(amount) AS total_spent,
    ROUND(AVG(amount), 2) AS average_order_value,
    MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Best and Worst Performing Months
SELECT 
    MONTHNAME(order_date) AS month_name,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(amount) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_order_value
FROM orders
GROUP BY MONTHNAME(order_date)
ORDER BY total_revenue DESC;

-- Data Validation Queries

-- Check for NULL values
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_ids,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) AS null_amounts
FROM orders;

-- Date range check
SELECT 
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS days_covered
FROM orders;