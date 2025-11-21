# ⚡ QUICK START: Submenu cho "Phân tích"

## TL;DR - 3 phút cài đặt

### Bước 1: Vào Ghost Admin
```
https://tradingview.com.vn/ghost
→ Settings → Code Injection
```

### Bước 2: Copy-Paste CSS (Site Header)

```html
<style>
.nav li.has-submenu{position:relative}.nav li.has-submenu>a::after{content:'▾';margin-left:6px;font-size:12px;transition:transform .2s ease;display:inline-block}.nav li.has-submenu.submenu-open>a::after{transform:rotate(180deg)}.gh-submenu{position:absolute;top:calc(100% + 8px);left:0;z-index:100;min-width:220px;margin:0;padding:12px 0;list-style:none!important;background:#fff;border-radius:8px;box-shadow:0 4px 20px rgba(0,0,0,.15);opacity:0;visibility:hidden;transform:translateY(-10px);transition:opacity .3s ease,transform .3s ease,visibility .3s ease}.has-submenu.submenu-open .gh-submenu,.has-submenu:hover .gh-submenu{opacity:1;visibility:visible;transform:translateY(0)}.gh-submenu-item{margin:0;padding:0;list-style:none}.gh-submenu-item a{display:block;padding:10px 20px;color:#15171a;font-size:14px;font-weight:500;text-decoration:none;transition:background-color .2s ease,color .2s ease;line-height:1.5}.gh-submenu-item a:hover{background-color:#f5f5f5;color:#FD9220}@media(max-width:767px){.gh-submenu{position:static;margin:8px 0;padding:0;background:0 0;box-shadow:none;max-height:0;overflow:hidden;opacity:1;visibility:visible;transform:none;transition:max-height .3s ease}.has-submenu.submenu-open .gh-submenu{max-height:500px}.gh-submenu-item a{padding:12px 20px 12px 40px;font-size:15px;color:rgba(255,255,255,.9)}.gh-submenu-item a:hover{background-color:rgba(255,255,255,.1);color:#fff}}
</style>
```

### Bước 3: Copy-Paste JS (Site Footer)

```html
<script>
!function(){"use strict";const e={["phan-tich"]:[{label:"Thị Trường Hôm Nay",url:"/tag/thi-truong-hom-nay/"},{label:"Vàng",url:"/tag/vang-xauusd/"},{label:"Tiền Tệ",url:"/tag/tien-te-forex/"},{label:"Bạc",url:"/tag/bac-xagusd/"},{label:"Dầu",url:"/tag/dau-wti/"}]};function t(t,n,a,l){t.classList.add("has-submenu");const s=document.createElement("ul");s.className="gh-submenu",s.setAttribute("aria-label","Submenu"),a.forEach((function(e){const t=document.createElement("li");t.className="gh-submenu-item";const n=document.createElement("a");n.href=e.url,n.textContent=e.label,window.location.pathname.includes(e.url)&&n.classList.add("active"),t.appendChild(n),s.appendChild(t)})),t.appendChild(s),t.addEventListener("mouseenter",(function(){t.classList.add("submenu-open")})),t.addEventListener("mouseleave",(function(){t.classList.remove("submenu-open")})),n.addEventListener("click",(function(e){(()=>window.innerWidth<=767)()&&(e.preventDefault(),document.querySelectorAll(".has-submenu.submenu-open").forEach((function(e){e!==t&&e.classList.remove("submenu-open")})),t.classList.toggle("submenu-open"))})),document.addEventListener("click",(function(e){t.contains(e.target)||(()=>window.innerWidth<=767)()||t.classList.remove("submenu-open")})),console.log("✅ Submenu initialized for:",n.textContent.trim())}function n(){const n=document.querySelector("#navigation");n?(console.log("[Submenu] Processing navigation items"),n.querySelectorAll("li").forEach((function(n){const a=n.querySelector("a");if(!a)return;const l=a.getAttribute("href")||"",s=a.textContent.trim().toLowerCase(),u=n.className;Object.keys(e).forEach((function(o){(u.includes("nav-"+o)||l.includes("/"+o+"/")||l==="#"+o||s.includes(o.replace(/-/g," ")))&&e[o]&&t(n,a,e[o],o)}))}))):console.warn("[Submenu] Navigation element not found")}"loading"===document.readyState?document.addEventListener("DOMContentLoaded",n):n(),console.log("[Submenu] Script loaded")}();
</script>
```

### Bước 4: Lưu & Kiểm tra
1. Click **Save**
2. Mở `https://tradingview.com.vn/`
3. Hover vào "Phân tích" → ✅ Submenu hiện ra!

---

## 🎨 Tùy chỉnh nhanh

### Đổi submenu items

Trong JS, tìm và sửa:

```javascript
const e={["phan-tich"]:[
  {label:"Tên mới",url:"/tag/url-moi/"},
  // Thêm items ở đây
]};
```

### Đổi màu hover

Trong CSS, thêm:

```css
.gh-submenu-item a:hover{
  background-color: #YOUR_COLOR !important;
  color: #YOUR_TEXT_COLOR !important;
}
```

---

## 📖 Chi tiết hơn

- **Hướng dẫn đầy đủ:** `SUBMENU_GUIDE_VI.md`
- **Tích hợp vào theme:** `SUBMENU_INTEGRATION_GUIDE.md`
- **Files:** 
  - CSS: `content/themes/tradingview-v6/assets/css/submenu.css`
  - JS: `content/themes/tradingview-v6/assets/js/submenu.js`

---

## ❓ Không hoạt động?

1. Xóa cache browser (Ctrl + Shift + Delete)
2. Hard refresh (Ctrl + F5)
3. Mở Console (F12), tìm log "✅ Submenu initialized"
4. Nếu vẫn lỗi, xem `SUBMENU_INTEGRATION_GUIDE.md` → Troubleshooting

---

**Version:** 1.0.0  
**Updated:** Nov 22, 2025
