import { Link } from 'react-scroll';
import Header from './components/header';
import Hero from './components/hero';
import About from './components/About';
import WhyTravelitin from './components/WhyTravelitin';
import Features from './components/features';
import HowItWorks from './components/HowItWorks';
import UpcomingFeatures from './components/UpcomingFeatures';
import FAQ from './components/FAQ';
import FeedbackForm from './components/FeedbackForm';
import Footer from './components/footer';
import './index.css';

function App() {
  return (
    <div className="m-0 p-0">
      <Header />
      <main className="flex flex-col m-0 p-0 gap-0">
        {/* Added flex flex-col to ensure vertical stacking, and m-0 p-0 gap-0 to remove spacing */}
        <section id="home" className="m-0 p-0"><Hero /></section>
        <section id="about" className="m-0 p-0"><About /></section>
        <section id="why-travelitin" className="m-0 p-0"><WhyTravelitin /></section>
        <section id="features" className="m-0 p-0"><Features /></section>
        <section id="how-it-works" className="m-0 p-0"><HowItWorks /></section>
        <section id="upcoming-features" className="m-0 p-0"><UpcomingFeatures /></section>
        <section id="faq" className="m-0 p-0"><FAQ /></section>
        <section id="feedback" className="m-0 p-0"><FeedbackForm /></section>
      </main>
      <Footer />
    </div>
  );
}

export default App;