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
        const navHeader = document.querySelector('.gh-navigation');

        if (!nav) {
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

        // Mark navigation as loaded to show menu items
        if (navHeader) {
            navHeader.classList.add('is-dropdown-loaded');
        }
    }
    
    /**
     * Create and attach submenu to a navigation item
     * @param {HTMLElement} parentItem - The parent <li> element
     * @param {HTMLElement} parentLink - The parent <a> element
     * @param {Array} items - Array of submenu items
     * @param {string} key - Menu identifier
     */
    function createSubmenu(parentItem, parentLink, items, key) {
        // Prevent duplicate submenu creation
        if (parentItem.classList.contains('has-submenu') || parentItem.querySelector('.dropdown-menu')) {
            return;
        }

        const iconHTML = '<svg class="dropdown-icon" width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 4L6 8L10 4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path></svg>';
        
        // Add class to parent
        parentItem.classList.add('has-submenu');
        parentItem.setAttribute('data-submenu-key', key);
        
        // Add dropdown icon after link (insert into parent li)
        if (!parentItem.querySelector('.dropdown-icon')) {
            parentLink.insertAdjacentHTML('afterend', iconHTML);
        }
        
        // Get the icon element
        const dropdownIcon = parentItem.querySelector('.dropdown-icon');
        
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

            // Add empty text node for formatting
            li.appendChild(document.createTextNode('\n\t\t\t'));

            const a = document.createElement('a');
            a.className = 'nav-link';
            a.href = subitem.url;
            a.textContent = subitem.label;

            // Mark active submenu item - check both pathname and href
            const currentPath = window.location.pathname;
            const itemPath = subitem.url;
            
            // Check if current page matches this submenu item
            if (currentPath === itemPath || 
                currentPath.startsWith(itemPath) || 
                (itemPath.includes('/tag/') && currentPath.includes(itemPath))) {
                a.classList.add('active');
                console.log('Active submenu item:', subitem.label, 'Path:', itemPath);
            }

            li.appendChild(a);

            // Add line break and comment
            li.appendChild(document.createTextNode('\n\n\t\t\t'));
            li.appendChild(document.createComment(' Thêm dropdown menu cho mục "' + parentLink.textContent.trim() + '" '));
            li.appendChild(document.createTextNode('\n\t\t'));

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
        
        // Mobile: Toggle on click (both link and icon)
        const handleMobileToggle = function(e) {
            if (isMobile()) {
                e.preventDefault();
                e.stopPropagation();
                
                // Close other open submenus
                document.querySelectorAll('.has-submenu.submenu-open').forEach(function(openItem) {
                    if (openItem !== parentItem) {
                        openItem.classList.remove('submenu-open');
                    }
                });
                
                // Toggle current submenu with smooth transition
                const wasOpen = parentItem.classList.contains('submenu-open');
                parentItem.classList.toggle('submenu-open');
                
                // Add animation class
                if (!wasOpen) {
                    submenu.style.display = 'block';
                    requestAnimationFrame(() => {
                        submenu.classList.add('is-animating');
                    });
                } else {
                    submenu.classList.remove('is-animating');
                }
            }
        };
        
        // Attach click event to both link and icon
        parentLink.addEventListener('click', handleMobileToggle);
        if (dropdownIcon) {
            dropdownIcon.addEventListener('click', handleMobileToggle);
        }
        
        // Close submenu when clicking outside (only on mobile)
        const handleOutsideClick = function(e) {
            if (!parentItem.contains(e.target) && isMobile() && parentItem.classList.contains('submenu-open')) {
                parentItem.classList.remove('submenu-open');
                submenu.classList.remove('is-animating');
            }
        };
        
        document.addEventListener('click', handleOutsideClick);
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
     * Disabled to prevent duplicate submenu creation
     */
    // const observer = new MutationObserver(function(mutations) {
    //     mutations.forEach(function(mutation) {
    //         if (mutation.type === 'childList') {
    //             const nav = document.querySelector('#navigation');
    //             if (nav && !nav.querySelector('.has-submenu')) {
    //                 initSubmenu();
    //             }
    //         }
    //     });
    // });

    // // Start observing
    // if (document.body) {
    //     observer.observe(document.body, {
    //         childList: true,
    //         subtree: true
    //     });
    // }
})();
