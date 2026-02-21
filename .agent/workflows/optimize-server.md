---
description: Tối ưu hóa Database và Server TradingView (Dọn dẹp log, Optimize tables, Restart)
---

# Workflow: Optimize Server TradingView

// turbo-all

## 🚀 Tự động hóa Tối ưu hóa

Workflow này thực hiện dọn dẹp bảng `actions` (giữ lại 60 ngày), chạy `OPTIMIZE TABLE` cho các bảng lớn, dọn dẹp Docker rác và restart toàn bộ hệ thống.

### Bước 1: Upload script tối ưu hóa lên server

```bash
scp d:\Project\traddingview.com.vn\.agent\scripts\optimize-db-tradingview.sh root@57.129.45.30:/tmp/optimize-db.sh
```

### Bước 2: Chạy script tối ưu hóa

```bash
ssh root@57.129.45.30 "chmod +x /tmp/optimize-db.sh && /tmp/optimize-db.sh"
```

### Bước 3: Kiểm tra tốc độ phản hồi sau tối ưu

```bash
ssh root@57.129.45.30 "curl -o /dev/null -s -w 'Time Total: %{time_total}s\n' https://tradingview.com.vn"
```
