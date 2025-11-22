# HƯỚNG DẪN NHÚNG MÃ VÀO TRANG ĐIỂM TIN

## Bước 1: Truy cập Ghost Admin
1. Vào http://localhost:3000/ghost
2. Đăng nhập vào Ghost Admin

## Bước 2: Tìm/Tạo Page "Điểm Tin"
1. Vào **Pages** từ menu bên trái
2. Tìm page có slug `/diem-tin/`
3. Hoặc tạo page mới:
   - Click **New Page**
   - Title: `Điểm Tin 247`
   - URL (slug): `diem-tin`

## Bước 3: Chọn Custom Template
1. Trong page editor, click vào **Settings** (icon ⚙️ góc phải)
2. Tìm mục **Template**
3. Chọn: `widget` (hoặc `custom-widget-fullwidth`)
4. Click **Done** để lưu settings

## Bước 4: Nhúng mã HTML
1. Trong page editor, click vào nút **⋯** (3 chấm) ở góc phải
2. Chọn **HTML** hoặc **Code injection**
3. Copy toàn bộ nội dung từ file:
   - `TEMPLATE_DIEM_TIN_SIMPLE.html` (có dữ liệu mẫu - dùng để test)
   - Hoặc `TEMPLATE_DIEM_TIN.html` (kết nối API thật)
4. Paste vào HTML editor
5. Click **Update** để lưu

## Bước 5: Xuất bản
1. Click nút **Publish** (hoặc **Update** nếu đã publish)
2. Xác nhận publish

## Kiểm tra kết quả
Truy cập: http://localhost:3000/diem-tin/

---

## Nếu muốn kết nối API thật:

Mở file `TEMPLATE_DIEM_TIN.html`, tìm dòng:
```javascript
const response = await fetch('YOUR_API_URL_HERE');
```

Thay thế bằng API thật của bạn, ví dụ:
```javascript
const response = await fetch('https://api.example.com/news');
```

Và điều chỉnh cách xử lý data cho phù hợp với format API của bạn.

---

## Template đã cung cấp:

1. **TEMPLATE_DIEM_TIN_SIMPLE.html**
   - Có dữ liệu mẫu sẵn (6 tin tức)
   - Dùng để test ngay lập tức
   - Responsive design với Tailwind CSS
   - Vue 3 Composition API

2. **TEMPLATE_DIEM_TIN.html**
   - Kết nối với API
   - Có loading state, error handling
   - Cần thay URL API thật

## Troubleshooting:

**Nếu gặp lỗi Vue:**
- Đảm bảo page template là `widget` hoặc `custom-widget-fullwidth`
- Template này đã có Vue 3 import sẵn

**Nếu không hiển thị:**
- Kiểm tra Console trong Developer Tools (F12)
- Kiểm tra page đã Publish chưa
- Xóa cache trình duyệt (Ctrl+Shift+R)
