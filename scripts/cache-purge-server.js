const http = require('http');
const { exec } = require('child_process');

const PORT = 9000;
const NGINX_CACHE_DIR = '/var/cache/nginx';

function purgeNginxCache() {
    console.log('[INFO] Purging Nginx cache...');
    // Xóa sạch các thư mục cache levels 1:2
    const command = `rm -rf ${NGINX_CACHE_DIR}/[0-9a-f] ${NGINX_CACHE_DIR}/[0-9a-f][0-9a-f]`;
    exec(command, (error) => {
        if (error) {
            console.error('[ERROR] Purge failed:', error.message);
            return;
        }
        console.log('[SUCCESS] Cache purged at ' + new Date().toISOString());
    });
}

const server = http.createServer((req, res) => {
    // Health check
    if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        return res.end(JSON.stringify({ status: 'ok' }));
    }

    // Purge endpoint
    if (req.method === 'POST' && req.url.startsWith('/purge')) {
        console.log('[WEBHOOK] Received purge request at ' + new Date().toISOString());
        
        // TRẢ LỜI NGAY để Ghost không timeout (Lỗi 500/504)
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, message: 'Process started' }));
        
        // Consume dữ liệu body (background) để tránh lỗi connection reset
        req.on('data', () => {});
        req.on('end', () => {
            purgeNginxCache();
        });
        return;
    }

    res.writeHead(404);
    res.end();
});

server.listen(PORT, '0.0.0.0', () => {
    console.log('Cache Purge Server running on port ' + PORT);
});
