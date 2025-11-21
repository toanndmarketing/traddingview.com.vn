# 🎯 Hướng dẫn Cài đặt Submenu cho "Phân tích"

## Tổng quan
Tạo dropdown submenu cho menu "Phân tích" với các mục con: Thị Trường Hôm Nay, Vàng, Tiền Tệ, Bạc, Dầu.

---

## 📋 Bước 1: Cấu hình Navigation trong Ghost Admin

1. Đăng nhập Ghost Admin: `https://tradingview.com.vn/ghost`
2. Vào **Settings** → **Navigation**
3. Đảm bảo có menu "Phân tích" với URL: `#` (hoặc `/tag/phan-tich/`)
4. Click **Save**

---

## 💻 Bước 2: Thêm Code vào Code Injection

### 2.1. Thêm CSS vào Site Header

Vào **Settings** → **Code Injection** → **Site Header**, thêm:

```html
<style>
/* Submenu Styles for Phân tích */
.nav li.has-submenu { 
    position: relative; 
}

.nav li.has-submenu > a::after { 
    content: '▾';
    margin-left: 6px;
    font-size: 12px;
    transition: transform 0.2s;
}

.nav li.has-submenu.submenu-open > a::after { 
    transform: rotate(180deg); 
}

.gh-submenu { 
    position: absolute;
    top: calc(100% + 8px);
    left: 0;
    z-index: 100;
    min-width: 220px;
    padding: 12px 0;
    list-style: none;
    background: #ffffff;
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
    opacity: 0;
    visibility: hidden;
    transform: translateY(-10px);
    transition: opacity 0.3s, transform 0.3s, visibility 0.3s;
}

.has-submenu.submenu-open .gh-submenu { 
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.gh-submenu-item { 
    margin: 0;
    padding: 0;
}

.gh-submenu-item a { 
    display: block;
    padding: 10px 20px;
    color: #15171a;
    font-size: 14px;
    font-weight: 500;
    text-decoration: none;
    transition: background-color 0.2s, color 0.2s;
}

.gh-submenu-item a:hover { 
    background-color: #f5f5f5;
    color: #FD9220;
}

/* Mobile Responsive */
@media (max-width: 767px) {
    .gh-submenu {
        position: static;
        margin: 8px 0;
        padding: 0;
        background: transparent;
        box-shadow: none;
        max-height: 0;
        overflow: hidden;
        opacity: 1;
        visibility: visible;
        transform: none;
        transition: max-height 0.3s;
    }
    
    .has-submenu.submenu-open .gh-submenu {
        max-height: 500px;
    }
    
    .gh-submenu-item a {
        padding: 12px 20px 12px 40px;
        font-size: 15px;
        color: rgba(255, 255, 255, 0.9);
    }
    
    .gh-submenu-item a:hover {
        background-color: rgba(255, 255, 255, 0.1);
        color: #ffffff;
    }
}
</style>
```

### 2.2. Thêm JavaScript vào Site Footer

Vào **Settings** → **Code Injection** → **Site Footer**, thêm vào **CUỐI CÙNG**:

```html
<script>
// Submenu Handler for Phân tích
(function() {
    'use strict';
    
    const submenuData = {
        'phan-tich': [
            { label: 'Thị Trường Hôm Nay', url: '/tag/thi-truong-hom-nay/' },
            { label: 'Vàng', url: '/tag/vang-xauusd/' },
            { label: 'Tiền Tệ', url: '/tag/tien-te-forex/' },
            { label: 'Bạc', url: '/tag/bac-xagusd/' },
            { label: 'Dầu', url: '/tag/dau-wti/' }
        ]
    };
    
    function initSubmenu() {
        const nav = document.querySelector('#navigation');
        if (!nav) {
            console.warn('Navigation not found');
            return;
        }
        
        nav.querySelectorAll('li').forEach(function(item) {
            const link = item.querySelector('a');
            if (!link) return;
            
            const href = link.getAttribute('href');
            const text = link.textContent.trim().toLowerCase();
            
            // Tìm menu "Phân tích" bằng nhiều cách
            const isPhanTichMenu = 
                item.classList.contains('nav-phan-tich') ||
                href === '#phan-tich' ||
                href === '/tag/phan-tich/' ||
                text.includes('phân tích') ||
                href === '#';
            
            if (isPhanTichMenu && submenuData['phan-tich']) {
                item.classList.add('has-submenu');
                
                // Tạo submenu
                const submenu = document.createElement('ul');
                submenu.className = 'gh-submenu';
                
                submenuData['phan-tich'].forEach(function(subitem) {
                    const li = document.createElement('li');
                    li.className = 'gh-submenu-item';
                    const a = document.createElement('a');
                    a.href = subitem.url;
                    a.textContent = subitem.label;
                    li.appendChild(a);
                    submenu.appendChild(li);
                });
                
                item.appendChild(submenu);
                
                // Desktop hover
                item.addEventListener('mouseenter', function() {
                    item.classList.add('submenu-open');
                });
                
                item.addEventListener('mouseleave', function() {
                    item.classList.remove('submenu-open');
                });
                
                // Mobile click
                link.addEventListener('click', function(e) {
                    if (window.innerWidth <= 767) {
                        e.preventDefault();
                        item.classList.toggle('submenu-open');
                    }
                });
                
                console.log('✅ Submenu initialized for:', link.textContent);
            }
        });
    }
    
    // Khởi chạy khi DOM sẵn sàng
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSubmenu);
    } else {
        initSubmenu();
    }
})();
</script>
```

---

## 🔍 Bước 3: Kiểm tra

1. Lưu tất cả thay đổi trong Code Injection
2. Mở website: `https://tradingview.com.vn/`
3. Hover vào menu "Phân tích" → Submenu sẽ hiện ra
4. Kiểm tra trên mobile (responsive)
5. Mở Console (F12) để xem log: "✅ Submenu initialized for: Phân tích"

---

## 🎨 Tùy chỉnh

### Thêm/Xóa submenu items

Chỉnh sửa mảng `submenuData` trong JavaScript:

```javascript
const submenuData = {
    'phan-tich': [
        { label: 'Tên mới', url: '/url-moi/' },
        // Thêm items khác...
    ]
};
```

### Đổi màu hover

Chỉnh sửa trong CSS:

```css
.gh-submenu-item a:hover { 
    background-color: #f5f5f5;  /* Đổi màu nền */
    color: #FD9220;              /* Đổi màu chữ */
}
```

---

## 🐛 Troubleshooting

**Submenu không hiện:**
- Kiểm tra Console (F12) có thấy log "✅ Submenu initialized" không
- Đảm bảo menu "Phân tích" có class `nav-phan-tich` hoặc URL là `#`

**CSS không áp dụng:**
- Xóa cache trình duyệt (Ctrl + Shift + Delete)
- Kiểm tra Code Injection đã Save chưa

**Mobile không hoạt động:**
- Đảm bảo CSS responsive được thêm đầy đủ
- Test lại bằng DevTools mobile emulator

---

## 📞 Hỗ trợ

Nếu cần thêm submenu cho menu khác (Điểm Tin, Tiện Điện Tử...), chỉ cần:
1. Thêm vào object `submenuData`
2. Đổi key từ `'phan-tich'` sang `'diem-tin'` chẳng hạn
3. Thêm điều kiện nhận diện trong script

---

**Version:** 1.0  
**Last Updated:** November 22, 2025  
**Author:** Ghost Theme TradingView Vietnam
