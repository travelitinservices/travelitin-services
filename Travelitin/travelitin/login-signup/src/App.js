import {BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LoginSignup from "./Components/LoginSignup/loginsignup.jsx";
import BlankPage from "./Components/LoginSignup/BlankPage.jsx";


function App() {
  return (
    
   
      <Router>
      <Routes>
      <Route path="/" element={<LoginSignup />} />

      
        <Route path="/blank" element={
          <BlankPage/>
          } />
        
        
      </Routes>
      </Router>
      
    
    
  );
}

export default App;