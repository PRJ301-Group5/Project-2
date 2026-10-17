    </div><!-- /container -->

    <footer class="spirit-footer">
        <div>
            <strong>Spirit</strong> &copy; 2026 · Group 5 ·
            <a href="https://github.com/PRJ301-Group5/Project-2" target="_blank" rel="noopener">PRJ301 — Java Web Application</a>
        </div>
        <div class="mt-1">
            AI Grading + Git Contribution Analytics · Spirit v2.0
        </div>
    </footer>

    <div class="loading-overlay" id="globalLoading">
        <div class="spinner-border text-light spinner-border-lg" role="status">
            <span class="visually-hidden">Loading…</span>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-submit forms (with .spirit-auto-submit) show global spinner
        document.addEventListener('submit', function (e) {
            const form = e.target;
            if (form.classList && form.classList.contains('spirit-auto-submit')) {
                document.getElementById('globalLoading')?.classList.add('active');
            }
        });
        // Buttons with .spirit-loading also trigger spinner
        document.addEventListener('click', function (e) {
            const btn = e.target.closest('.spirit-loading');
            if (btn) {
                setTimeout(() => {
                    btn.disabled = true;
                    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang xử lý…';
                }, 0);
                document.getElementById('globalLoading')?.classList.add('active');
            }
        });
    </script>
</body>
</html>
