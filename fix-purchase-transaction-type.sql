-- Fix transaction_type ENUM to support purchase invoices
-- This will resolve the "Data truncated for column 'transaction_type'" error

-- Update financial_transactions table to include 'purchase' type
ALTER TABLE financial_transactions 
MODIFY transaction_type ENUM('sale', 'payment', 'expense', 'stock_adjustment', 'purchase') NOT NULL;

-- Verify the change
DESCRIBE financial_transactions;

-- Check current transaction types in use
SELECT DISTINCT transaction_type FROM financial_transactions;

SELECT 'financial_transactions table updated to support purchase transactions' as status;
