/**
 * Ghost Navigation Submenu Handler
 * File: submenu.js
 * Version: 2.0.0
 * Purpose: Handle touch toggle for hardcoded dropdown submenu in navigation
 */

(function() {
    'use strict';
    
    /**
     * Initialize submenu events
     */
    function initSubmenu() {
        const navHeader = document.querySelector('.gh-navigation');
        const submenus = document.querySelectorAll('.has-submenu');

        if (submenus.length === 0) return;

        submenus.forEach(function(parentItem) {
            const parentLink = parentItem.querySelector('a');
            const dropdownIcon = parentItem.querySelector('.dropdown-icon');
            const submenu = parentItem.querySelector('.dropdown-menu');
            
            if (!parentLink || !submenu) return;

            // Highlight active submenu items
            const currentPath = window.location.pathname;
            const submenuLinks = submenu.querySelectorAll('.nav-link');
            submenuLinks.forEach(function(a) {
                const itemPath = a.getAttribute('href');
                if (currentPath === itemPath || 
                    currentPath.startsWith(itemPath) || 
                    (itemPath.includes('/tag/') && currentPath.includes(itemPath))) {
                    a.classList.add('active');
                }
            });
            
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
            
            // Remove old listeners to prevent duplicates
            parentLink.removeEventListener('click', handleMobileToggle);
            if (dropdownIcon) {
                dropdownIcon.removeEventListener('click', handleMobileToggle);
            }

            // Attach new click event
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
        });

        // Mark navigation as loaded to show menu items
        if (navHeader && !navHeader.classList.contains('is-dropdown-loaded')) {
            navHeader.classList.add('is-dropdown-loaded');
        }
    }
    
    /**
     * Check if device is mobile
     * @returns {boolean}
     */
    function isMobile() {
        return window.innerWidth <= 767;
    }
    
    /**
     * Initialize when DOM is ready
     */
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSubmenu);
    } else {
        initSubmenu();
    }
    
    /**
     * Re-initialize on navigation change (when dropdown.js rebuilds menu on resize)
     */
    window.addEventListener('navigation-rebuilt', function() {
        initSubmenu();
    });
})();
