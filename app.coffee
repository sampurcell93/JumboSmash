express = require 'express'
url = require 'url'
_ = require 'underscore'
app = do express
app.listen process.env.PORT || 4040

checkAuth = (req,res,next) ->
    req.user = "samuel.purcell@tufts.edu"
    req.user = "grace.buchloh@tufts.edu"
    db.users.findOne({email: req.user}, (err, user)->
        req.user = user
        next()
    ) 

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

app.get "/smashes", checkAuth, (req, res) ->
    db.users.find({email: req.user.email}, (err, user) ->
        res.render "smashes", {
            user: user[0]
            scripts: ["js/test.js"]
        }
    )

### REST API ###
# Get the list of matches for a given user
app.get "/matches", checkAuth, (req, res) ->
    search = req.query.search
    loggedin = req.user
    db.users.findOne {email: search}, (err, user) ->
        matches = user.matches
        # Check all matches for the desired person
        for match in matches
            # If the person's desired matches the current user
            if match.email == loggedin.email
                # Set that match to true
                match.match = true
                # Get the current user's reference to the desired and set it to true
                cc loggedin
                _.each loggedin.matches, (logged_match) ->
                    cc logged_match
                    if logged_match.email == search then logged_match.match = true
                # cc loggedin
                # cc user
                # Update the logged in user's match list
                db.users.update {email: loggedin.email}, {$set: {matches: loggedin.matches}}, ->
                    # Update the desired person's match list
                    db.users.update({email: user.email}, {$set: {matches: matches}}, ->
                        # Return true so ajax can handle it
                        res.json match: true
                    )
                return true
        res.json match: false
# Add a new match to a user's list
app.post "/matches", checkAuth, (req, res) ->
    matches = req.body.matches
    cc "POSTING"
    db.users.update {email: req.user.email},  {$set: {matches: matches}}, (err, updated) ->
        res.json success: true

# Remove a match from the logged in user
app.delete "/matches/:matchid", (req, res) ->

app.get "/users", checkAuth, (req, res) ->
    ignore = req.query.ignore
    # query = req.params.query
    db.users.find {}, (err, users) ->
        clean = []
        _.each users, (user) ->
            unless (ignore? and ignore.indexOf(user.email) != -1) or user.email == req.user.email
                user.match_total = (_.filter user.matches, (matches) ->
                    matches.match == true
                ).length
                # delete user.matches
                clean.push user
                return true
            cc "ignoring" + user.email
        if !err
            res.json clean
        else 
            res.json success: false
    true

app.get "/dev", (req,res) ->
    db.users.update({}, {$set: {matches: []} }, {multi: true}, ->
        res.json success: true
    )