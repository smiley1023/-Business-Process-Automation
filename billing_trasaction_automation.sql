-- 🔥 Business Process Automation & SQL Optimization 

-- Create a new database
CREATE DATABASE finance_db;
USE finance_db;
-- Create a table for billing transactions
CREATE TABLE billing_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(10),
    amount DECIMAL(10,2),
    transaction_date DATE,
    status ENUM('Completed', 'Pending', 'Failed'),
    payment_method VARCHAR(50),
    invoice_id VARCHAR(10)
);
SHOW TABLES FROM finance_db;
SHOW TABLES;

INSERT INTO billing_transactions (customer_id, amount, transaction_date, status, payment_method, invoice_id)
VALUES 
('CUST001', 250.00, '2024-03-01', 'Completed', 'Credit Card', 'INV001'),
('CUST002', 500.00, '2024-03-02', 'Pending', 'Bank Transfer', 'INV002'),
('CUST003', 120.00, '2024-03-03', 'Completed', 'PayPal', 'INV003'),
('CUST001', 75.00, '2024-03-03', 'Failed', 'Credit Card', 'INV004'),
('CUST004', 300.00, '2024-03-05', 'Completed', 'Bank Transfer', 'INV005'),
('CUST005', 400.00, '2024-03-07', 'Pending', 'Credit Card', 'INV006');

INSERT INTO billing_transactions (customer_id, amount, transaction_date, status, payment_method, invoice_id)
VALUES 
('CUST001', 600.00, CURDATE(), 'Completed', 'Credit Card', 'INV010'),
('CUST002', 750.00, CURDATE(), 'Pending', 'Bank Transfer', 'INV011'),
('CUST003', 450.00, DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Completed', 'PayPal', 'INV012');


SELECT * FROM billing_transactions;

-- Scenario: The risk & fraud detection team wants a report on high-value transactions ($400+) in the past 7 days.
-- 🔹  1️⃣ High-Value Transactions in the Last 7 Days
-- Why? Finance teams need to monitor big transactions for risk.
-- ✔ Use Case: Identifies transactions requiring manual review for fraud or VIP approvals
SELECT transaction_id, customer_id, amount,DATE(transaction_date) AS transaction_date, status
FROM billing_transactions
WHERE amount > 400 AND DATE(transaction_date) >= date_sub(curdate(), interval 7 DAY)
ORDER BY amount DESC;
-- 🔹  2️⃣ Challenge: Count Transactions by Status in the Last 30 Days
-- Scenario: The finance automation team wants to analyze how many transactions were Completed, Pending, or Failed.
SELECT  status, count(*) as transaction_count
FROM billing_transactions
WHERE DATE(transaction_date) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY status;
-- 🔹  3️⃣ Challenge: Find Customers Who Made Consecutive Failed Transactions
-- Scenario: The fraud detection team wants to find customers with 2+ consecutive failed transactions.
SELECT  customer_id, COUNT(*) AS failed_count
FROM billing_transactions
WHERE status = 'Failed'
GROUP BY customer_id
HAVING COUNT(*) > 2;
-- 🔹 4️⃣ Detect Potential Duplicate Transactions
-- Scenario: The finance audit team needs a report on duplicate transactions (same customer, amount, and date)
SELECT customer_id, amount, transaction_date, COUNT(*) AS duplicate_count
FROM billing_transactions
GROUP BY customer_id, amount, transaction_date
HAVING COUNT(*) > 1;
-- 🔹 5️⃣ Automate Monthly Revenue Report
-- Scenario: The finance team wants a monthly revenue summary grouped by payment method.
SELECT payment_method, SUM(amount) AS total_revenue, COUNT(transaction_id) AS total_transactions
FROM billing_transactions
WHERE transaction_date >= DATE_FORMAT(NOW(), '%Y-%m-01')  -- First day of the current month
GROUP BY payment_method
ORDER BY total_revenue DESC;
###############################################################################################################################################################################
-- 🔥 Business Process Automation & SQL Optimization 

USE finance_db;

-- Create the invoices table
CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(10),
    amount DECIMAL(10,2),
    due_date DATE,
    payment_status ENUM('Paid', 'Unpaid', 'Overdue'),
    payment_method VARCHAR(50)
);
INSERT INTO invoices (customer_id, amount, due_date, payment_status, payment_method)
VALUES
('CUST001', 1200.00, '2025-02-01', 'Unpaid', 'Credit Card'),
('CUST002', 500.00, '2025-01-25', 'Unpaid', 'Bank Transfer'),
('CUST003', 250.00, '2025-03-10', 'Paid', 'PayPal'),
('CUST004', 800.00, '2025-01-10', 'Unpaid', 'Credit Card'),
('CUST005', 950.00, '2025-02-05', 'Overdue', 'Bank Transfer');


