express = require 'express'
app = do express
app.listen process.env.PORT || 4040
cc = (arg) ->
    console.log arg

db = require("mongojs").connect(process.env.MONGOHQ_URL || "JumboSmash", ['users'])
app.configure ->
  app.use(express.logger('dev'));
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.cookieParser());
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.static(__dirname + '/public'));

app.get "/signup", (req,res,next) ->
    res.render "signup"

app.post "/signup", (req,res, next) ->
    click = req.body.submit_login
    email = req.body.email.toLowerCase()
    year = parseInt req.body.grad_year
    unless typeof click == "undefined"
        db.users.update {
            email: email
        }, {$set: {email: email, grad_year: year}}, {upsert: true}, (err, inserted) ->
            if err || !inserted
                res.redirect "/signup?bad=true"
            else 
                res.redirect "/signup?bad=false"
        return true
    res.redirect  "/signup?bad=true"
