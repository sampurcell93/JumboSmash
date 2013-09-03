$ ->
    cc = (arg) ->
        console.log arg

    messages = {
        signup: {
            wrong: "Sorry, something went wrong with your signup"
            right: "Great! You've signed up for JumboSmash. We'll email you when there's more to know."
        }
    }

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
    signup = $.urlParam("signup")
    if signup != 0
        cc signup
        launchModal messages['signup'][signup], 5000