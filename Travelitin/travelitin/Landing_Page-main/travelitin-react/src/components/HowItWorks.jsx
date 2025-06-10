function HowItWorks() {
  return (
    <section className="bg-[var(--section-bg)] relative overflow-hidden">
      {/* Map Background with Animation */}
      <div
        className="absolute inset-0 map-background"
        style={{
          backgroundImage: "url('https://images.unsplash.com/photo-1591627991997-0e7a97a77d6f?q=80&w=2070&auto=format&fit=crop')",
          backgroundSize: '200% 200%',
          backgroundPosition: 'center',
          zIndex: 1,
          opacity: 0.7,
        }}
      ></div>

      {/* Flight Route SVG with Animated Airplane */}
      <svg
        className="absolute inset-0"
        style={{ zIndex: 2 }}
        viewBox="0 0 1000 600"
        preserveAspectRatio="xMidYMid meet"
      >
        {/* Gradient for Path */}
        <defs>
          <linearGradient id="pathGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" style={{ stopColor: '#ffffff', stopOpacity: 0.8 }} />
            <stop offset="100%" style={{ stopColor: '#a0a0ff', stopOpacity: 0.6 }} />
          </linearGradient>
        </defs>

        {/* Realistic Flight Path */}
        <path
          id="flightPath"
          d="M900,100 C800,150 700,250 600,200 S500,300 400,250 C300,200 200,350 100,500"
          fill="none"
          stroke="url(#pathGradient)"
          strokeWidth="3" // Thinner for realism
          strokeDasharray="8,8" // Subtler dashes
          opacity="0.9"
          filter="url(#glow)" // Optional glow effect
        />

        {/* Glow Filter for Path */}
        <defs>
          <filter id="glow">
            <feGaussianBlur stdDeviation="2" result="coloredBlur" />
            <feMerge>
              <feMergeNode in="coloredBlur" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
        </defs>

        {/* Airplane Image Moving Along the Path */}
        <image
          href="assets/images/feature5.jpg"
          width="75" // Increased to 75 (250% of original 30)
          height="75" // Increased to 75 (250% of original 30)
          x="-37.5" // Adjusted offset to center (half of 75)
          y="-37.5" // Adjusted offset to center (half of 75)
          transform="rotate(180)" // Keep to correct inversion
        >
          <animateMotion
            dur="6s" // Faster animation (from 10s to 6s)
            repeatCount="indefinite"
            rotate="auto"
          >
            <mpath href="#flightPath" />
          </animateMotion>
        </image>
      </svg>

      {/* Main Content */}
      <div className="max-w-5xl mx-auto px-4 text-center relative z-10">
        <h2 className="text-3xl md:text-4xl font-semibold mb-8 animate-fade-in text-white">
          How It Works
        </h2>
        <iframe
          className="w-full rounded-lg aspect-video"
          src="https://www.youtube.com/embed/E47FGfv14Mc?autoplay=1&loop=1&mute=1&playlist=E47FGfv14Mc"
          title="How It Works Demo Video"
          frameBorder="0"
          allow="autoplay; encrypted-media"
          allowFullScreen
        ></iframe>
      </div>

      {/* Styles for Map Animation */}
      <style jsx>{`
        /* Map Background Animation */
        .map-background {
          animation: pan-map 30s infinite linear;
        }

        @keyframes pan-map {
          0% {
            background-position: 0% 0%;
          }
          50% {
            background-position: 100% 100%;
          }
          100% {
            background-position: 0% 0%;
          }
        }
      `}</style>
    </section>
  );
}

export default HowItWorks;