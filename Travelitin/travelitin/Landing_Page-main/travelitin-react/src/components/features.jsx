import { Link } from 'react-scroll';
import { useEffect, useRef, useMemo } from 'react';

function Features() {
  const features = [
    { icon: '🛡️', title: 'Safety, Always First', description: 'Get real-time alerts on crime, natural disasters, and risky areas—wherever you are. We don’t just show maps, we show what to avoid.' },
    { icon: '🗺️', title: 'Custom Travel Planning', description: 'Whether you’re on a budget, traveling solo, or with family, get personalized itineraries that match your style and pace.' },
    { icon: '📍', title: 'Local Insights, Smarter Choices', description: 'From safety tips to cultural do’s and don’ts, make informed decisions based on real-time, local data.' },
    { icon: '⛔', title: 'Emergency Ready', description: 'One tap connects you to nearby help. Add emergency contacts, share your location.' },
    { icon: '👥', title: 'Find Travel Companions', description: 'Connect with like-minded travelers to share experiences and expenses.' },
    { icon: '💸', title: 'Expense Planning Tools', description: 'Easily track and manage your travel budget across different categories.' },
    { icon: '🚨', title: 'Scam Reporting', description: 'Report and view scams to stay vigilant and protect yourself.' },
    { icon: '🏨', title: 'Booking Help (Hotels & Travel)', description: 'Assistance finding and booking affordable and trusted accommodation and transport.' },
    { icon: '🍽️', title: 'Nearby Food Recommendations', description: 'Discover the best local eateries that match your taste and budget.' },
  ];

  const rainDrops = useMemo(() => {
    const isMobile = window.innerWidth < 768;
    const count = isMobile ? 40 : 100;

    return [...Array(count)].map((_, i) => {
      const left = Math.random() * 100;
      const delay = (Math.random() * 2).toFixed(2);
      const duration = (1 + Math.random() * 1).toFixed(2);

      return (
        <div
          key={i}
          className="raindrop"
          style={{
            position: 'absolute',
            top: '-10vh',
            left: `${left}vw`,
            width: '1.5px',
            height: '60px',
            background:
              'linear-gradient(to bottom, rgba(255,255,255,0.25), rgba(255,255,255,0))',
            filter: 'drop-shadow(0 0 2px rgba(255,255,255,0.2))',
            animation: `fall ${duration}s linear ${delay}s infinite`,
            opacity: 0.3,
            pointerEvents: 'none',
            borderRadius: '50%',
            willChange: 'transform',
          }}
        />
      );
    });
  }, []);

  return (
    <section className="relative overflow-hidden py-16 min-h-screen bg-gradient-to-br from-[#1e3c72] to-[#2a5298]">
      {/* Raindrop Background */}
      <div className="absolute inset-0 z-10 pointer-events-none">
        {rainDrops}
      </div>

      <div className="relative max-w-6xl mx-auto px-6 z-20 text-white">
        <h2 className="text-4xl font-bold text-center mb-14">Features</h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-10">
          {features.map((feature, index) => (
            <div
              key={index}
              className="bg-white bg-opacity-10 rounded-2xl p-6 shadow-lg hover:shadow-2xl transition-shadow duration-300 backdrop-blur-md"
            >
              <div className="text-5xl mb-5">{feature.icon}</div>
              <h3 className="text-xl font-semibold mb-3">{feature.title}</h3>
              <p className="leading-relaxed">{feature.description}</p>
            </div>
          ))}
        </div>

        <div className="text-center mt-16">
          <p className="text-2xl font-semibold text-indigo-200 bg-indigo-900 bg-opacity-30 inline-block px-8 py-5 rounded-lg shadow-lg">
            Try Travelitin once. You won’t want to travel without it again.
          </p>
          <div className="mt-8">
            <Link to="home" smooth={true} duration={500}>
              <button className="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 px-10 rounded-full shadow-lg transition-colors duration-300">
                Try Now
              </button>
            </Link>
          </div>
        </div>
      </div>

      <style jsx>{`
        @keyframes fall {
          0% {
            transform: translateY(0);
            opacity: 0.3;
          }
          80% {
            opacity: 0.7;
          }
          100% {
            transform: translateY(110vh);
            opacity: 0;
          }
        }
      `}</style>
    </section>
  );
}

export default Features;
