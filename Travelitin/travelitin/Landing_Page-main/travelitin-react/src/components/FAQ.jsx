import { useState } from "react";

function FAQ() {
  const faqs = [
    {
      question: "How does Travelitin ensure my safety while traveling?",
      answer:
        "Travelitin provides real-time alerts on crime, natural disasters, and risky areas based on your location. We also offer local safety insights and one-tap emergency access to keep you prepared, wherever you are.",
    },
    {
      question: "Can I use Travelitin offline?",
      answer:
        "Yes, Travelitin offers offline access to essential features like saved itineraries and emergency contacts. However, real-time alerts and local insights require an internet connection to stay updated.",
    },
    {
      question: "Is Travelitin suitable for solo travelers?",
      answer:
        "Absolutely! Travelitin is designed with solo travelers in mind, offering safety alerts, local tips, and travel companion matching to make your journeys safe and enjoyable.",
    },
    {
      question: "How does the custom travel planning work?",
      answer:
        "Tell us your travel style, budget, and preferences, and Travelitin creates a personalized itinerary for you. From safe routes to local hotspots, we tailor every detail to match your needs.",
    },
    {
      question: "What happens if I encounter an emergency?",
      answer:
        "With one tap, Travelitin connects you to nearby help, shares your location with emergency contacts, and provides local emergency resources to ensure you get assistance quickly.",
    },
  ];

  const [openIndex, setOpenIndex] = useState(null);

  const toggleFAQ = (index) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <section className="relative py-16 px-4 overflow-hidden">
      {/* Background animation layer */}
      <div className="absolute inset-0 -z-10 bg-gradient-to-br from-indigo-900 via-blue-900 to-black animate-background-fade"></div>

      <ParticlesBackground />

      <div className="max-w-3xl mx-auto text-white relative z-10">
        <h2 className="text-3xl font-extrabold text-center mb-12">
          Frequently Asked Questions
        </h2>
        <div className="space-y-4">
          {faqs.map((faq, index) => {
            const isOpen = openIndex === index;
            return (
              <div
                key={index}
                className={`border border-indigo-600 rounded-lg bg-indigo-900 bg-opacity-30 shadow-md transition-shadow duration-300 ${
                  isOpen ? "shadow-xl border-indigo-400" : "hover:shadow-lg"
                }`}
              >
                <button
                  onClick={() => toggleFAQ(index)}
                  aria-expanded={isOpen}
                  aria-controls={`faq-panel-${index}`}
                  id={`faq-header-${index}`}
                  className="flex items-center justify-between w-full px-6 py-4 text-left focus:outline-none focus-visible:ring-2 focus-visible:ring-indigo-400 rounded-lg"
                >
                  <span className="text-lg font-semibold">{faq.question}</span>
                  <span className="ml-4 text-indigo-300 flex-shrink-0">
                    {isOpen ? (
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-6 w-6"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M20 12H4"
                        />
                      </svg>
                    ) : (
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-6 w-6"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M12 4v16m8-8H4"
                        />
                      </svg>
                    )}
                  </span>
                </button>
                {isOpen && (
                  <div
                    id={`faq-panel-${index}`}
                    role="region"
                    aria-labelledby={`faq-header-${index}`}
                    className="px-6 pb-6 text-indigo-200 text-base leading-relaxed"
                  >
                    <p>{faq.answer}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Optional shimmer effect overlay */}
      <div className="absolute inset-0 pointer-events-none shimmer"></div>

      <style jsx>{`
        /* Animate background gradient subtle shift */
        @keyframes background-fade {
          0%, 100% {
            background-position: 0% 50%;
          }
          50% {
            background-position: 100% 50%;
          }
        }

        .animate-background-fade {
          background-size: 200% 200%;
          animation: background-fade 30s ease infinite;
        }

        /* Particle effect with CSS */
        .particles {
          position: absolute;
          top: 0; left: 0; right: 0; bottom: 0;
          pointer-events: none;
          overflow: hidden;
          z-index: -5;
        }
        .particle {
          position: absolute;
          background: rgba(255 255 255 / 0.15);
          border-radius: 50%;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          opacity: 0.8;
          filter: drop-shadow(0 0 2px rgba(255 255 255 / 0.2));
        }

        /* shimmer effect overlay */
        .shimmer {
          background: linear-gradient(
            120deg,
            rgba(255, 255, 255, 0.05) 0%,
            rgba(255, 255, 255, 0.15) 50%,
            rgba(255, 255, 255, 0.05) 100%
          );
          background-size: 200% 100%;
          animation: shimmer 5s linear infinite;
          pointer-events: none;
          mix-blend-mode: screen;
        }
        @keyframes shimmer {
          0% {
            background-position: 200% 0%;
          }
          100% {
            background-position: -200% 0%;
          }
        }
      `}</style>
    </section>
  );
}

// Separate component to render moving particles in background
function ParticlesBackground() {
  // We'll create an array for particles with random position, size, and animation duration
  const particlesCount = 25;
  const particles = Array.from({ length: particlesCount });

  return (
    <div className="particles" aria-hidden="true">
      {particles.map((_, i) => {
        // Random size between 4 and 10 px
        const size = Math.random() * 6 + 4;
        // Random animation duration between 20s and 40s
        const duration = Math.random() * 20 + 20;
        // Random start delay to spread animations
        const delay = Math.random() * 40;
        // Random position on screen (percentage)
        const top = Math.random() * 100;
        const left = Math.random() * 100;

        return (
          <span
            key={i}
            className="particle"
            style={{
              width: size,
              height: size,
              top: `${top}%`,
              left: `${left}%`,
              animationName: "particleMove",
              animationDuration: `${duration}s`,
              animationDelay: `${delay}s`,
            }}
          />
        );
      })}
      <style jsx>{`
        @keyframes particleMove {
          0% {
            transform: translateY(0) translateX(0);
            opacity: 0.8;
          }
          50% {
            transform: translateY(-15px) translateX(10px);
            opacity: 0.5;
          }
          100% {
            transform: translateY(0) translateX(0);
            opacity: 0.8;
          }
        }
      `}</style>
    </div>
  );
}

export default FAQ;
