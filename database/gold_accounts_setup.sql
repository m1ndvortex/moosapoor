-- Gold Accounts Setup Script for VPS Deployment
-- Description: Complete setup for gold transaction system
-- Date: 2025-01-29

-- Use the correct database
USE gold_shop_db;

-- Create customer_gold_transactions table if not exists
CREATE TABLE IF NOT EXISTS customer_gold_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type ENUM('debit', 'credit') NOT NULL COMMENT 'debit=بدهکار, credit=بستانکار',
    amount_grams DECIMAL(8,3) NOT NULL COMMENT 'مقدار طلا بر حسب گرم',
    description TEXT NOT NULL COMMENT 'توضیحات تراکنش',
    created_by INT NOT NULL COMMENT 'کاربری که تراکنش را ثبت کرده',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    
    -- Indexes for performance optimization
    INDEX idx_customer_date (customer_id, transaction_date),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_created_by (created_by),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add constraints for validation
ALTER TABLE customer_gold_transactions 
ADD CONSTRAINT chk_amount_positive CHECK (amount_grams > 0);

-- Add composite index for complex queries
CREATE INDEX IF NOT EXISTS idx_customer_type_date ON customer_gold_transactions (customer_id, transaction_type, transaction_date);

-- Add gold_balance column to customers table if not exists
ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS gold_balance DECIMAL(8,3) DEFAULT 0.000 COMMENT 'موجودی طلای مشتری بر حسب گرم';

-- Create or update gold_inventory table
CREATE TABLE IF NOT EXISTS gold_inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    item_code VARCHAR(100) UNIQUE NOT NULL,
    weight_grams DECIMAL(8,3) NOT NULL,
    purity VARCHAR(50) NOT NULL COMMENT 'عیار طلا',
    current_stock INT DEFAULT 0,
    unit_price DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_item_code (item_code),
    INDEX idx_purity (purity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create or update gold_rates table
CREATE TABLE IF NOT EXISTS gold_rates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rate_date DATE NOT NULL,
    gold_18k_price DECIMAL(15,2) NOT NULL COMMENT 'قیمت طلای 18 عیار',
    gold_24k_price DECIMAL(15,2) NOT NULL COMMENT 'قیمت طلای 24 عیار',
    dollar_rate DECIMAL(10,2) DEFAULT 0 COMMENT 'نرخ دلار',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_date (rate_date),
    INDEX idx_rate_date (rate_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default gold rate if not exists
INSERT IGNORE INTO gold_rates (rate_date, gold_18k_price, gold_24k_price, dollar_rate) 
VALUES (CURDATE(), 0, 0, 0);

-- Create trigger to update customer gold balance
DELIMITER $$

DROP TRIGGER IF EXISTS update_customer_gold_balance$$

CREATE TRIGGER update_customer_gold_balance
    AFTER INSERT ON customer_gold_transactions
    FOR EACH ROW
BEGIN
    UPDATE customers 
    SET gold_balance = (
        SELECT 
            COALESCE(SUM(CASE WHEN transaction_type = 'credit' THEN amount_grams ELSE -amount_grams END), 0)
        FROM customer_gold_transactions 
        WHERE customer_id = NEW.customer_id
    )
    WHERE id = NEW.customer_id;
END$$

DROP TRIGGER IF EXISTS update_customer_gold_balance_on_update$$

CREATE TRIGGER update_customer_gold_balance_on_update
    AFTER UPDATE ON customer_gold_transactions
    FOR EACH ROW
BEGIN
    UPDATE customers 
    SET gold_balance = (
        SELECT 
            COALESCE(SUM(CASE WHEN transaction_type = 'credit' THEN amount_grams ELSE -amount_grams END), 0)
        FROM customer_gold_transactions 
        WHERE customer_id = NEW.customer_id
    )
    WHERE id = NEW.customer_id;
END$$

DROP TRIGGER IF EXISTS update_customer_gold_balance_on_delete$$

CREATE TRIGGER update_customer_gold_balance_on_delete
    AFTER DELETE ON customer_gold_transactions
    FOR EACH ROW
BEGIN
    UPDATE customers 
    SET gold_balance = (
        SELECT 
            COALESCE(SUM(CASE WHEN transaction_type = 'credit' THEN amount_grams ELSE -amount_grams END), 0)
        FROM customer_gold_transactions 
        WHERE customer_id = OLD.customer_id
    )
    WHERE id = OLD.customer_id;
END$$

DELIMITER ;

-- Update existing customers' gold balance
UPDATE customers c
SET gold_balance = (
    SELECT 
        COALESCE(SUM(CASE WHEN cgt.transaction_type = 'credit' THEN cgt.amount_grams ELSE -cgt.amount_grams END), 0)
    FROM customer_gold_transactions cgt
    WHERE cgt.customer_id = c.id
);

-- Show setup results
SELECT 'Gold accounts setup completed successfully!' as status;

-- Show table information
SELECT 
    TABLE_NAME as 'Table',
    TABLE_ROWS as 'Rows',
    CREATE_TIME as 'Created'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'gold_shop_db' 
AND TABLE_NAME LIKE '%gold%'
ORDER BY TABLE_NAME;