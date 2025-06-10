function FeedbackForm() {
  return (
    <section className="relative overflow-hidden min-h-screen bg-gradient-to-tr from-sky-300 via-blue-100 to-white py-16">
      {/* Animated Clouds */}
      <div className="cloud cloud-1" />
      <div className="cloud cloud-2" />
      <div className="cloud cloud-3" />

      {/* Animated Airplanes */}
      <div className="airplane plane-1" />
      <div className="airplane plane-2" />

      {/* Feedback Form */}
      <div className="max-w-5xl mx-auto px-4 text-center relative z-10">
        <h2 className="text-4xl font-extrabold mb-12 text-gray-900 animate-fade-in tracking-wide">
          Feedback
        </h2>
        <div
          className="max-w-md mx-auto bg-gradient-to-br from-white via-gray-50 to-gray-100 p-10 rounded-2xl 
          shadow-xl border border-gray-200 hover:shadow-2xl transition-shadow duration-500 relative"
        >
          <form className="space-y-7">
            {/* Name */}
            <div className="relative group">
              <input
                type="text"
                id="name"
                placeholder=" "
                className="peer w-full px-5 py-4 rounded-lg border border-gray-300 
                  text-gray-900 placeholder-transparent
                  focus:outline-none focus:ring-2 focus:ring-[var(--primary)] 
                  focus:border-transparent transition duration-300 shadow-sm"
                required
              />
              <label
                htmlFor="name"
                className="absolute left-5 top-4 text-gray-400 text-sm
                  peer-placeholder-shown:top-4 peer-placeholder-shown:text-base
                  peer-placeholder-shown:text-gray-400 peer-focus:top-1 peer-focus:text-[var(--primary)]
                  peer-focus:text-sm transition-all pointer-events-none"
              >
                Name
              </label>
            </div>

            {/* Email */}
            <div className="relative group">
              <input
                type="email"
                id="email"
                placeholder=" "
                className="peer w-full px-5 py-4 rounded-lg border border-gray-300 
                  text-gray-900 placeholder-transparent
                  focus:outline-none focus:ring-2 focus:ring-[var(--primary)] 
                  focus:border-transparent transition duration-300 shadow-sm"
                required
              />
              <label
                htmlFor="email"
                className="absolute left-5 top-4 text-gray-400 text-sm
                  peer-placeholder-shown:top-4 peer-placeholder-shown:text-base
                  peer-placeholder-shown:text-gray-400 peer-focus:top-1 peer-focus:text-[var(--primary)]
                  peer-focus:text-sm transition-all pointer-events-none"
              >
                Email
              </label>
            </div>

            {/* Message */}
            <div className="relative group">
              <textarea
                id="message"
                placeholder=" "
                rows="5"
                className="peer w-full px-5 py-4 rounded-lg border border-gray-300
                  text-gray-900 placeholder-transparent resize-none
                  focus:outline-none focus:ring-2 focus:ring-[var(--primary)] 
                  focus:border-transparent transition duration-300 shadow-sm"
                required
              ></textarea>
              <label
                htmlFor="message"
                className="absolute left-5 top-4 text-gray-400 text-sm
                  peer-placeholder-shown:top-4 peer-placeholder-shown:text-base
                  peer-placeholder-shown:text-gray-400 peer-focus:top-1 peer-focus:text-[var(--primary)]
                  peer-focus:text-sm transition-all pointer-events-none"
              >
                Message
              </label>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              className="relative w-full py-4 bg-[var(--primary)] text-white font-semibold rounded-lg
                hover:bg-[var(--primary-dark)] transition duration-300 shadow-lg
                focus:outline-none focus:ring-4 focus:ring-[var(--primary-light)] flex items-center justify-center gap-3"
            >
              Send&nbsp;Feedback
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="w-6 h-6 stroke-white stroke-[1.5] group-hover:animate-send-plane transition-transform"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M2.5 19.5L21 12 2.5 4.5v7.5l10.5 0"
                />
              </svg>
            </button>
          </form>
        </div>
      </div>

      {/* Style */}
      <style jsx>{`
        @keyframes cloudDrift {
          0% {
            transform: translateX(-300px);
            opacity: 0.3;
          }
          50% {
            transform: translateX(50vw);
            opacity: 0.5;
          }
          100% {
            transform: translateX(120vw);
            opacity: 0.3;
          }
        }

        @keyframes planeFly {
          0% {
            transform: translateX(-150px) rotate(0deg);
            opacity: 0.6;
          }
          50% {
            transform: translateX(50vw) rotate(5deg);
            opacity: 0.8;
          }
          100% {
            transform: translateX(130vw) rotate(0deg);
            opacity: 0.6;
          }
        }

        .cloud {
          position: absolute;
          background: white;
          border-radius: 9999px;
          filter: blur(10px);
          z-index: 0;
        }

        .cloud-1 {
          width: 160px;
          height: 80px;
          top: 10%;
          left: -300px;
          animation: cloudDrift 50s linear infinite;
        }

        .cloud-2 {
          width: 220px;
          height: 110px;
          top: 25%;
          left: -400px;
          animation: cloudDrift 60s linear infinite;
          animation-delay: 10s;
        }

        .cloud-3 {
          width: 180px;
          height: 90px;
          bottom: 10%;
          left: -350px;
          animation: cloudDrift 70s linear infinite;
          animation-delay: 20s;
        }

        .airplane {
          position: absolute;
          background-image: url('airplane.png');
          background-size: contain;
          background-repeat: no-repeat;
          width: 120px;
          height: 120px;
          z-index: 1;
          opacity: 0.7;
        }

        .plane-1 {
          top: 20%;
          left: -150px;
          animation: planeFly 20s linear infinite;
        }

        .plane-2 {
          top: 60%;
          left: -200px;
          animation: planeFly 25s linear infinite;
          animation-delay: 12s;
        }

        @keyframes sendPlane {
          0% {
            transform: translateX(0) rotate(0deg);
            opacity: 1;
          }
          50% {
            transform: translateX(10px) rotate(15deg);
            opacity: 0.7;
          }
          100% {
            transform: translateX(0) rotate(0deg);
            opacity: 1;
          }
        }

        .group-hover\\:animate-send-plane:hover {
          animation: sendPlane 0.8s ease-in-out infinite;
        }
      `}</style>
    </section>
  );
}

export default FeedbackForm;
