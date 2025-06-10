import { useEffect, useRef } from 'react';

function Hero() {
  const textContainerRef = useRef(null);

  useEffect(() => {
    const handleScroll = () => {
      if (textContainerRef.current) {
        const scrollPosition = window.scrollY;
        textContainerRef.current.style.transform = `translateY(${-scrollPosition * 0.2}px)`;
      }
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <section className="relative min-h-screen flex items-center justify-center text-center" style={{ backgroundColor: 'var(--hero-bg)' }}>
      <div className="absolute inset-0">
        <img
          src="/assets/images/hero.jpg"
          alt="Traveler with phone in beautiful location"
          className="w-full h-full object-cover opacity-70"
        />
        <div className="absolute inset-0 bg-gradient-to-b from-[var(--secondary)] to-transparent opacity-50"></div>
      </div>
      <div className="relative z-10 max-w-5xl mx-auto px-4">
        <div ref={textContainerRef}>
          <h1 className="text-4xl md:text-6xl font-bold mb-6 animate-fade-in">
            Stay Safe, Travel Smart. Anywhere. Anytime.
          </h1>
          <p className="text-lg md:text-2xl mb-10 text-black-600 animate-slide-in-up">
            Travelitin is your personal safety companion – delivering real-time alerts, emergency tools, and smart tips based on your location and behavior.
          </p>
          <button className="button-primary animate-fade-in">
            Try Now
          </button>
        </div>
        <div className="absolute top-20 left-20 animate-float" style={{ animationDelay: '0s' }}>
          <svg className="h-12 w-12 text-[var(--primary)]" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth="1.5">
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div className="absolute top-40 right-20 animate-float" style={{ animationDelay: '1s' }}>
          <svg className="h-12 w-12 text-[var(--primary)]" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth="1.5">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 20l-5.447-2.724A2 2 0 013 15.382V5.618a2 2 0 011.553-1.894L9 2m0 18l6-9-6-9m0 18h6" />
          </svg>
        </div>
        <div className="absolute bottom-20 left-40 animate-float" style={{ animationDelay: '2s' }}>
          <svg className="h-12 w-12 text-[var(--primary)]" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth="1.5">
            <path strokeLinecap="round" strokeLinejoin="round" d="M12 2a10 10 0 00-7.071 17.071M12 2a10 10 0 017.071 17.071M12 2v4m0 12v4m-4-4h8m-10-2h12" />
          </svg>
        </div>
      </div>
    </section>
  );
}

export default Hero;