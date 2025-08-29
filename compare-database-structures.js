const mysql = require('mysql2/promise');

// Database comparison script to identify differences between local and VPS databases

const config = {
    local: {
        host: '127.0.0.1',
        user: 'root', // Change this if needed
        password: '', // Change this to your local password
        database: 'gold_shop_db'
    },
    vps: {
        host: '87.248.131.94',
        user: 'root', // Using root for testing
        password: '18588530', // Your original password
        database: 'gold_shop_db'
    }
};

async function getTableStructure(connection, tableName) {
    try {
        const [columns] = await connection.execute(`DESCRIBE ${tableName}`);
        return columns;
    } catch (error) {
        console.log(`Table ${tableName} does not exist`);
        return null;
    }
}

async function getAllTables(connection) {
    const [tables] = await connection.execute('SHOW TABLES');
    return tables.map(row => Object.values(row)[0]);
}

async function compareDatabase() {
    let localConnection, vpsConnection;
    
    try {
        console.log('🔄 Connecting to databases...');
        
        // Connect to both databases
        localConnection = await mysql.createConnection(config.local);
        vpsConnection = await mysql.createConnection(config.vps);
        
        console.log('✅ Connected to local database');
        console.log('✅ Connected to VPS database');
        
        // Get all tables from local
        const localTables = await getAllTables(localConnection);
        console.log('\n📋 Local Database Tables:');
        console.log(localTables.sort());
        
        // VPS comparison
        const vpsTables = await getAllTables(vpsConnection);
        console.log('\n📋 VPS Database Tables:');
        console.log(vpsTables.sort());
        
        // Find missing tables
        const missingInVPS = localTables.filter(table => !vpsTables.includes(table));
        const extraInVPS = vpsTables.filter(table => !localTables.includes(table));
        
        if (missingInVPS.length > 0) {
            console.log('\n❌ Tables missing in VPS:');
            missingInVPS.forEach(table => console.log(`  - ${table}`));
        }
        
        if (extraInVPS.length > 0) {
            console.log('\n⚠️  Extra tables in VPS:');
            extraInVPS.forEach(table => console.log(`  - ${table}`));
        }
        
        // Focus on critical tables for purchase invoices
        const criticalTables = ['invoices', 'invoice_items', 'customers', 'inventory_items', 'payments'];
        
        console.log('\n🔍 Checking structure of critical tables...');
        
        for (const tableName of criticalTables) {
            console.log(`\n📊 ${tableName.toUpperCase()} TABLE STRUCTURE:`);
            
            const localStructure = await getTableStructure(localConnection, tableName);
            const vpsStructure = await getTableStructure(vpsConnection, tableName);
            
            if (localStructure) {
                console.log('Local columns:');
                localStructure.forEach(col => {
                    console.log(`  ${col.Field} | ${col.Type} | ${col.Null} | ${col.Key} | ${col.Default}`);
                });
            }
            
            if (vpsStructure) {
                console.log('\nVPS columns:');
                vpsStructure.forEach(col => {
                    console.log(`  ${col.Field} | ${col.Type} | ${col.Null} | ${col.Key} | ${col.Default}`);
                });
                
                // Compare structures
                if (localStructure) {
                    const localFields = localStructure.map(col => col.Field);
                    const vpsFields = vpsStructure.map(col => col.Field);
                    
                    const missingInVPS = localFields.filter(field => !vpsFields.includes(field));
                    const extraInVPS = vpsFields.filter(field => !localFields.includes(field));
                    
                    if (missingInVPS.length > 0) {
                        console.log(`\n❌ Columns missing in VPS ${tableName}:`);
                        missingInVPS.forEach(field => console.log(`  - ${field}`));
                    }
                    
                    if (extraInVPS.length > 0) {
                        console.log(`\n⚠️  Extra columns in VPS ${tableName}:`);
                        extraInVPS.forEach(field => console.log(`  - ${field}`));
                    }
                    
                    if (missingInVPS.length === 0 && extraInVPS.length === 0) {
                        console.log(`\n✅ ${tableName} structure matches between local and VPS`);
                    }
                }
            } else {
                console.log(`\n❌ Table ${tableName} does not exist on VPS!`);
            }
            
            if (localStructure) {
                
                // Show specific columns that might be missing in VPS
                if (tableName === 'invoices') {
                    const hasPaymentColumns = localStructure.some(col => 
                        ['paid_amount', 'remaining_amount', 'payment_status'].includes(col.Field)
                    );
                    
                    const hasInvoiceType = localStructure.some(col => col.Field === 'invoice_type');
                    
                    console.log(`\n🔍 Invoice table analysis:`);
                    console.log(`  - Has payment status columns: ${hasPaymentColumns ? '✅' : '❌'}`);
                    console.log(`  - Has invoice_type column: ${hasInvoiceType ? '✅' : '❌'}`);
                    
                    if (!hasPaymentColumns) {
                        console.log(`\n❗ Missing payment columns in invoices table!`);
                        console.log(`   Run this SQL on your VPS:`);
                        console.log(`   ALTER TABLE invoices ADD COLUMN paid_amount DECIMAL(15,2) DEFAULT 0.00 COMMENT 'مبلغ پرداخت شده';`);
                        console.log(`   ALTER TABLE invoices ADD COLUMN remaining_amount DECIMAL(15,2) DEFAULT 0.00 COMMENT 'مبلغ باقیمانده';`);
                        console.log(`   ALTER TABLE invoices ADD COLUMN payment_status ENUM('unpaid','partial','paid') DEFAULT 'unpaid' COMMENT 'وضعیت پرداخت';`);
                    }
                    
                    if (!hasInvoiceType) {
                        console.log(`\n❗ Missing invoice_type column!`);
                        console.log(`   Run this SQL on your VPS:`);
                        console.log(`   ALTER TABLE invoices ADD COLUMN invoice_type ENUM('sale','purchase') DEFAULT 'sale' AFTER invoice_date_shamsi;`);
                    }
                }
                
                if (tableName === 'invoice_items') {
                    const hasExtendedColumns = localStructure.some(col => 
                        ['carat', 'manual_weight', 'daily_gold_price', 'tax_amount', 'final_unit_price'].includes(col.Field)
                    );
                    
                    console.log(`\n🔍 Invoice_items table analysis:`);
                    console.log(`  - Has extended columns: ${hasExtendedColumns ? '✅' : '❌'}`);
                    
                    if (!hasExtendedColumns) {
                        console.log(`\n❗ Missing extended columns in invoice_items table!`);
                        console.log(`   Run this SQL on your VPS:`);
                        console.log(`   ALTER TABLE invoice_items ADD COLUMN carat INT DEFAULT 18 COMMENT 'عیار طلا';`);
                        console.log(`   ALTER TABLE invoice_items ADD COLUMN manual_weight DECIMAL(8,3) DEFAULT 0.000 COMMENT 'وزن دستی وارد شده';`);
                        console.log(`   ALTER TABLE invoice_items ADD COLUMN daily_gold_price DECIMAL(15,2) DEFAULT 0.00 COMMENT 'قیمت طلای روز';`);
                        console.log(`   ALTER TABLE invoice_items ADD COLUMN tax_amount DECIMAL(15,2) DEFAULT 0.00 COMMENT 'مبلغ مالیات';`);
                        console.log(`   ALTER TABLE invoice_items ADD COLUMN final_unit_price DECIMAL(15,2) DEFAULT 0.00 COMMENT 'قیمت نهایی واحد';`);
                    }
                }
                
                if (tableName === 'payments') {
                    const hasInvoiceId = localStructure.some(col => col.Field === 'invoice_id');
                    
                    console.log(`\n🔍 Payments table analysis:`);
                    console.log(`  - Has invoice_id column: ${hasInvoiceId ? '✅' : '❌'}`);
                    
                    if (!hasInvoiceId) {
                        console.log(`\n❗ Missing invoice_id column in payments table!`);
                        console.log(`   Run this SQL on your VPS:`);
                        console.log(`   ALTER TABLE payments ADD COLUMN invoice_id INT DEFAULT NULL AFTER customer_id;`);
                        console.log(`   ALTER TABLE payments ADD CONSTRAINT payments_ibfk_2 FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL;`);
                    }
                }
            } else {
                console.log(`❌ Table ${tableName} does not exist locally!`);
            }
            
            console.log('\n' + '='.repeat(80));
        }
        
        // Generate migration script
        console.log('\n📝 SUGGESTED MIGRATION SCRIPT FOR VPS:');
        console.log('='.repeat(50));
        
        const migrationSQL = `
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
`;
        
        console.log(migrationSQL);
        
        // Save migration script to file
        require('fs').writeFileSync('vps-migration.sql', migrationSQL);
        console.log('\n💾 Migration script saved to vps-migration.sql');
        
    } catch (error) {
        console.error('❌ Database comparison error:', error.message);
        
        if (error.code === 'ER_ACCESS_DENIED_ERROR') {
            console.log('\n🔧 Database connection failed. Please update the config object at the top of this file with your correct database credentials.');
        }
        
        if (error.code === 'ECONNREFUSED') {
            console.log('\n🔧 Cannot connect to database. Make sure your database server is running.');
        }
        
    } finally {
        if (localConnection) await localConnection.end();
        if (vpsConnection) await vpsConnection.end();
    }
}

// Run the comparison
compareDatabase().then(() => {
    console.log('\n✨ Database comparison completed!');
    console.log('\n📋 Next steps:');
    console.log('1. Update the config object in this file with your VPS database credentials');
    console.log('2. Uncomment the VPS connection code to compare both databases');
    console.log('3. Run the generated vps-migration.sql script on your VPS database');
    console.log('4. Test the purchase invoice functionality again');
}).catch(console.error);
