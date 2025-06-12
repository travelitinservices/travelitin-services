import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./loginsignup.css";
import user_icon from "../Assets/user.png";
import password_icon from "../Assets/padlock.png";
import mail_icon from "../Assets/mail.png";
import logo from "../Assets/logo.png";
import axios from 'axios';
import isEmpty from 'lodash.isempty';

const LoginSignup = () => {
  const [action, setAction] = useState("Log In");
  const [formFade, setFormFade] = useState(false);
  const [formValues, setformValues] = useState({ user: "", email: "", password: "" });
  const [submitted, setSubmitted] = useState(false);
  const [logres, setlogres] = useState("");
  const [pasres, setpasres] = useState("");
  const navigate = useNavigate();

  const dynvalidate = (valss, curr) => {
    const errorss = {};
    const regex = /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/;

    if (curr === "Sign Up") {
      if (!valss.user) {
        errorss.username = "Username is Required!";
      } else if (valss.user.length < 4) {
        errorss.username = "Username must be at least 4 characters!";
      } else if (valss.user.length > 10) {
        errorss.username = "Username cannot exceed 10 characters!";
      }
    }

    if (!valss.email) {
      errorss.email = "Email is Required!";
    } else if (!regex.test(valss.email)) {
      errorss.email = "Incorrect Email Format!";
    }

    if (!valss.password) {
      errorss.password = "Password is Required!";
    } else if (valss.password.length < 4) {
      errorss.password = "Password must be at least 4 characters!";
    } else if (valss.password.length > 12) {
      errorss.password = "Password cannot exceed 12 characters!";
    }

    return errorss;
  };

  const handleLogin = (dats) => {
    setSubmitted(true);
    const erres = dynvalidate(dats, "Log In");

    setlogres("");
    setpasres("");

    if (isEmpty(erres)) {
      axios.post('http://localhost:5050/login', {
        email: dats.email,
        password: dats.password
      })
        .then(res => {
          const resp = res.data;
          if (resp === "Success") navigate('/blank');
          else if (resp === "Email Not Found") setlogres(resp);
          else setpasres(resp);
        })
        .catch(console.log);
    }
  };

  const handleSignUp = (values) => {
    setSubmitted(true);
    const result = dynvalidate(values, "Sign Up");

    if (isEmpty(result)) {
      axios.post('http://localhost:5050/register', {
        user: values.user,
        email: values.email,
        password: values.password
      })
        .then(() => navigate('/blank'))
        .catch(console.log);
    }
  };

  const switchAction = (targetAction) => {
    setFormFade(true);
    setTimeout(() => {
      setAction(targetAction);
      setSubmitted(false);
      setFormFade(false);
    }, 300); // Match with CSS animation time
  };

  const errors = dynvalidate(formValues, action);

  return (
    <div className="login-container">
      <div className={`container ${formFade ? "fade-out" : "fade-in"}`}>
        <div className="logo-container">
          <img src={logo} alt="Logo" className="logo-img" />
        </div>

        <div className="header">
          <div className="text">{action}</div>
          <div className="underline"></div>
        </div>

        <form>
          <div className="inputs">
            {action === "Sign Up" && (
              <>
                <div className="input">
                  <img src={user_icon} alt="" />
                  <input
                    type="text"
                    placeholder="Username"
                    value={formValues.user}
                    onChange={(e) => setformValues({ ...formValues, user: e.target.value })}
                  />
                </div>
                <div className="errmsg">
                  {submitted && errors.username && <p>{errors.username}</p>}
                </div>
              </>
            )}

            <div className="input">
              <img src={mail_icon} alt="" />
              <input
                type="email"
                placeholder="Email"
                value={formValues.email}
                onChange={(e) => setformValues({ ...formValues, email: e.target.value })}
              />
            </div>
            <div className="errs">
              {submitted && (action === "Log In" ? <p>{logres}</p> : <p>{errors.email}</p>)}
            </div>

            <div className="input">
              <img src={password_icon} alt="" />
              <input
                type="password"
                placeholder="Password"
                value={formValues.password}
                onChange={(e) => setformValues({ ...formValues, password: e.target.value })}
              />
            </div>
            <div className="errs">
              {submitted && (pasres ? <p>{pasres}</p> : <p>{errors.password}</p>)}
            </div>
          </div>
        </form>

        {action === "Log In" && (
          <div className="forgot-password">
            Forgot Password? <span>Click Here!</span>
          </div>
        )}

        <div className="submit-container">
          {action === "Log In" ? (
            <>
              <button className="submit" onClick={() => handleLogin(formValues)}>Login</button>
              <button className="submit" onClick={() => switchAction("Sign Up")}>Sign Up</button>
            </>
          ) : (
            <>
              <button className="submit" onClick={() => switchAction("Log In")}>Login</button>
              <button className="submit" onClick={() => handleSignUp(formValues)}>Sign Up</button>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default LoginSignup;
