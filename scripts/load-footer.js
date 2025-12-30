/**
 * Loads and injects the shared footer component into the page.
 * Automatically adjusts relative paths based on the current page's location.
 * Uses embedded HTML to work with both file:// and http:// protocols.
 */
(function() {
    // Determine the base path based on current page location
    const currentPath = window.location.pathname;
    const isInSubdirectory = currentPath.includes('/whats-new/');
    
    // Path mappings for different page locations
    const pathMappings = {
        'home': isInSubdirectory ? '../index.html' : 'index.html',
        'sweaters': isInSubdirectory ? 'sweater-pattern-main-page.html' : 'whats-new/sweater-pattern-main-page.html',
        'summer': isInSubdirectory ? 'summer-styles.html' : 'whats-new/summer-styles.html',
        'accessories': isInSubdirectory ? 'accessories.html' : 'whats-new/accessories.html',
        'about': isInSubdirectory ? '../about-me.html' : 'about-me.html',
        'test-knitting': isInSubdirectory ? '../test-knitting.html' : 'test-knitting.html'
    };
    
    // Embedded footer HTML
    const footerHTML = `
<footer>
    <div class="footer-container">
        <div>
            <h4>Join my Newsletter</h4>
            <a href="https://dashboard.mailerlite.com/forms/936047/120780277461025946/share" class="btn">Sign up here!</a>
        </div>
        <div>
            <h4>Sitemap</h4>
            <ul>
                <li><a href="index.html" data-footer-link="home">Home</a></li>
                <li><a href="whats-new/sweater-pattern-main-page.html" data-footer-link="sweaters">Sweaters</a></li>
                <li><a href="whats-new/summer-styles.html" data-footer-link="summer">Summer Styles</a></li>
                <li><a href="whats-new/accessories.html" data-footer-link="accessories">Accessories</a></li>
                <li><a href="about-me.html" data-footer-link="about">About me</a></li>
            </ul>
        </div>
        <div>
            <h4>Useful Links</h4>
            <ul>
                <li><a href="https://www.ravelry.com/stores/hook-mountain-handmade-designs">Shop on Ravelry</a></li>
                <li><a href="https://gosadi.com/designer/hookmountainhandmade">Shop on GoSadi</a></li>
                <li><a href="https://payhip.com/hookmountainhandmade">Shop on Payhip</a></li>
                <li><a href="test-knitting.html" data-footer-link="test-knitting">Open Test Knits</a></li>
            </ul>
        </div>
        <div>
            <h4>Follow Along</h4>
            <div class="social-links">
                <a href="https://www.facebook.com/hookmountainhandmade" aria-label="Facebook">
                    <svg width="20" height="20" fill="white" viewBox="0 0 24 24"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg>
                </a>
                <a href="https://www.instagram.com/hookmountainhandmade/" aria-label="Instagram">
                    <svg width="20" height="20" fill="white" viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="5" ry="5" fill="none" stroke="white" stroke-width="2"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" fill="none" stroke="white" stroke-width="2"/><circle cx="17.5" cy="6.5" r="1.5" fill="white"/></svg>
                </a>
            </div>
        </div>
    </div>
    <div class="footer-bottom">
        <p>© Hook Mountain Handmade</p>
    </div>
</footer>
    `.trim();
    
    try {
        // Create a temporary container to parse the HTML
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = footerHTML;
        const footer = tempDiv.querySelector('footer');
        
        if (!footer) {
            throw new Error('Footer element not found');
        }
        
        // Update all links with data-footer-link attributes
        footer.querySelectorAll('a[data-footer-link]').forEach(link => {
            const linkKey = link.getAttribute('data-footer-link');
            if (pathMappings[linkKey]) {
                link.href = pathMappings[linkKey];
            }
        });
        
        // Find the footer placeholder or insert before </body>
        const footerPlaceholder = document.getElementById('footer-placeholder');
        if (footerPlaceholder) {
            footerPlaceholder.replaceWith(footer);
        } else {
            // Insert before closing body tag
            document.body.appendChild(footer);
        }
    } catch (error) {
        console.error('Error loading footer:', error);
        // Fallback: show a simple footer if loading fails
        const fallbackFooter = document.createElement('footer');
        fallbackFooter.innerHTML = `
            <div class="footer-bottom">
                <p>© Hook Mountain Handmade</p>
            </div>
        `;
        const footerPlaceholder = document.getElementById('footer-placeholder');
        if (footerPlaceholder) {
            footerPlaceholder.replaceWith(fallbackFooter);
        } else {
            document.body.appendChild(fallbackFooter);
        }
    }
})();
