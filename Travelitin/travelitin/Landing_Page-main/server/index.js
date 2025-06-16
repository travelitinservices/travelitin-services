const express = require('express')
const mongoose = require('mongoose')
const cors = require ('cors')
const userModel = require('./models/users')



const app = express();
app.use(express.json())
app.use(cors())

mongoose.connect("mongodb://127.0.0.1:27017/user")

app.post('/pushfeedback',(req,res)=>{

    userModel.create(req.body)
    .then(users=>res.json(users))
    .catch(err => res.json(err))

})


app.listen(5000,()=>{console.log("Connected To feedback DB!")})