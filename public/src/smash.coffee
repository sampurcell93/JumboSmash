$ ->
    cc = (arg) ->
        console.log arg
    window.launchModal = (content) ->
        if $(".modal").length then $(".modal").remove()
        modal = $("<div />").addClass("modal")
        if $.isArray(content)
            _.each content, (item) ->
                modal.append(item)
        else modal.html(content)
        modal.prepend("<i class='close-modal icon-multiply'></i>")
        $(document.body).addClass("active-modal").append(modal)
        modal

    $(".js-sign-up").on "click", (e) ->
        $t = $ @
        year = parseInt $t.siblings(".grad-signup").val()
        email = $t.siblings(".email-signup").val()
        if email.indexOf("@tufts.edu") == -1 || email.indexOf(".") == -1 || email.length < 13
            e.preventDefault()
            launchModal("Hi")
        else if isNaN(year) || year < 2014 || year > 2018
            e.preventDefault()
            launchModal("Hi")
