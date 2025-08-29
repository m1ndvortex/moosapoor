-- VPS Database Structure Check
-- Run this script on your VPS to check what columns are missing

SELECT 'CHECKING VPS DATABASE STRUCTURE' as info;

-- Check if critical tables exist
SELECT 
    CASE WHEN COUNT(*) = 5 THEN 'All critical tables exist ✅'
         ELSE CONCAT('Missing tables: ', 5 - COUNT(*)) 
    END as table_check
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME IN ('invoices', 'invoice_items', 'customers', 'inventory_items', 'payments');

-- Check invoices table structure
SELECT 'INVOICES TABLE CHECK:' as info;

SELECT 
    CASE WHEN COUNT(*) > 0 THEN 'invoice_type column exists ✅'
         ELSE 'invoice_type column MISSING ❌' 
    END as invoice_type_check
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'invoices' 
AND COLUMN_NAME = 'invoice_type';

SELECT 
    CASE WHEN COUNT(*) = 3 THEN 'Payment columns exist ✅'
         ELSE CONCAT('Missing payment columns: ', 3 - COUNT(*), ' ❌')
    END as payment_columns_check
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'invoices' 
AND COLUMN_NAME IN ('paid_amount', 'remaining_amount', 'payment_status');

-- Check invoice_items table structure  
SELECT 'INVOICE_ITEMS TABLE CHECK:' as info;

SELECT 
    CASE WHEN COUNT(*) = 5 THEN 'All extended columns exist ✅'
         ELSE CONCAT('Missing extended columns: ', 5 - COUNT(*), ' ❌')
    END as extended_columns_check
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'invoice_items' 
AND COLUMN_NAME IN ('carat', 'manual_weight', 'daily_gold_price', 'tax_amount', 'final_unit_price');

-- Check payments table structure
SELECT 'PAYMENTS TABLE CHECK:' as info;

SELECT 
    CASE WHEN COUNT(*) > 0 THEN 'invoice_id column exists ✅'
         ELSE 'invoice_id column MISSING ❌'
    END as invoice_id_check
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'payments' 
AND COLUMN_NAME = 'invoice_id';

-- Show current invoices table structure
SELECT 'CURRENT INVOICES TABLE STRUCTURE:' as info;
DESCRIBE invoices;

-- Show current invoice_items table structure
SELECT 'CURRENT INVOICE_ITEMS TABLE STRUCTURE:' as info;
DESCRIBE invoice_items;

-- Show current payments table structure
SELECT 'CURRENT PAYMENTS TABLE STRUCTURE:' as info;
DESCRIBE payments;

-- List all missing columns specifically
SELECT 'MISSING COLUMNS SUMMARY:' as info;

SELECT 'Missing from invoices:' as table_name, 
       GROUP_CONCAT(missing_column) as missing_columns
FROM (
    SELECT 'invoice_type' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoices' 
        AND COLUMN_NAME = 'invoice_type'
    )
    UNION ALL
    SELECT 'paid_amount' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoices' 
        AND COLUMN_NAME = 'paid_amount'
    )
    UNION ALL
    SELECT 'remaining_amount' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoices' 
        AND COLUMN_NAME = 'remaining_amount'
    )
    UNION ALL
    SELECT 'payment_status' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoices' 
        AND COLUMN_NAME = 'payment_status'
    )
) missing_invoice_cols
WHERE missing_column IS NOT NULL

UNION ALL

SELECT 'Missing from invoice_items:' as table_name,
       GROUP_CONCAT(missing_column) as missing_columns  
FROM (
    SELECT 'carat' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoice_items' 
        AND COLUMN_NAME = 'carat'
    )
    UNION ALL
    SELECT 'manual_weight' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoice_items' 
        AND COLUMN_NAME = 'manual_weight'
    )
    UNION ALL
    SELECT 'daily_gold_price' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoice_items' 
        AND COLUMN_NAME = 'daily_gold_price'
    )
    UNION ALL
    SELECT 'tax_amount' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoice_items' 
        AND COLUMN_NAME = 'tax_amount'
    )
    UNION ALL
    SELECT 'final_unit_price' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'invoice_items' 
        AND COLUMN_NAME = 'final_unit_price'
    )
) missing_items_cols
WHERE missing_column IS NOT NULL

UNION ALL

SELECT 'Missing from payments:' as table_name,
       GROUP_CONCAT(missing_column) as missing_columns
FROM (
    SELECT 'invoice_id' as missing_column
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'payments' 
        AND COLUMN_NAME = 'invoice_id'
    )
) missing_payments_cols
WHERE missing_column IS NOT NULL;
