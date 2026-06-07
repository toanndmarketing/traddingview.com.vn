const http = require('http');
const { exec } = require('child_process');

const PORT = 9000;
const NGINX_CACHE_DIR = '/var/cache/nginx';

// ==========================================
// CACHE & CRAWLER STORE
// ==========================================
let newsCache = []; // Danh sách tin tức trong ngày hôm nay (GMT+7)
let sentimentCache = null;
let lastSentimentFetch = 0;
const SENTIMENT_CACHE_TTL = 10 * 60 * 1000; // 10 phút cache cho sentiment

function purgeNginxCache() {
    console.log('[INFO] Purging Nginx cache...');
    const command = `rm -rf ${NGINX_CACHE_DIR}/[0-9a-f] ${NGINX_CACHE_DIR}/[0-9a-f][0-9a-f]`;
    exec(command, (error) => {
        if (error) {
            console.error('[ERROR] Purge failed:', error.message);
            return;
        }
        console.log('[SUCCESS] Cache purged at ' + new Date().toISOString());
    });
}

// Lọc và gộp tin tức trong ngày GMT+7
function updateNewsCache(newItems) {
    // GMT+7 Date
    const nowVN = new Date(new Date().getTime() + 7 * 60 * 60 * 1000);
    const todayStr = nowVN.toISOString().split('T')[0]; // YYYY-MM-DD

    const newsMap = new Map();
    // Nạp tin cũ vào map
    newsCache.forEach(item => {
        newsMap.set(item.newsId, item);
    });
    // Đè tin mới lên map
    newItems.forEach(item => {
        newsMap.set(item.newsId, item);
    });

    // Lọc lại các tin thuộc ngày hôm nay (theo giờ VN)
    const filteredList = Array.from(newsMap.values()).filter(item => {
        if (!item.releasedDate) return false;
        const newsDateVN = new Date(item.releasedDate + 7 * 60 * 60 * 1000);
        const newsDateStr = newsDateVN.toISOString().split('T')[0];
        return newsDateStr === todayStr;
    });

    // Sắp xếp mới nhất lên đầu
    filteredList.sort((a, b) => b.releasedDate - a.releasedDate);

    newsCache = filteredList;
    console.log(`[CRAWLER] Updated news cache. Total items for ${todayStr}: ${newsCache.length}`);
}

// Hàm fetch tin tức từ FastBull
async function fetchNewsFromOrigin() {
    try {
        console.log('[CRAWLER] Fetching news from FastBull...');
        const url = 'https://api.fastbull.com/fastbull-news-service/api/getNewsPageByTagIds?pageSize=100';
        const res = await fetch(url, {
            headers: {
                'Content-Type': 'application/json',
                'langId': '10'
            }
        });
        if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
        const data = await res.json();
        
        let bodyMessage = data.bodyMessage;
        if (typeof bodyMessage === 'string') {
            bodyMessage = JSON.parse(bodyMessage);
        }
        
        if (bodyMessage && Array.isArray(bodyMessage.pageDatas)) {
            updateNewsCache(bodyMessage.pageDatas);
        }
    } catch (err) {
        console.error('[CRAWLER] Error fetching news:', err.message);
    }
}

// Hàm fetch Sentiment từ FastBull
async function getSentiment() {
    const now = Date.now();
    if (sentimentCache && (now - lastSentimentFetch < SENTIMENT_CACHE_TTL)) {
        return sentimentCache;
    }
    
    try {
        console.log('[CRAWLER] Fetching sentiment from FastBull...');
        const url = 'https://api.fastbull.com/fastbull-macro-data-service/api/v2/getIndexSpeculative';
        const res = await fetch(url, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
        const data = await res.json();
        sentimentCache = data;
        lastSentimentFetch = now;
        return sentimentCache;
    } catch (err) {
        console.error('[CRAWLER] Error fetching sentiment:', err.message);
        return sentimentCache || { code: 200, message: "success", bodyMessage: JSON.stringify([]) };
    }
}

// Bắt đầu crawler chạy ngầm định kỳ (fetch tin tức mỗi 3 phút)
fetchNewsFromOrigin(); // Chạy ngay lần đầu khi khởi động
setInterval(fetchNewsFromOrigin, 3 * 60 * 1000); // 3 phút / lần

// ==========================================
// HTTP SERVER ROUTER
// ==========================================
const server = http.createServer(async (req, res) => {
    // Cấu hình Header mặc định cho JSON
    const headersJson = { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' };

    // Health check
    if (req.url === '/health') {
        res.writeHead(200, headersJson);
        return res.end(JSON.stringify({ status: 'ok', newsCachedCount: newsCache.length }));
    }

    // Purge cache Nginx (nhận từ Ghost webhook)
    if (req.method === 'POST' && req.url.startsWith('/purge')) {
        console.log('[WEBHOOK] Received purge request at ' + new Date().toISOString());
        res.writeHead(200, headersJson);
        res.end(JSON.stringify({ success: true, message: 'Process started' }));
        req.on('data', () => {});
        req.on('end', () => {
            purgeNginxCache();
        });
        return;
    }

    // API Get News (trả về tin tức cache trong ngày)
    if (req.method === 'GET' && req.url.startsWith('/news')) {
        res.writeHead(200, headersJson);
        const responseData = {
            code: 200,
            message: "success",
            bodyMessage: JSON.stringify({ pageDatas: newsCache })
        };
        return res.end(JSON.stringify(responseData));
    }

    // API Get Sentiment (trả về sentiment ratio cache 10p)
    if (req.method === 'GET' && req.url.startsWith('/sentiment')) {
        res.writeHead(200, headersJson);
        const data = await getSentiment();
        return res.end(JSON.stringify(data));
    }

    res.writeHead(404);
    res.end();
});

server.listen(PORT, '0.0.0.0', () => {
    console.log('Cache Purge & Crawler Server running on port ' + PORT);
});
