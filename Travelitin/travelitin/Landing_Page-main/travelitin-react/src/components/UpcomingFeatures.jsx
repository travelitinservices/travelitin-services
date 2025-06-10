import { useEffect, useRef } from "react";

function UpcomingFeatures() {
  const upcomingFeatures = [
    {
      title: "AI-Powered Risk Prediction",
      description:
        "Using advanced AI, Travelitin will predict potential risks at your destination by analyzing historical data, weather patterns, and local news in real-time. Get proactive safety recommendations before you even arrive.",
      side: "left",
    },
    {
      title: "Smart Language Assistance",
      description:
        "Break language barriers with real-time translation and cultural phrase guides tailored to your location. Communicate confidently with locals during emergencies or casual interactions.",
      side: "right",
    },
    {
      title: "Health & Wellness Alerts",
      description:
        "Stay healthy on the go with personalized health alerts, including air quality updates, vaccination reminders, and nearby medical facilities, all tailored to your travel itinerary.",
      side: "left",
    },
  ];

  const canvasRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext("2d");
    let width, height;
    let animationFrameId;

    const particles = [];
    const PARTICLE_COUNT = 30;

    function random(min, max) {
      return Math.random() * (max - min) + min;
    }

    class Particle {
      constructor() {
        this.reset();
      }
      reset() {
        this.x = random(0, width);
        this.y = random(0, height);
        this.radius = random(10, 25);
        this.alpha = random(0.05, 0.15);
        this.alphaChange = 0.002 * (Math.random() > 0.5 ? 1 : -1);
        this.speedX = random(-0.2, 0.2);
        this.speedY = random(-0.05, 0.05);
      }
      update() {
        this.x += this.speedX;
        this.y += this.speedY;
        this.alpha += this.alphaChange;
        if (this.alpha <= 0.02 || this.alpha >= 0.15) this.alphaChange *= -1;
        if (this.x < -this.radius) this.x = width + this.radius;
        if (this.x > width + this.radius) this.x = -this.radius;
        if (this.y < -this.radius) this.y = height + this.radius;
        if (this.y > height + this.radius) this.y = -this.radius;
      }
      draw() {
        const gradient = ctx.createRadialGradient(
          this.x,
          this.y,
          0,
          this.x,
          this.y,
          this.radius
        );
        gradient.addColorStop(0, `rgba(45,156,219,${this.alpha})`);
        gradient.addColorStop(1, "rgba(45,156,219,0)");
        ctx.fillStyle = gradient;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    function setup() {
      width = canvas.clientWidth;
      height = canvas.clientHeight;
      canvas.width = width * devicePixelRatio;
      canvas.height = height * devicePixelRatio;
      ctx.scale(devicePixelRatio, devicePixelRatio);

      particles.length = 0;
      for (let i = 0; i < PARTICLE_COUNT; i++) {
        particles.push(new Particle());
      }
    }

    function animate() {
      ctx.clearRect(0, 0, width, height);
      particles.forEach((p) => {
        p.update();
        p.draw();
      });
      animationFrameId = requestAnimationFrame(animate);
    }

    setup();
    animate();

    window.addEventListener("resize", () => {
      setup();
    });

    return () => {
      window.removeEventListener("resize", setup);
      cancelAnimationFrame(animationFrameId);
    };
  }, []);

  return (
    <section
      className="relative overflow-hidden py-16"
      style={{
        background:
          "radial-gradient(circle at center, #e0f3ff 0%, #ffffff 80%)",
        minHeight: "650px",
      }}
    >
      {/* Canvas for background particles */}
      <canvas
        ref={canvasRef}
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          pointerEvents: "none",
          zIndex: 0,
        }}
      />

      <div
        className="max-w-5xl mx-auto px-6 relative"
        style={{ zIndex: 10 }}
      >
        <h2 className="text-3xl md:text-4xl font-semibold mb-4 animate-fade-in text-center text-[var(--primary)]">
          Future Features for Smarter Travel
        </h2>
        <p className="text-lg md:text-xl mb-12 animate-slide-in-up text-gray-700 text-center max-w-3xl mx-auto">
          Innovating today for smarter travel tomorrow.
        </p>

        {/* Vertical timeline line */}
        <div className="relative">
          <div className="absolute left-1/2 top-0 transform -translate-x-1/2 w-1 bg-gray-300 h-full"></div>

          {/* Timeline items */}
          {upcomingFeatures.map((feature, index) => {
            const isLeft = feature.side === "left";
            return (
              <div
                key={index}
                className={`flex flex-col md:flex-row items-center mb-16 relative ${
                  isLeft ? "md:flex-row" : "md:flex-row-reverse"
                }`}
                style={{ perspective: "1000px" }}
              >
                {/* Marker */}
                <div
                  className="timeline-marker"
                  style={{
                    position: "absolute",
                    left: "50%",
                    top: "50%",
                    transform: "translate(-50%, -50%)",
                    width: "24px",
                    height: "24px",
                    borderRadius: "50%",
                    backgroundColor: "var(--primary, #2d9cdb)",
                    border: "3px solid white",
                    boxShadow: "0 0 12px var(--primary, #2d9cdb)",
                    zIndex: 20,
                    animation: "pulse 2.5s infinite",
                  }}
                ></div>

                {/* Content card */}
                <div
                  className={`feature-card w-full md:w-1/2 p-6 bg-white rounded-lg shadow-lg transition-transform duration-700 ease-in-out animate-slide-${
                    isLeft ? "from-left" : "from-right"
                  }`}
                  style={{ zIndex: 10 }}
                >
                  <h3 className="text-xl font-semibold mb-3">{feature.title}</h3>
                  <p className="text-base text-gray-700">{feature.description}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Styles */}
      <style jsx>{`
        @keyframes pulse {
          0% {
            box-shadow: 0 0 8px var(--primary, #2d9cdb),
              0 0 0 0 rgba(45, 156, 219, 0.7);
          }
          70% {
            box-shadow: 0 0 12px var(--primary, #2d9cdb),
              0 0 0 10px rgba(45, 156, 219, 0);
          }
          100% {
            box-shadow: 0 0 8px var(--primary, #2d9cdb),
              0 0 0 0 rgba(45, 156, 219, 0);
          }
        }

        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: translateY(10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        .animate-fade-in {
          animation: fadeIn 1s ease forwards;
        }

        @keyframes slideInUp {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        .animate-slide-in-up {
          animation: slideInUp 1s ease forwards;
        }

        @keyframes slideFromLeft {
          0% {
            opacity: 0;
            transform: translateX(-50px) scale(0.95);
          }
          100% {
            opacity: 1;
            transform: translateX(0) scale(1);
          }
        }
        @keyframes slideFromRight {
          0% {
            opacity: 0;
            transform: translateX(50px) scale(0.95);
          }
          100% {
            opacity: 1;
            transform: translateX(0) scale(1);
          }
        }

        .animate-slide-from-left {
          animation: slideFromLeft 0.8s ease forwards;
        }
        .animate-slide-from-right {
          animation: slideFromRight 0.8s ease forwards;
        }

        /* Feature card */
        .feature-card {
          border: 1px solid #e2e8f0;
          background: white;
          border-radius: 12px;
          box-shadow: 0 8px 20px rgb(0 0 0 / 0.05);
          transition: box-shadow 0.3s ease, transform 0.3s ease;
        }
        .feature-card:hover {
          box-shadow: 0 15px 40px rgb(0 0 0 / 0.1);
          transform: translateY(-6px);
        }

        /* Responsive tweaks */
        @media (max-width: 768px) {
          .timeline-marker {
            position: relative !important;
            margin: 0 auto 1rem;
            left: auto !important;
            top: auto !important;
            transform: none !important;
          }
          .feature-card {
            width: 100% !important;
          }
          div.flex.md\\:flex-row {
            flex-direction: column !important;
          }
        }
      `}</style>
    </section>
  );
}

export default UpcomingFeatures;
