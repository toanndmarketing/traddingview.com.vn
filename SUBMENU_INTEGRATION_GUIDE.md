# 🎯 Hướng dẫn Tích hợp Submenu vào Theme

## Cách 1: Sử dụng Code Injection (Không cần build theme)

### Ưu điểm:
- ✅ Nhanh, không cần rebuild theme
- ✅ Dễ chỉnh sửa từ Ghost Admin
- ✅ Không ảnh hưởng đến code theme gốc

### Nhược điểm:
- ❌ Tăng thời gian load trang (CSS/JS inline)
- ❌ Khó quản lý khi có nhiều custom code

### Các bước:

1. **Thêm CSS vào Site Header** (Settings → Code Injection → Site Header)
   - Copy toàn bộ nội dung từ `assets/css/submenu.css`
   - Wrap trong tag `<style>...</style>`

2. **Thêm JS vào Site Footer** (Settings → Code Injection → Site Footer)
   - Copy toàn bộ nội dung từ `assets/js/submenu.js`
   - Wrap trong tag `<script>...</script>`

3. **Cấu hình Navigation**
   - Vào Settings → Navigation
   - Thêm menu "Phân tích" với URL: `#` hoặc `/tag/phan-tich/`
   - Save

4. **Kiểm tra**
   - Mở website, hover vào "Phân tích"
   - Xem Console (F12) có log: "✅ Submenu initialized"

---

## Cách 2: Tích hợp vào Theme (Khuyến nghị cho production)

### Ưu điểm:
- ✅ Performance tốt hơn (CSS/JS được minify, cache)
- ✅ Dễ quản lý version
- ✅ Tích hợp chặt chẽ với theme

### Nhược điểm:
- ❌ Cần rebuild theme mỗi lần thay đổi
- ❌ Cần kiến thức về Ghost theme development

### Các bước:

#### Bước 1: Build Assets

```bash
# Di chuyển vào thư mục theme
cd content/themes/tradingview-v6

# Cài dependencies (nếu chưa có)
npm install

# Build CSS và JS
npm run dev
# Hoặc build một lần
gulp build
```

#### Bước 2: Include CSS trong theme

**Option A: Import vào screen.css**

Mở `assets/css/screen.css`, thêm dòng sau ở đầu file:

```css
@import "submenu.css";
```

**Option B: Link riêng trong default.hbs**

Mở `default.hbs`, thêm sau dòng link `style.css`:

```handlebars
<link rel="stylesheet" type="text/css" href="{{asset "css/submenu.css"}}">
```

#### Bước 3: Include JS trong theme

Mở `default.hbs`, tìm dòng:

```handlebars
<script src="{{asset "built/source.js"}}"></script>
```

Thêm ngay sau đó:

```handlebars
<script src="{{asset "js/submenu.js"}}"></script>
```

Hoặc để JS được minify cùng source.js, thêm vào `gulpfile.js`:

```javascript
// Không cần thay đổi gì, file submenu.js ở trong assets/js/ 
// sẽ tự động được concat vào source.js
```

#### Bước 4: Rebuild và Deploy

```bash
# Build lại theme
gulp build

# Hoặc build và tạo zip
gulp zip

# Upload file .zip lên Ghost Admin → Settings → Design → Change theme
```

---

## Cách 3: Hybrid (CSS trong theme, JS trong Code Injection)

### Khi nào dùng:
- Muốn CSS được cache tốt
- Nhưng cần linh hoạt chỉnh sửa submenu data

### Các bước:

1. **CSS**: Tích hợp vào theme (Cách 2 - Bước 2)
2. **JS**: Thêm vào Code Injection (Cách 1 - Bước 2)
3. **Lợi ích**: CSS minified, JS dễ chỉnh sửa không cần rebuild

---

## Tùy chỉnh Submenu Items

### Thêm menu mới

Trong `submenu.js`, thêm vào object `submenuData`:

```javascript
const submenuData = {
    'phan-tich': [
        { label: 'Thị Trường Hôm Nay', url: '/tag/thi-truong-hom-nay/' },
        { label: 'Vàng', url: '/tag/vang-xauusd/' },
        // ... existing items
    ],
    'diem-tin': [  // ← Thêm menu mới
        { label: 'Tin Tức 24/7', url: '/tag/tin-tuc/' },
        { label: 'Phân Tích', url: '/tag/analysis/' }
    ]
};
```

### Đổi màu submenu

Trong `submenu.css`, chỉnh sửa:

```css
.gh-submenu-item a:hover { 
    background-color: #f5f5f5;  /* Màu nền khi hover */
    color: #FD9220;              /* Màu chữ */
}
```

---

## Testing Checklist

### Desktop
- [ ] Hover vào "Phân tích" → submenu hiện
- [ ] Di chuột ra ngoài → submenu ẩn
- [ ] Click vào submenu item → chuyển trang đúng
- [ ] Kiểm tra animation mượt mà

### Mobile
- [ ] Click vào "Phân tích" → submenu expand
- [ ] Click lại → submenu collapse
- [ ] Submenu item hiển thị indent
- [ ] Touch/scroll hoạt động bình thường

### Browser Compatibility
- [ ] Chrome/Edge
- [ ] Firefox
- [ ] Safari
- [ ] Mobile browsers

---

## Troubleshooting

### Submenu không hiện

**Kiểm tra:**
1. Console có log "✅ Submenu initialized" không?
2. CSS đã load đúng chưa? (Inspect element)
3. Menu "Phân tích" có class `.nav-phan-tich` không?
4. URL của menu có đúng pattern không?

**Fix:**
- Xóa cache browser (Ctrl + Shift + Delete)
- Hard refresh (Ctrl + F5)
- Kiểm tra lại Code Injection đã Save
- Xem Console errors

### CSS không áp dụng

**Kiểm tra:**
1. File `submenu.css` có trong `assets/css/` không?
2. Đã build theme chưa? (`gulp build`)
3. Link CSS trong `default.hbs` đúng chưa?

**Fix:**
- Rebuild theme: `gulp build`
- Clear Ghost cache: Restart Ghost
- Check network tab (F12) xem CSS load failed

### JS không chạy

**Kiểm tra:**
1. Console có errors không?
2. Script load sau `source.js` chưa?
3. Navigation selector `#navigation` có tồn tại không?

**Fix:**
- Đổi vị trí script xuống cuối `</body>`
- Wrap trong `DOMContentLoaded` event
- Check navigation markup có đúng structure

---

## Performance Tips

### 1. Minify CSS/JS
```bash
# Gulp tự động minify khi build
gulp build
```

### 2. Lazy Load Submenu
Chỉ init submenu khi user hover vào menu lần đầu:

```javascript
let initialized = false;
parentItem.addEventListener('mouseenter', function() {
    if (!initialized) {
        initSubmenu();
        initialized = true;
    }
});
```

### 3. Reduce Reflows
Batch DOM operations trong `createSubmenu()`

---

## Version History

- **v1.0.0** (Nov 22, 2025): Initial release
  - CSS submenu styles
  - JS auto-detection
  - Mobile responsive
  - Multiple submenu support

---

## Tài liệu tham khảo

- [Ghost Theme Documentation](https://ghost.org/docs/themes/)
- [Ghost Navigation Helper](https://ghost.org/docs/themes/helpers/navigation/)
- [CSS Dropdown Menu Best Practices](https://www.w3.org/WAI/tutorials/menus/flyout/)

---

**Recommended:** Dùng **Cách 2** (tích hợp vào theme) cho production để tối ưu performance.