-- SQL for Business Process Automation
-- 🔹 1️⃣ Automating Invoice Reconciliation
-- Use Case: This query flags overdue invoices so automated reminders can be sent via Power Automate
SELECT invoice_id, customer_id, amount, due_date, payment_status
FROM invoices
WHERE payment_status = 'Unpaid'
AND DATEDIFF(CURDATE(), due_date) > 30;
-- 🔹 2️⃣ Detecting Duplicate Payments
-- Scenario: The audit team wants to detect duplicate payments (same customer, amount, date)
-- Use Case: Prevents double charging customers in automated billing 
SELECT customer_id, amount, transaction_date, COUNT(*) AS duplicate_count
FROM billing_transactions
GROUP BY customer_id, amount, transaction_date
HAVING COUNT(*) > 1;
-- 🔹 3️⃣ Automating KPI Dashboard for Finance Team
-- Scenario: Your company wants an automated monthly financial report showing total revenue per payment method
-- Use Case: Generates real-time financial reports for executives
SELECT payment_method, SUM(amount) AS total_revenue, COUNT(transaction_id) AS total_transactions
FROM billing_transactions
WHERE transaction_date >= DATE_FORMAT(NOW(), '%Y-%m-01')  -- First day of the current month
GROUP BY payment_method
ORDER BY total_revenue DESC;
###############################################################################################################################################################################
-- 📌 SQL Query Optimization for Finance Workflows

-- 🔹 1️⃣ Using Indexes to Speed Up Queries
-- Problem: Large finance datasets slow down SQL queries
-- Solution: Indexes speed up searches 
-- Speeds up queries filtering by transaction_date
CREATE INDEX idx_transaction_date ON billing_transactions(transaction_date);
-- 🔹 2️⃣ Partitioning Large Finance Tables
-- Problem: A single finance table (millions of rows) slows queries.
-- Solution: Partitioning by year improves performance
-- Faster data retrieval in large datasets
ALTER TABLE billing_transactions DROP PRIMARY KEY;

ALTER TABLE billing_transactions ADD PRIMARY KEY (transaction_id, transaction_date);

ALTER TABLE billing_transactions MODIFY COLUMN transaction_date DATE;

CREATE TABLE billing_transactions (
    transaction_id INT NOT NULL,
    customer_id VARCHAR(10),
    amount DECIMAL(10,2),
    transaction_date DATE NOT NULL,
    status ENUM('Completed', 'Pending', 'Failed'),
    payment_method VARCHAR(50),
    invoice_id VARCHAR(10),
    PRIMARY KEY (transaction_id, transaction_date)
)
PARTITION BY RANGE (YEAR(transaction_date)) (
    PARTITION p0 VALUES LESS THAN (2023),
    PARTITION p1 VALUES LESS THAN (2024),
    PARTITION p2 VALUES LESS THAN (2025)
);

-- Verify partitioning with this query
SELECT PARTITION_NAME, TABLE_ROWS 
FROM information_schema.partitions 
WHERE TABLE_NAME = 'billing_transactions';
-- 🔹 Find customers who have BOTH overdue invoices AND failed transactions in billing_transactions
-- finds customers who are overdue AND repeatedly fail transactions, so finance teams can take action
SELECT i.customer_id, COUNT(i.invoice_id) AS overdue_invoices, COUNT(b.transaction_id) AS failed_transactions
FROM invoices i
JOIN billing_transactions b ON i.customer_id = b.customer_id
WHERE i.payment_status = 'Unpaid'
AND DATEDIFF(CURDATE(), i.due_date) > 30
AND b.status = 'Failed'
GROUP BY i.customer_id
HAVING COUNT(b.transaction_id) > 2;





