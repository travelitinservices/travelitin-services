import React, { useState } from "react";
import { useNavigate } from "react-router-dom"; 
import "./loginsignup.css";
import ImageSlider from "./slider.jsx";
import user_icon from "../Assets/user.png";
import password_icon from "../Assets/padlock.png";
import mail_icon from "../Assets/mail.png";
import axios from 'axios';
var isEmpty = require('lodash.isempty')


const LoginSignup = () => {
  const [action, setAction] = useState("Log In");
  const navigate = useNavigate(); 
  const initialValues = { user: "", email: "", password: ""};
  const [formValues,setformValues]=useState(initialValues);
  const [logres,setlogres]=useState("");
  const [pasres,setpasres]=useState("");
  



  // const poster = (datas)=>{

  //   console.log('post request is happening')


  //   const emails=datas.email

  //   axios.post('http://localhost:5050/checkuser',{emails})
  //   .then(result=>{
  //     const ret = result.data
  //     if(ret === "User already present"){
  //       return (<div>{ret}</div>)
  //     }
  //     else{
  //       const valmes = dynvalidate(datas,"Log In").email
  //       return (valmes)
  //     }
  //   })
  //   .catch(err=>console.log(err))
  // }
  

  
  const handleLogin = (dats)=>{

    const email=dats.email
    const password=dats.password
    const erres=dynvalidate(dats,"Log In")

    setlogres("")
    setpasres("")

    
    
    if(isEmpty(erres)){
      console.log("came here")
    axios.post('http://localhost:5050/login',{email,password})
    .then(result=>{

      const responder = result.data

      if(result.data==='Success'){
      console.log('Successful Login')
      
      navigate('/blank')
      }
      else{

        if(responder==="Email Not Found"){
          setlogres(responder)
        }
        else{
          setpasres(responder)
        }
        console.log('Incorrect Credentials/User not found.')
      }
} 
)

    .catch(err=>console.log(err.data))
    

}
}

  const handleSignUp =(values)=>{
    
    const user = values.user
    const email = values.email
    const password=values.password
    const result = dynvalidate(values,"Sign Up")

    
    
      
      
        if(isEmpty(result)){
        axios.post('http://localhost:5050/register',{user,email,password})
        .then(result=>console.log(result))
        .catch(err=>console.log(err))
        navigate('/blank')
        console.log('correct stuff')
        }
    

  }


  const dynvalidate = (valss,curr)=>{

    const errorss={};

    const regex = /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/;

    if(curr==="Sign Up"){
    if(!valss.user){
      errorss.username = "Username is Required!"
    }
    else if(valss.user.length<4){
      errorss.username = "Username cannot be less than 4 characters"
    }
    else if(valss.user.length>10){
      errorss.username = "Username cannot exceed 10 characters!"
    }

  }
    if(!valss.email){
      errorss.email = "Email is Required!"
    }
    else if(!regex.test(valss.email)){
      errorss.email = "Incorrect Email Format!"
    }
    if(!valss.password){
      errorss.password = "Password is Required!"
    }
    else if(valss.password.length<4){
      errorss.password= "Password cannot be less than 3 characterss"
    }
    else if(valss.password.length>12){
      errorss.password= "Password cannot exceed 12 characters!"
    }

    return errorss
  }


  return (
    
    <div className="login-container">
      <div className="container">
        <div className="header">
          <div className="text">{action}</div>
          <div className="underline"></div>
        </div>  

        <form>
          <div className="inputs">
            {action === "Log In" ? (
              <></>
            ) : (
              <div className="input">
                <img src={user_icon} alt="" />
                <input type="text" placeholder="Username" value={formValues.user}  onChange={(e)=>setformValues({user:e.target.value,email:formValues.email,password:formValues.password})}/>           
              </div>
            )}

            <div className="errmsg">
              {dynvalidate(formValues).username === "" || action === "Log In" ? (<></>) : (<p>{dynvalidate(formValues,"Sign Up").username}</p>)
                
              }
            </div>

            
            <div className="input">
              <img src={mail_icon} alt="" />
              <input
                type="email"
                placeholder="Email"
                value={formValues.email}
                onChange={(e)=>setformValues({user:formValues.user,email:e.target.value,password:formValues.password})}
              />
            </div>
      
            <div className="errs">
            {action==="Log In"? <p>{logres}</p>:<p>{dynvalidate(formValues).email}</p>}
            </div>
            
            <div className="input">
              <img src={password_icon} alt="" />
              <input
                type="password"
                placeholder="Password"
                value={formValues.password}
                onChange={(e)=>setformValues({user:formValues.user,email:formValues.email,password:e.target.value})}
              />
            </div>
            <p>{dynvalidate(formValues,"Log In").password}</p>
            <p>{pasres}</p>
          </div>
        </form>

        {action === "Sign Up" ? (
          <></>
        ) : (
          <div className="forgot-password">
            Forgot Password? <span>Click Here!</span>
          </div>
        )}
       
       
        {action === "Log In" ? (
          <div className="submit-container">
              <button className="submit" onClick={()=>handleLogin(formValues)}>Login</button>
              <button className="submit" onClick={() => setAction("Sign Up")}>Sign Up</button>
              </div>
            ) : (
              <div className="submit-container">
              <button className="submit" onClick={()=>setAction("Log In")}>Login</button>
              <button className="submit" onClick={()=>handleSignUp(formValues)}>Sign Up</button>
              </div>
            )}
          
          
        
      </div>

      <div className="slider-container">
        <ImageSlider />
      </div>
    </div>
  );
};

export default LoginSignup;