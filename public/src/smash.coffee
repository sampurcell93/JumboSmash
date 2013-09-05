$(document).ready ->
    window.cc = (arg) ->
        console.log arg
    String.prototype.clean =  ->
        @charAt(0).toUpperCase() + @slice(1)

    messages = {
        signup_wrong: "Sorry, something went wrong with your signup"
        signup_right: "Great! You've signed up for JumboSmash. We'll email you when there's more to know."
        existing: 'Sorry, that email address is already registered with us.'
    }

    String.prototype.trimLast = ->
        @slice(0, @length-1)

    User = Backbone.Model.extend
        url: "/matches"
        defaults: 
            {match: false}
        initialize: ->
            @getName()
        getName: ->
            name = @get("email").split(".");
            first_name = first = name[0].toLowerCase().clean();
            last_name = last = name[1].split("@")[0].toLowerCase().clean();
            @.first = first_name
            @last = last_name

    Users = Backbone.Collection.extend
        url: "/users"
        model: User

    SelectableUser = Backbone.View.extend
        template: $("#person-select").html()
        tagName: 'li'
        render: ->
            data = _.template @template, {first: @model.first, last: @model.last}
            @$el.append data
            @
        events:
            "click .js-choose": (e) ->
                $t = $ e.currentTarget
                email = @model.get("email")
                @$el.addClass("selected")
                matches.add desirable = new User({email: email})
                logged_in.save(null, {
                    success: ->
                        $.ajax
                            url: '/matches'
                            data: {
                                search: email
                            }
                            dataType: 'json'
                            success: (json) ->
                                if json.match is true
                                    launchModal("You got a match, biaatch", 4000)
                    error: ->
                        cc "error"
                })

    SmashItem = Backbone.View.extend
        tagName: 'li'
        template: "<%= first + ' ' + last %>"
        initialize: ->
            self = @
            @listenTo @model,
                remove: ->
                    self.$el.slideUp "fast", ->
                        $(@).remove()
        render: ->
            @$el.html(_.template @template, {first: @model.first, last: @model.last})
            @

    SmashList = Backbone.View.extend
        el: '.smash-list'
        initialize: ->
            self = @
            @listenTo @collection, 
                add: @appendDesirable
                remove: ->
                    if self.collection.length is 0
                        self.$(".placeholder").show()
        appendDesirable: (person) ->
            @$(".placeholder").hide()
            person = new SmashItem({model: person})
            @$el.append $(person.render().el).hide().fadeIn("slow")
            @

    window.launchModal = (content, time) ->
        if $(".my-modal").length then $(".my-modal").remove()
        modal = $("<div />").addClass("my-modal")
        if $.isArray(content)
            _.each content, (item) ->
                modal.append(item)
        else modal.html(content)
        modal.prepend("<i class='close-modal icon-multiply'></i>")
        $(document.body).addClass("active-modal").append(modal)
        if typeof time != "undefined"
            modal.delay(time).fadeOut "fast", ->
                $(@).remove()
                $(document.body).removeClass("active-modal")
        modal
    $.urlParam = (name) ->
        results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
        if !results then return 0; 
        results[1] || 0;

    $(".js-sign-up").on "click", (e) ->
        $t = $ @
        year = parseInt $t.siblings(".grad-signup").val()
        email = $t.siblings(".email-signup").val()
        if email.indexOf("@tufts.edu") == -1 || email.indexOf(".") == -1 || email.length < 13
            e.preventDefault()
            launchModal("Sorry, you need to provide a valid tufts email address.", 1500)
        else if isNaN(year) || year < 2014 || year > 2018
            e.preventDefault()
            launchModal("Your graduation year must be a number between 2014 and 2018", 1500)

    # Returns elements in the collection that contain substrings of the query or match it
    findPeople = (self, keydown) ->
        $t = $ self
        str = $t.val().toLowerCase()
        if keydown is true then str = str.trimLast()
        if str == ""
            $(".filtered-list").remove(); 
            return
        list = users.models
        cc list.length
        filtered = _.filter list, (item) ->
            first = item.first.toLowerCase()
            last = item.last.toLowerCase()
            first.indexOf(str) != -1 or last.indexOf(str) != -1 or (first + " " + last).indexOf(str) != -1
        top = $t.offset().top
        left = $t.offset().left
        $(".filtered-list").remove()
        list = $("<ul/>").addClass("filtered-list").css({left: left + "px", top: top + 30 + "px"}).html("<li>Loading....</li>")
        _.each filtered, (item) ->
            item = new SelectableUser({model: item}).render().el
            list.append item
        list.children().first().remove()
        list.appendTo $(".small-container")


    # delegating finding events
    $(".js-find-people").on {
        "keyup": (e) ->
            code = e.keyCode || e.which
            if code >= 65 and code <= 90 then findPeople(@, false)
        "keydown": (e) ->
            code = e.keyCode || e.which
            if code == 46 or code == 8 then findPeople(@, true)
    }

    # If a message is passed, display it
    msg = $.urlParam("msg")
    if msg != 0
        launchModal messages[msg], 5000

    # Get all users in system for frontend sorting
    logged_in = new User(window.user_data)
    matches = new Users()
    matchlist = new SmashList({collection: matches})
    _.each logged_in.get("matches"), (match) ->
        matches.add user = new User(match)
    logged_in.set("matches", matches)
    users = new Users()
    clean = []
    _.each matches.models, (item) ->
        clean.push item.toJSON().email
    users.fetch({
        data: {ignore: clean}
        # success: (coll) ->
        #     cc users.length
        #     _.each coll.models, (model) ->
        #         email = model.get("email")
        #         search = _.findWhere matches.models, {email: email}
        #         for match in matches.models 
        #             if match.get("email") == email
        #                 users.remove match
        #     cc users.length

    })

    $(".name").text(logged_in.first)