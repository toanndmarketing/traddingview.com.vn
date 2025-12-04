/**
 * Ghost Webhook Cache Purge Server
 * 
 * Nhận webhook từ Ghost khi publish/update bài và tự động purge nginx cache
 * 
 * Chạy trong Docker container, share volume với nginx cache
 * Port: 9000
 */

const http = require('http');
const { exec } = require('child_process');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// Config
const PORT = 9000;
const SECRET = process.env.WEBHOOK_SECRET || 'ghost-cache-purge-secret-2024';

// Nginx cache directory (shared volume với nginx container)
const NGINX_CACHE_DIR = '/var/cache/nginx';

// Purge nginx cache bằng cách xóa files trong shared volume
function purgeNginxCache(callback) {
    // Đọc tất cả subdirectories và xóa
    fs.readdir(NGINX_CACHE_DIR, (err, items) => {
        if (err) {
            console.error(`[ERROR] Cannot read cache dir: ${err.message}`);
            callback(false, err.message);
            return;
        }

        let deleted = 0;
        const cacheSubdirs = items.filter(item => {
            // Chỉ xóa các folder cache (0-9, a-f)
            return /^[0-9a-f]$/.test(item);
        });

        if (cacheSubdirs.length === 0) {
            console.log(`[INFO] Cache already empty`);
            callback(true, 'Cache already empty');
            return;
        }

        cacheSubdirs.forEach(dir => {
            const dirPath = path.join(NGINX_CACHE_DIR, dir);
            exec(`rm -rf ${dirPath}/*`, (error) => {
                deleted++;
                if (deleted === cacheSubdirs.length) {
                    console.log(`[SUCCESS] Nginx cache purged at ${new Date().toISOString()}`);
                    callback(true, `Purged ${deleted} cache directories`);
                }
            });
        });
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
