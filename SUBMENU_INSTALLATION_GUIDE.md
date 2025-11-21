# 📋 HƯỚNG DẪN CÀI ĐẶT SUBMENU CHO "PHÂN TÍCH"

## 🎯 Mục tiêu
Tạo dropdown submenu cho menu "Phân tích" với các mục:
- Thị Trường Hôm Nay
- Vàng
- Tiền Tệ
- Bạc
- Dầu

---

## 📦 CÁCH 1: Thêm vào Code Injection (Khuyến nghị)

### Bước 1: Copy CSS
Vào **Ghost Admin** → **Settings** → **Code Injection** → **Site Header**

Paste đoạn CSS sau:

```html
<style>
/* Submenu Styles */
.nav li.has-submenu { position: relative; }
.nav li.has-submenu > a::after { content: ''; display: inline-block; width: 0; height: 0; margin-left: 6px; vertical-align: middle; border-top: 4px solid currentColor; border-right: 4px solid transparent; border-left: 4px solid transparent; transition: transform 0.2s; }
.nav li.has-submenu.submenu-open > a::after { transform: rotate(180deg); }
.gh-submenu { position: absolute; top: 100%; left: 0; z-index: 100; min-width: 220px; margin: 8px 0 0; padding: 12px 0; list-style: none; background: #ffffff; border-radius: 8px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15); opacity: 0; visibility: hidden; transform: translateY(-10px); transition: opacity 0.3s, transform 0.3s, visibility 0.3s; }
.has-submenu.submenu-open .gh-submenu { opacity: 1; visibility: visible; transform: translateY(0); }
.gh-submenu-item { margin: 0; padding: 0; }
.gh-submenu-item a { display: block; padding: 10px 20px; color: #15171a; font-size: 14px; font-weight: 500; text-decoration: none; transition: background-color 0.2s, color 0.2s; }
.gh-submenu-item a:hover { background-color: #f5f5f5; color: var(--ghost-accent-color, #15171a); }
@media (max-width: 767px) {
    .gh-submenu { position: static; margin: 8px 0; padding: 0; background: transparent; box-shadow: none; opacity: 1; visibility: visible; transform: none; max-height: 0; overflow: hidden; transition: max-height 0.3s; }
    .has-submenu.submenu-open .gh-submenu { max-height: 500px; }
    .gh-submenu-item a { padding: 12px 20px 12px 40px; font-size: 15px; color: rgba(255, 255, 255, 0.85); }
    .gh-submenu-item a:hover { background-color: rgba(255, 255, 255, 0.1); color: #ffffff; }
}
</style>
```

### Bước 2: Copy JavaScript
Vào **Ghost Admin** → **Settings** → **Code Injection** → **Site Footer**

**THÊM** đoạn JavaScript sau vào **CUỐI** code hiện có (sau widget Market Sentiment):

```html
<script>
// Submenu Handler
const submenuData = {
    'phan-tich': [
        { label: 'Thị Trường Hôm Nay', url: '/tag/thi-truong-hom-nay/' },
        { label: 'Vàng', url: '/tag/vang-xauusd/' },
        { label: 'Tiền Tệ', url: '/tag/tien-te-forex/' },
        { label: 'Bạc', url: '/tag/bac-xagusd/' },
        { label: 'Dầu', url: '/tag/dau-wti/' }
    ]
};

document.addEventListener('DOMContentLoaded', function() {
    const nav = document.querySelector('#navigation');
    if (!nav) return;
    
    nav.querySelectorAll('li').forEach(function(item) {
        const link = item.querySelector('a');
        if (!link) return;
        
        if (link.getAttribute('href') === '#' || item.classList.contains('nav-phan-tich')) {
            const submenuItems = submenuData['phan-tich'];
            if (!submenuItems) return;
            
            item.classList.add('has-submenu');
            const submenu = document.createElement('ul');
            submenu.className = 'gh-submenu';
            
            submenuItems.forEach(function(subitem) {
                const li = document.createElement('li');
                li.className = 'gh-submenu-item';
                const a = document.createElement('a');
                a.href = subitem.url;
                a.textContent = subitem.label;
                li.appendChild(a);
                submenu.appendChild(li);
            });
            
            item.appendChild(submenu);
            
            item.addEventListener('mouseenter', function() {
                item.classList.add('submenu-open');
            });
            item.addEventListener('mouseleave', function() {
                item.classList.remove('submenu-open');
            });
            
            link.addEventListener('click', function(e) {
                if (window.innerWidth <= 767) {
                    e.preventDefault();
                    item.classList.toggle('submenu-open');
                }
            });
        }
    });
});
</script>
```

### Bước 3: Lưu và Kiểm tra
1. Click **Save** trong Code Injection
2. Truy cập website: https://tradingview.com.vn/
3. Hover vào menu "Phân tích" → Submenu sẽ hiển thị

---

## ✨ Tính năng

✅ **Dropdown submenu** khi hover vào "Phân tích"
✅ **Responsive** - Hoạt động tốt trên mobile
✅ **Smooth animation** - Hiệu ứng mượt mà
✅ **Tương thích** - Không ảnh hưởng code cũ
✅ **Dễ tùy chỉnh** - Chỉnh sửa submenuData để thêm/bớt menu

---

## 🔧 Tùy chỉnh

### Thêm/Bớt submenu items
Chỉnh sửa mảng `submenuData` trong JavaScript:

```javascript
const submenuData = {
    'phan-tich': [
        { label: 'Menu mới', url: '/url-moi/' },
        // Thêm items ở đây
    ]
};
```

### Thay đổi màu sắc
Chỉnh sửa CSS:

```css
.gh-submenu-item a:hover {
    background-color: #your-color;
    color: #your-text-color;
}
```

---

Bạn muốn tôi giúp paste code này vào Ghost Admin qua SSH không?

