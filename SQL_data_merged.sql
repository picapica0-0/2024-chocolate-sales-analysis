
-- Add a new column for the corrected category
ALTER TABLE products
ADD COLUMN correct_category TEXT;

-- Fill the new column using category 
UPDATE products
SET correct_category =
    SUBSTR(
        product_name,
        1,
        INSTR(product_name, ' ') - 1
    );

-- Remove the old incorrect category column
ALTER TABLE products
DROP COLUMN category;

-- Merge sales data with related customer, product, store,
-- and calendar information into one combined result table
CREATE TABLE chocolate AS
SELECT
    -- All columns from sales table
    s.*,

    -- Product details
    p.product_name,
    p.brand,
    p.correct_category,
    p.cocoa_percent,
    p.weight_g,

    -- Customer details
    c.age,
    c.gender,
    c.loyalty_member,
    c.join_date,

    -- Store details
    st.store_name,
    st.city,
    st.country,
    st.store_type,

    -- Calendar details
    cal.month,
    cal.year

FROM sales s

-- Match customer information
JOIN customers c
    ON s.customer_id = c.customer_id

-- Match product information
JOIN products p
    ON s.product_id = p.product_id

-- Match store information
JOIN stores st
    ON s.store_id = st.store_id

-- Match calendar information using order date
JOIN calendar cal
    ON s.order_date = cal.date;

-- Create table with monthly revenue, profit, and quantity
CREATE TABLE monthly_sales AS
SELECT c.year,
        c.month,
        SUM(s.revenue) AS monthly_revenue,
        SUM(s.quantity) AS monthly_quantity,
        SUM(s.profit) AS monthly_profit
FROM sales s
JOIN calendar c ON s.order_date = c.date
GROUP BY c.year, c.month
ORDER BY c.year, c.month;
