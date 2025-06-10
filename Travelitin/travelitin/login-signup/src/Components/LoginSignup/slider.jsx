import React, { useState } from "react";
import "./slider.css";
import img1 from "../Assets/img1.jpg";
import img2 from "../Assets/img2.jpg";
import img3 from "../Assets/img3.jpg";

const ImageArray = [img1, img2, img3];

function ImageSlider() {
  const [currentIndex, setCurrentIndex] = useState(0);

  return (
    <div className="ImageSlider">
      <div className="ImageSliderContainer">
        <div className="Images">
          <img src={ImageArray[currentIndex]} className="middleImage" alt="slider-img" />
        </div>
      </div>
      <div className="dots">
        {ImageArray.map((_, index) => (
          <span 
            key={index} 
            className={`dot ${index === currentIndex ? "active" : ""}`} 
            onClick={() => setCurrentIndex(index)}
          ></span>
        ))}
      </div>
    </div>
  );
}

export default ImageSlider;