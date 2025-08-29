
-- Migration script to fix VPS database structure
-- Run these commands on your VPS database

-- 1. Add missing columns to invoices table
ALTER TABLE invoices 
ADD COLUMN IF NOT EXISTS invoice_type ENUM('sale','purchase') DEFAULT 'sale' AFTER invoice_date_shamsi,
ADD COLUMN IF NOT EXISTS paid_amount DECIMAL(15,2) DEFAULT 0.00 COMMENT 'مبلغ پرداخت شده' AFTER status,
ADD COLUMN IF NOT EXISTS remaining_amount DECIMAL(15,2) DEFAULT 0.00 COMMENT 'مبلغ باقیمانده' AFTER paid_amount,
ADD COLUMN IF NOT EXISTS payment_status ENUM('unpaid','partial','paid') DEFAULT 'unpaid' COMMENT 'وضعیت پرداخت' AFTER remaining_amount;

-- 2. Add missing columns to invoice_items table  
ALTER TABLE invoice_items
ADD COLUMN IF NOT EXISTS carat INT DEFAULT 18 COMMENT 'عیار طلا' AFTER description,
ADD COLUMN IF NOT EXISTS manual_weight DECIMAL(8,3) DEFAULT 0.000 COMMENT 'وزن دستی وارد شده' AFTER carat,
ADD COLUMN IF NOT EXISTS daily_gold_price DECIMAL(15,2) DEFAULT 0.00 COMMENT 'قیمت طلای روز' AFTER manual_weight,
ADD COLUMN IF NOT EXISTS tax_amount DECIMAL(15,2) DEFAULT 0.00 COMMENT 'مبلغ مالیات' AFTER daily_gold_price,
ADD COLUMN IF NOT EXISTS final_unit_price DECIMAL(15,2) DEFAULT 0.00 COMMENT 'قیمت نهایی واحد' AFTER tax_amount;

-- 3. Add missing column to payments table
ALTER TABLE payments 
ADD COLUMN IF NOT EXISTS invoice_id INT DEFAULT NULL AFTER customer_id;

-- 4. Add foreign key constraint for payments.invoice_id
ALTER TABLE payments 
ADD CONSTRAINT IF NOT EXISTS payments_ibfk_2 
FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL;

-- 5. Ensure inventory_items has category_id column
ALTER TABLE inventory_items 
ADD COLUMN IF NOT EXISTS category_id INT DEFAULT NULL AFTER type_id;

-- 6. Add foreign key for inventory_items.category_id if categories table exists
-- ALTER TABLE inventory_items 
-- ADD CONSTRAINT IF NOT EXISTS inventory_items_ibfk_2 
-- FOREIGN KEY (category_id) REFERENCES categories(id);

-- Verify the changes
SELECT 'invoices table updated' as status;
DESCRIBE invoices;

SELECT 'invoice_items table updated' as status;  
DESCRIBE invoice_items;

SELECT 'payments table updated' as status;
DESCRIBE payments;
