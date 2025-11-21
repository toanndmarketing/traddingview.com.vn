/**
 * Ghost Navigation Submenu Handler
 * File: submenu.js
 * Version: 1.0.0
 * Purpose: Add dropdown submenu functionality to Ghost navigation
 * 
 * Usage:
 * 1. Define submenu items in submenuData object
 * 2. Include this script in theme or Code Injection
 * 3. Script auto-detects parent menu items and attaches submenus
 */

(function() {
    'use strict';
    
    /**
     * Submenu configuration
     * Key: Menu identifier (slug, class, or text)
     * Value: Array of submenu items with label and url
     */
    const submenuData = {
        'phan-tich': [
            { label: 'Thị Trường Hôm Nay', url: '/tag/thi-truong-hom-nay/' },
            { label: 'Vàng', url: '/tag/vang-xauusd/' },
            { label: 'Tiền Tệ', url: '/tag/tien-te-forex/' },
            { label: 'Bạc', url: '/tag/bac-xagusd/' },
            { label: 'Dầu', url: '/tag/dau-wti/' }
        ],
        // Add more submenus here as needed
        // 'diem-tin': [
        //     { label: 'Breaking News', url: '/tag/breaking/' },
        //     { label: 'Analysis', url: '/tag/analysis/' }
        // ]
    };
    
    /**
     * Initialize submenu functionality
     */
    function initSubmenu() {
        const nav = document.querySelector('#navigation');
        
        if (!nav) {
            console.warn('[Submenu] Navigation element not found');
            return;
        }
        
        // Process each navigation item
        nav.querySelectorAll('li').forEach(function(item) {
            const link = item.querySelector('a');
            if (!link) return;
            
            const href = link.getAttribute('href') || '';
            const text = link.textContent.trim().toLowerCase();
            const itemClasses = item.className;
            
            // Check if this item should have a submenu
            Object.keys(submenuData).forEach(function(key) {
                const isMatch = 
                    itemClasses.includes('nav-' + key) ||
                    href.includes('/' + key + '/') ||
                    href === '#' + key ||
                    text.includes(key.replace(/-/g, ' '));
                
                if (isMatch && submenuData[key]) {
                    createSubmenu(item, link, submenuData[key], key);
                }
            });
        });
    }
    
    /**
     * Create and attach submenu to a navigation item
     * @param {HTMLElement} parentItem - The parent <li> element
     * @param {HTMLElement} parentLink - The parent <a> element
     * @param {Array} items - Array of submenu items
     * @param {string} key - Menu identifier
     */
    function createSubmenu(parentItem, parentLink, items, key) {
        // Add class to parent
        parentItem.classList.add('has-submenu');
        
        // Add dropdown icon after link text
        const dropdownIcon = document.createElement('svg');
        dropdownIcon.className = 'dropdown-icon';
        dropdownIcon.setAttribute('width', '12');
        dropdownIcon.setAttribute('height', '12');
        dropdownIcon.setAttribute('viewBox', '0 0 12 12');
        dropdownIcon.setAttribute('fill', 'none');
        dropdownIcon.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
        dropdownIcon.innerHTML = '<path d="M2 4L6 8L10 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"></path>';
        parentLink.parentNode.insertBefore(dropdownIcon, parentLink.nextSibling);
        
        // Create submenu container
        const submenu = document.createElement('ul');
        submenu.className = 'dropdown-menu';
        submenu.setAttribute('aria-label', 'Submenu');
        
        // Add submenu items
        items.forEach(function(subitem) {
            // Create proper slug from label
            const slug = subitem.label
                .toLowerCase()
                .normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '') // Remove diacritics
                .replace(/đ/g, 'd')
                .replace(/\s+/g, '-');
            
            const li = document.createElement('li');
            li.className = 'nav-item nav-' + slug;
            
            const a = document.createElement('a');
            a.className = 'nav-link';
            a.href = subitem.url;
            a.textContent = subitem.label;
            
            // Mark active submenu item
            if (window.location.pathname.includes(subitem.url)) {
                a.classList.add('active');
            }
            
            li.appendChild(a);
            submenu.appendChild(li);
        });
        
        // Attach submenu to parent
        parentItem.appendChild(submenu);
        
        // Desktop: Show/hide on hover
        parentItem.addEventListener('mouseenter', function() {
            parentItem.classList.add('submenu-open');
        });
        
        parentItem.addEventListener('mouseleave', function() {
            parentItem.classList.remove('submenu-open');
        });
        
        // Mobile: Toggle on click
        parentLink.addEventListener('click', function(e) {
            if (isMobile()) {
                e.preventDefault();
                
                // Close other open submenus
                document.querySelectorAll('.has-submenu.submenu-open').forEach(function(openItem) {
                    if (openItem !== parentItem) {
                        openItem.classList.remove('submenu-open');
                    }
                });
                
                // Toggle current submenu
                parentItem.classList.toggle('submenu-open');
            }
        });
        
        // Close submenu when clicking outside
        document.addEventListener('click', function(e) {
            if (!parentItem.contains(e.target) && isMobile()) {
                parentItem.classList.remove('submenu-open');
            }
        });
        
        console.log('✅ Submenu initialized for:', parentLink.textContent.trim());
    }
    
    /**
     * Check if device is mobile
     * @returns {boolean}
     */
    function isMobile() {
        return window.innerWidth <= 767;
    }
    
    /**
     * Handle window resize
     */
    let resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            // Close all submenus on resize
            document.querySelectorAll('.has-submenu.submenu-open').forEach(function(item) {
                item.classList.remove('submenu-open');
            });
        }, 250);
    });
    
    /**
     * Initialize when DOM is ready
     */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSubmenu);
    } else {
        initSubmenu();
    }
    
    /**
     * Re-initialize on navigation change (for SPA-like themes)
     */
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.type === 'childList') {
                const nav = document.querySelector('#navigation');
                if (nav && !nav.querySelector('.has-submenu')) {
                    initSubmenu();
                }
            }
        });
    });
    
    // Start observing
    if (document.body) {
        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }
    
    console.log('[Submenu] Script loaded');
})();
