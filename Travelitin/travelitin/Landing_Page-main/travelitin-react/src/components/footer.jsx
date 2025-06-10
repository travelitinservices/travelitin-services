function Footer() {
  return (
    <footer style={{ backgroundColor: 'var(--footer-bg)' }}>
      <div className="max-w-5xl mx-auto px-4 py-10 text-center">
        <div className="flex justify-center gap-6 mb-6">
          <a href="#about" className="footer-link">About</a>
          <a href="#features" className="footer-link">Features</a>
          <a href="#feedback" className="footer-link">Contact</a>
          <a href="#feedback" className="footer-link">Feedback Form</a>
        </div>
        <p className="text-[var(--footer-text)] mb-4">
          Contact: <a href="mailto:travelitin@gmail.com" className="footer-link">travelitin@gmail.com</a>
        </p>
        <div className="flex justify-center gap-4 mb-6">
          <a href="#" className="text-[var(--primary)]">
            <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2a10 10 0 00-3.16 19.5c.5.09.68-.22.68-.49v-1.72c-2.78.61-3.37-1.34-3.37-1.34-.45-1.15-1.1-1.46-1.1-1.46-.9-.61.07-.6.07-.6 1 .07 1.53 1.03 1.53 1.03.89 1.53 2.34 1.09 2.91.83.09-.65.35-1.09.63-1.34-2.22-.25-4.56-1.11-4.56-4.94 0-1.09.39-1.98 1.03-2.68-.1-.25-.5-1.29.11-2.68 0 0 .85-.27 2.78 1.03A9.63 9.63 0 0112 6.5c.86 0 1.72.12 2.53.35 1.93-1.3 2.78-1.03 2.78-1.03.61 1.39.21 2.43.11 2.68.64.7 1.03 1.59 1.03 2.68 0 3.84-2.34 4.69-4.57 4.94.36.31.68.92.68 1.85v2.74c0 .27.18.58.69.49A10 10 0 0012 2z" />
            </svg>
          </a>
          <a href="#" className="text-[var(--primary)]">
            <svg className="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M22.46 6c-.77.35-1.6.58-2.46.69.88-.53 1.56-1.37 1.88-2.38-.83.5-1.75.85-2.72 1.05C18.37 4.5 17.26 4 16 4c-2.35 0-4.27 1.92-4.27 4.29 0 .34.04.67.11.98C8.28 9.09 5.11 7.38 3 4.79c-.37.63-.58 1.37-.58 2.15 0 1.49.75 2.81 1.91 3.56-.71 0-1.37-.2-1.95-.5v.03c0 2.08 1.48 3.82 3.44 4.21a4.22 4.22 0 01-1.93.07 4.28 4.28 0 004 2.98 8.58 8.58 0 01-5.29 1.83c-.34 0-.67-.02-1-.06A12.1 12.1 0 0012 21c8.24 0 12.75-6.83 12.75-12.75 0-.19 0-.38-.01-.57.87-.63 1.63-1.41 2.23-2.3z" />
            </svg>
          </a>
        </div>
        <p className="text-[var(--footer-text)] text-sm">
          © 2025 Travelitin Services Private Limited. All Rights Reserved.
        </p>
        <div className="flex justify-center gap-4 text-[var(--footer-text)] text-sm">
          <a href="#" className="footer-link">Privacy Policy</a>
          <a href="#" className="footer-link">Terms of Use</a>
        </div>
      </div>
    </footer>
  );
}

export default Footer;