import { useEffect, useRef } from "react";

function About() {
  const textRef = useRef(null);

  useEffect(() => {
    const handleScroll = () => {
      if (textRef.current) {
        const scrollPosition = window.scrollY;
        textRef.current.style.transform = `translateY(${-scrollPosition * 0.15}px)`;
      }
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <section
      id="sunset-travel"
      className="relative overflow-hidden min-h-[600px] flex items-center justify-center px-6 m-0 mt-0 pt-0"
      // Added 'mt-0' and 'pt-0' to ensure no top margin or padding
      style={{
        color: "white",
        animation: "skyColorShift 30s ease-in-out infinite alternate",
      }}
    >
      {/* Sun */}
      <div className="sun-container">
        <div className="sun-core" />
        <div className="sun-halo" />
      </div>

      {/* Mountains */}
      <svg
        className="mountains"
        viewBox="0 0 100 30"
        preserveAspectRatio="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <polygon points="0,30 15,10 30,25 45,5 60,20 75,10 90,25 100,10 100,30" />
      </svg>

      {/* Content */}
      <div
        ref={textRef}
        className="relative max-w-3xl text-center z-10"
        style={{ fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif" }}
      >
        <h2 className="text-5xl font-extrabold mb-4 drop-shadow-lg">About Us</h2>
        <p className="text-lg max-w-xl mx-auto leading-relaxed drop-shadow-md">
          We are a team passionate about travel, dedicated to making your journey
          unforgettable with Travelitin.
        </p>
      </div>

      {/* Styles */}
      <style jsx>{`
        @keyframes skyColorShift {
          0% {
            background: linear-gradient(180deg, #ffaf7b 0%, #d76d77 60%, #3a1c71 100%);
          }
          50% {
            background: linear-gradient(180deg, #ff7e5f 0%, #feb47b 60%, #654ea3 100%);
          }
          100% {
            background: linear-gradient(180deg, #ffaf7b 0%, #d76d77 60%, #3a1c71 100%);
          }
        }

        .sun-container {
          position: absolute;
          bottom: 30px;
          left: 50%;
          width: 120px;
          height: 120px;
          transform: translateX(-50%);
          animation: sunSetArc 30s linear infinite;
          z-index: 2;
          pointer-events: none;
        }

        .sun-core {
          width: 100px;
          height: 100px;
          background: radial-gradient(circle at center, #ffdd76, #ff7e00);
          border-radius: 50%;
          filter: drop-shadow(0 0 25px #ff9c00);
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          animation: sunBrightness 30s linear infinite;
        }

        .sun-halo {
          position: absolute;
          top: 50%;
          left: 50%;
          width: 140px;
          height: 140px;
          background: radial-gradient(circle, rgba(255, 190, 75, 0.4), transparent 70%);
          border-radius: 50%;
          filter: blur(40px);
          transform: translate(-50%, -50%);
          animation: haloPulse 30s linear infinite;
        }

        @keyframes sunSetArc {
          0% {
            bottom: 120px;
            left: 75%;
            opacity: 1;
          }
          50% {
            bottom: 200px;
            left: 50%;
            opacity: 1;
          }
          90% {
            bottom: 30px;
            left: 25%;
            opacity: 0.6;
          }
          100% {
            bottom: 20px;
            left: 25%;
            opacity: 0;
          }
        }

        @keyframes sunBrightness {
          0%, 100% {
            filter: drop-shadow(0 0 15px #ff7e00);
            opacity: 0;
          }
          30%, 70% {
            filter: drop-shadow(0 0 55px #ffb347);
            opacity: 1;
          }
          50% {
            filter: drop-shadow(0 0 80px #ffc947);
            opacity: 1;
          }
        }

        @keyframes haloPulse {
          0%, 100% {
            opacity: 0;
          }
          30%, 70% {
            opacity: 0.35;
          }
          50% {
            opacity: 0.55;
          }
        }

        .mountains {
          position: absolute;
          bottom: 0;
          left: 0;
          width: 100%;
          height: 120px;
          fill: #1a1438;
          filter: drop-shadow(0 0 15px rgba(26, 20, 56, 0.7));
          pointer-events: none;
          z-index: 3;
        }

        /* Ensure no top spacing */
        section#sunset-travel {
          margin-top: 0 !important;
          padding-top: 0 !important;
          border-top: none !important;
        }
      `}</style>
    </section>
  );
}

export default About;