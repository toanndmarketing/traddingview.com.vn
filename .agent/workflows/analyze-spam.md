---
description: Check traffic spam, xác thực Real IP và User-Agent để chặn trên Cloudflare
---

# Workflow: Phân tích & Xử lý Spam Traffic (Tradingview)

// turbo-all

---

## 🚀 1. Kiểm tra nhanh (Quick Audit)

Xem 20 IP thực (Real IP) có lượng request lớn nhất trong 1 giờ qua:

```bash
ssh root@57.129.45.30 "grep \"$(date +'%d/%b/%Y:%H')\" /var/log/nginx/access.log | grep -oP 'cf_ip=\"\K[^\"]+' | sort | uniq -c | sort -rn | head -20"
```

## 🔍 2. Phân tích diện rộng (Deep Analysis)

### TOP User-Agents khả nghi (Thường là bot đồ cổ hoặc headless)

```bash
ssh root@57.129.45.30 "awk -F'\"' '{print \$6}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -15"
```

### TOP Quốc gia đang truy cập nhiều nhất

```bash
ssh root@57.129.45.30 "grep -oP 'cf_country=\"\K[^\"]+' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10"
```

### Kiểm tra các bản Chrome "đồ cổ" (Dấu hiệu spam chủ đạo)

Check xem còn bao nhiêu request từ Chrome 41, 55, 16 (Hội spam 2s):

```bash
ssh root@57.129.45.30 "grep -iE 'Chrome/(41|55|16)' /var/log/nginx/access.log | tail -n 20"
```

## 📈 3. Theo dõi Timeline (Realtime)

Xem tốc độ request theo từng phút để phát hiện "bão spam":

```bash
ssh root@57.129.45.30 "tail -n 2000 /var/log/nginx/access.log | awk '{print \$4}' | cut -d: -f1-3 | uniq -c | tail -15"
```

---

## 🛠 4. Hướng dẫn xử lý (Action Plan)

### Nếu thấy 1 User-Agent lạ chiếm đa số (vd: Chrome/41.0...)

1. Copy đoạn User-Agent đó.
2. Vào **Cloudflare -> Security -> WAF -> Custom Rules**.
3. Tạo Rule: `User Agent contains "tên_agent_vừa_copy"`.
4. Action: **Block** hoặc **JS Challenge**.

### Nếu thấy 1 IP từ Data Center nước ngoài spam

1. Lấy Real IP từ cột `cf_ip`.
2. Dùng công cụ `whois` check nếu thuộc Amazon, OVH, DigitalOcean thì chặn thẳng tay.
3. Chặn trên Cloudflare bằng Rule IP.

### Nếu thấy traffic tăng đột biến không rõ nguồn gốc

1. Bật **Under Attack Mode** trên Cloudflare Dashboad.
2. Sau khi ổn định thì tắt đi để tránh ảnh hưởng UX người dùng thật.
