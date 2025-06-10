import { useState, useEffect, useRef } from 'react';
import { Link } from 'react-scroll';

function Header() {
  const [isMoreOpen, setIsMoreOpen] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const titleRef = useRef(null);

  useEffect(() => {
    const handleScroll = () => {
      if (titleRef.current) {
        const scrollPosition = window.scrollY;
        titleRef.current.style.transform = `translateY(${-scrollPosition * 0.2}px)`;
      }
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className="fixed top-0 left-0 w-full py-5 z-50 bg-[var(--background)]">
      <div className="flex items-center justify-between w-full px-6 md:px-4">
        {/* Logo and Title Container */}
        <div className="flex items-center gap-3">
          <img
            src="/assets/images/feature2.jpg"
            alt="Travelitin Logo"
            className="h-16 w-16 md:h-28 md:w-28"
          />
          <h1 ref={titleRef} className="text-xl md:text-3xl font-bold text-[var(--secondary)] animate-fade-in">
            Travelitin
          </h1>
        </div>
        {/* Hamburger Icon for Mobile */}
        <button
          className="md:hidden z-50"
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          aria-label="Toggle mobile menu"
        >
          <svg
            className="w-8 h-8 text-[var(--secondary)]"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d={isMobileMenuOpen ? "M6 18L18 6M6 6l12 12" : "M4 6h16M4 12h16m-7 6h7"}
            />
          </svg>
        </button>
        {/* Navigation Links - Desktop */}
        <nav className="hidden md:flex items-center gap-8 max-w-7xl">
          <Link to="home" smooth={true} duration={500} className="nav-link cursor-pointer">Home</Link>
          <Link to="about" smooth={true} duration={500} className="nav-link cursor-pointer">About Us</Link>
          <Link to="features" smooth={true} duration={500} className="nav-link cursor-pointer">Features</Link>
          <div className="relative">
            <button onClick={() => setIsMoreOpen(!isMoreOpen)} className="nav-link">
              More
            </button>
            {isMoreOpen && (
              <div className="absolute top-10 right-0 bg-white shadow-lg rounded-lg p-4 flex flex-col gap-2">
                <Link to="how-it-works" smooth={true} duration={500} className="nav-link cursor-pointer" onClick={() => setIsMoreOpen(false)}>
                  How It Works
                </Link>
                <Link to="upcoming-features" smooth={true} duration={500} className="nav-link cursor-pointer" onClick={() => setIsMoreOpen(false)}>
                  Upcoming Features
                </Link>
              </div>
            )}
          </div>
          <Link to="feedback" smooth={true} duration={500} className="nav-link cursor-pointer">Contact</Link>
          <Link to="home" smooth={true} duration={500}>
            <button className="button-primary">Try Now</button>
          </Link>
        </nav>
        {/* Mobile Menu */}
        <div
          className={`${
            isMobileMenuOpen ? "flex" : "hidden"
          } md:hidden absolute top-0 left-0 w-full h-screen bg-[var(--background)] flex-col items-center justify-center gap-6 z-40`}
        >
          <Link
            to="home"
            smooth={true}
            duration={500}
            className="text-2xl nav-link cursor-pointer"
            onClick={() => setIsMobileMenuOpen(false)}
          >
            Home
          </Link>
          <Link
            to="about"
            smooth={true}
            duration={500}
            className="text-2xl nav-link cursor-pointer"
            onClick={() => setIsMobileMenuOpen(false)}
          >
            About Us
          </Link>
          <Link
            to="features"
            smooth={true}
            duration={500}
            className="text-2xl nav-link cursor-pointer"
            onClick={() => setIsMobileMenuOpen(false)}
          >
            Features
          </Link>
          <div className="relative">
            <button onClick={() => setIsMoreOpen(!isMoreOpen)} className="text-2xl nav-link">
              More
            </button>
            {isMoreOpen && (
              <div className="flex flex-col gap-4 mt-4">
                <Link
                  to="how-it-works"
                  smooth={true}
                  duration={500}
                  className="text-xl nav-link cursor-pointer"
                  onClick={() => {
                    setIsMoreOpen(false);
                    setIsMobileMenuOpen(false);
                  }}
                >
                  How It Works
                </Link>
                <Link
                  to="upcoming-features"
                  smooth={true}
                  duration={500}
                  className="text-xl nav-link cursor-pointer"
                  onClick={() => {
                    setIsMoreOpen(false);
                    setIsMobileMenuOpen(false);
                  }}
                >
                  Upcoming Features
                </Link>
              </div>
            )}
          </div>
          <Link
            to="feedback"
            smooth={true}
            duration={500}
            className="text-2xl nav-link cursor-pointer"
            onClick={() => setIsMobileMenuOpen(false)}
          >
            Contact
          </Link>
          <Link to="home" smooth={true} duration={500} onClick={() => setIsMobileMenuOpen(false)}>
            <button className="button-primary text-2xl">Try Now</button>
          </Link>
        </div>
      </div>
    </header>
  );
}

export default Header;