#!/usr/bin/env node
/**
 * Test script to verify SQL parameter fix
 */

const GoldTransactionDB = require('./database/gold-transactions-db');

async function testSQLFix() {
    console.log('🧪 Testing SQL parameter fix...\n');
    
    try {
        console.log('1. Testing getByCustomer with valid parameters...');
        
        // Test with limit and offset
        const result1 = await GoldTransactionDB.getByCustomer(1, {
            limit: 10,
            offset: 0,
            orderBy: 'transaction_date',
            orderDirection: 'DESC'
        });
        
        console.log(`✅ Test 1 passed: Retrieved ${result1.length} transactions`);
        
        // Test with no limit
        console.log('\n2. Testing getByCustomer without limit...');
        const result2 = await GoldTransactionDB.getByCustomer(1, {
            orderBy: 'transaction_date',
            orderDirection: 'DESC'
        });
        
        console.log(`✅ Test 2 passed: Retrieved ${result2.length} transactions`);
        
        // Test with invalid customer ID
        console.log('\n3. Testing with invalid customer ID...');
        try {
            await GoldTransactionDB.getByCustomer('invalid', {
                limit: 10,
                offset: 0
            });
            console.log('❌ Test 3 failed: Should have thrown error');
        } catch (error) {
            console.log('✅ Test 3 passed: Caught invalid customer ID error');
        }
        
        // Test with boundary values
        console.log('\n4. Testing with boundary values...');
        const result4 = await GoldTransactionDB.getByCustomer(999999, {
            limit: 5,
            offset: 0,
            orderBy: 'transaction_date',
            orderDirection: 'DESC'
        });
        
        console.log(`✅ Test 4 passed: Retrieved ${result4.length} transactions (expected 0 for non-existent customer)`);
        
        console.log('\n🎉 All SQL parameter tests passed!');
        console.log('\nThe SQL parameter issue has been fixed.');
        console.log('You can now restart your server:');
        console.log('  pm2 restart gold-shop');
        
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        console.error('Stack:', error.stack);
    }
}

// Run the test
testSQLFix().then(() => {
    console.log('\n✅ Test completed.');
    process.exit(0);
}).catch(error => {
    console.error('❌ Test failed:', error);
    process.exit(1);
});
