// VPS Route Testing Script
// Run this to test if routes are working properly

const http = require('http');

const testRoutes = [
    '/accounting/customer-detail/22',
    '/accounting/customer/22',
    '/customers',
    '/accounting'
];

function testRoute(path) {
    return new Promise((resolve) => {
        const options = {
            hostname: 'localhost', // Change to your VPS domain
            port: 3000,
            path: path,
            method: 'GET',
            headers: {
                'Cookie': 'connect.sid=your-session-cookie' // Add your session cookie
            }
        };

        const req = http.request(options, (res) => {
            console.log(`✅ ${path}: Status ${res.statusCode}`);
            resolve({ path, status: res.statusCode });
        });

        req.on('error', (err) => {
            console.log(`❌ ${path}: Error - ${err.message}`);
            resolve({ path, error: err.message });
        });

        req.setTimeout(5000, () => {
            console.log(`⏰ ${path}: Timeout`);
            req.destroy();
            resolve({ path, error: 'Timeout' });
        });

        req.end();
    });
}

async function testAllRoutes() {
    console.log('🧪 Testing VPS Routes...\n');
    
    for (const route of testRoutes) {
        await testRoute(route);
        await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1 second between tests
    }
    
    console.log('\n✅ Route testing completed!');
}

testAllRoutes().catch(console.error);