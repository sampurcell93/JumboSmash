$ ->
    cc = (arg) ->
        console.log arg

    messages = {
        signup_wrong: "Sorry, something went wrong with your signup"
        signup_right: "Great! You've signed up for JumboSmash. We'll email you when there's more to know."
        existing: 'Sorry, that email address is already registered with us.'
    }

    String.prototype.trimLast = ->
        @slice(0, @length-1)

    User = Backbone.Model.extend
        getName: ->
            name = @get("email").split(".");
            first_name = first = name[0];
            last_name = last = name[1].split("@")[0];
            { first: first_name.toLowerCase(), last: last_name.toLowerCase()}

    Users = Backbone.Collection.extend
        url: "/users"
        model: User

    SelectableUser = Backbone.View.extend
        template: $("#person-select").html()
        tagName: 'li'
        render: ->
            names = @model.getName()
            data = _.template @template, {first: names.first, last: names.last}
            @$el.append data
            @
        events:
            "click .js-choose": (e) ->
                $t = $ e.currentTarget
                @$el.addClass("selected")

    SmashList = Backbone.View.extend
        el: '.smash-list'

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
        str = $t.val()
        if keydown is true then str = str.trimLast()
        str = str.toLowerCase()
        if str == ""
            $(".filtered-list").remove(); 
            return
        list = users.models
        filtered = _.filter list, (item) ->
            names = item.getName()
            names.first.indexOf(str) != -1 or names.last.indexOf(str) != -1 or (names.first + " " + names.last).indexOf(str) != -1
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
    users = new Users()
    users.fetch()
    cc window.user_data.matches
    matches = new SmashList({collection: new Users(window.user_data.matches)})
    cc matches