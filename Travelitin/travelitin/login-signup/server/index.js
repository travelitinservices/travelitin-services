const express = require('express')
const mongoose = require('mongoose')
const cors = require ('cors')
const userModel = require('./models/users')



const app = express();
app.use(express.json())
app.use(cors())

mongoose.connect("mongodb://127.0.0.1:27017/user")

app.post('/register',(req,res)=>{

    userModel.create(req.body)
    .then(users=>res.json(users))
    .catch(err => res.json(err))

})


app.post('/login',(req,res)=>{

   const {email,password}=req.body;
   userModel.findOne({email:email})
   .then(user=> {if(user){
        if(user.password===password){
            res.json("Success")
        }
        else{
            res.json("Invalid Password")
        }
   }
   
   else{
    res.json("Email Not Found")
   }
})

})


app.post('/checkuser',(req,res)=>{

    console.log('coming inside the request handle')

    const {emails}=req.body;
    userModel.findOne({email:emails})
    .then(userr=>{if(userr){
        res.json("User already present")}
    else{
        res.json("User not present")
    }
    
    })
    .catch(err=>console.log(err))
})

app.listen(5050,()=>{console.log("Server connected on port 5050")})