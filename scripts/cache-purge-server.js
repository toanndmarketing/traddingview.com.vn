/**
 * Ghost Webhook Cache Purge Server
 * 
 * Nhận webhook từ Ghost khi publish/update bài và tự động purge nginx cache
 * 
 * Chạy: node cache-purge-server.js
 * Port: 9000
 */

const http = require('http');
const { exec } = require('child_process');
const crypto = require('crypto');

// Config
const PORT = 9000;
const SECRET = process.env.WEBHOOK_SECRET || 'ghost-cache-purge-secret-2024';

// Nginx cache directory (trong docker container)
const NGINX_CACHE_DIR = '/var/cache/nginx';
const NGINX_CONTAINER = 'ghost-nginx';

// Purge nginx cache
function purgeNginxCache(callback) {
    const cmd = `docker exec ${NGINX_CONTAINER} sh -c "rm -rf ${NGINX_CACHE_DIR}/* && nginx -s reload"`;
    
    exec(cmd, (error, stdout, stderr) => {
        if (error) {
            console.error(`[ERROR] Purge failed: ${error.message}`);
            callback(false, error.message);
            return;
        }
        console.log(`[SUCCESS] Nginx cache purged at ${new Date().toISOString()}`);
        callback(true, 'Cache purged successfully');
    });
}

// Verify webhook signature (optional security)
function verifySignature(payload, signature) {
    if (!signature) return true; // Skip if no signature
    
    const hmac = crypto.createHmac('sha256', SECRET);
    const digest = hmac.update(payload).digest('hex');
    return signature === digest;
}

// HTTP Server
const server = http.createServer((req, res) => {
    // Health check
    if (req.method === 'GET' && req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', service: 'cache-purge-server' }));
        return;
    }

    // Only accept POST to /purge
    if (req.method !== 'POST' || !req.url.startsWith('/purge')) {
        res.writeHead(404);
        res.end('Not Found');
        return;
    }

    let body = '';
    req.on('data', chunk => { body += chunk; });
    
    req.on('end', () => {
        // Log incoming webhook
        console.log(`[WEBHOOK] Received at ${new Date().toISOString()}`);
        
        try {
            const data = JSON.parse(body || '{}');
            
            // Log event type
            if (data.post) {
                console.log(`[EVENT] Post: "${data.post.current?.title || 'Unknown'}" - Status: ${data.post.current?.status || 'unknown'}`);
            } else if (data.page) {
                console.log(`[EVENT] Page: "${data.page.current?.title || 'Unknown'}"`);
            } else if (data.tag) {
                console.log(`[EVENT] Tag updated`);
            } else if (data.site) {
                console.log(`[EVENT] Site settings updated`);
            }
        } catch (e) {
            console.log(`[EVENT] Unknown event`);
        }

        // Purge cache
        purgeNginxCache((success, message) => {
            res.writeHead(success ? 200 : 500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ 
                success, 
                message,
                timestamp: new Date().toISOString()
            }));
        });
    });
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`
╔════════════════════════════════════════════════════════════╗
║        Ghost Cache Purge Server Started                    ║
╠════════════════════════════════════════════════════════════╣
║  Port: ${PORT}                                                 ║
║  Endpoint: http://127.0.0.1:${PORT}/purge                      ║
║  Health: http://127.0.0.1:${PORT}/health                       ║
╚════════════════════════════════════════════════════════════╝

Waiting for Ghost webhooks...
    `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('[SHUTDOWN] Received SIGTERM, closing server...');
    server.close(() => process.exit(0));
});
