express = require 'express'
url = require 'url'
app = do express
app.listen process.env.PORT || 4040

checkAuth = (req,res,next) ->
    req.user = "samuel.purcell@tufts.edu"
    next()

cc = (arg) ->
    console.log arg
temp = "mongodb://heroku:192be8556a80da2574b29c0a48b37360@ethan.mongohq.com:10058/app17903256"
db = require("mongojs").connect(temp || process.env.MONGOHQ_URL || "JumboSmash", ['users'])
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
        db.users.find {email: email}, (err, users) ->
            if users.length
                res.redirect "/signup?msg=existing"
            else 
                db.users.insert {
                    email: email
                }, {$set: {email: email, grad_year: year}}, (err, inserted) ->
                    if err || !inserted
                        res.redirect "/signup?msg=signup_wrong"
                    else 
                res.redirect "/signup?msg=signup_right"
        return true
    res.redirect  "/signup?msg=signup_wrong"

app.get "/smashes", (req, res) ->
    db.users.find({email: 'samuel.purcell@tufts.edu'}, (err, user) ->
        cc user
        res.render "smashes", {
            user: user[0]
            scripts: ["js/test.js"]
        }
    )

### REST API ###
# Get the list of matches for a given user
app.get "/matches", checkAuth, (req, res) ->
    db.users.find({email: req.user}, (err, user) ->
        res.json user
    )

# Add a new match to a user's list
app.post "/matches/:matchid", (req, res) ->

# Remove a match from the logged in user
app.delete "/matches/:matchid", (req, res) ->

app.get "/users", (req, res) ->
    # query = req.params.query
    db.users.find {}, {matches: 0}, (err, users) ->
        if !err
            res.json users
        else 
            res.json success: false
    true

app.get "/dev", (req,res) ->
    db.users.update({email: "samuel.purcell@tufts.edu"}, {$set: {matches: ["grace.buchloh@tufts.edu, jack.watterson@tufts.edu"]} }, {multi: true}, ->
        res.json success: true
    )