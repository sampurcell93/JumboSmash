// Generated by CoffeeScript 1.6.3
(function() {
  $(function() {
    var SelectableUser, SmashList, User, Users, cc, findPeople, matches, messages, msg, users;
    cc = function(arg) {
      return console.log(arg);
    };
    messages = {
      signup_wrong: "Sorry, something went wrong with your signup",
      signup_right: "Great! You've signed up for JumboSmash. We'll email you when there's more to know.",
      existing: 'Sorry, that email address is already registered with us.'
    };
    String.prototype.trimLast = function() {
      return this.slice(0, this.length - 1);
    };
    User = Backbone.Model.extend({
      getName: function() {
        var first, first_name, last, last_name, name;
        name = this.get("email").split(".");
        first_name = first = name[0];
        last_name = last = name[1].split("@")[0];
        return {
          first: first_name.toLowerCase(),
          last: last_name.toLowerCase()
        };
      }
    });
    Users = Backbone.Collection.extend({
      url: "/users",
      model: User
    });
    SelectableUser = Backbone.View.extend({
      template: $("#person-select").html(),
      tagName: 'li',
      render: function() {
        var data, names;
        names = this.model.getName();
        data = _.template(this.template, {
          first: names.first,
          last: names.last
        });
        this.$el.append(data);
        return this;
      },
      events: {
        "click .js-choose": function(e) {
          var $t;
          $t = $(e.currentTarget);
          return this.$el.addClass("selected");
        }
      }
    });
    SmashList = Backbone.View.extend({
      el: '.smash-list'
    });
    window.launchModal = function(content, time) {
      var modal;
      if ($(".my-modal").length) {
        $(".my-modal").remove();
      }
      modal = $("<div />").addClass("my-modal");
      if ($.isArray(content)) {
        _.each(content, function(item) {
          return modal.append(item);
        });
      } else {
        modal.html(content);
      }
      modal.prepend("<i class='close-modal icon-multiply'></i>");
      $(document.body).addClass("active-modal").append(modal);
      if (typeof time !== "undefined") {
        modal.delay(time).fadeOut("fast", function() {
          $(this).remove();
          return $(document.body).removeClass("active-modal");
        });
      }
      return modal;
    };
    $.urlParam = function(name) {
      var results;
      results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
      if (!results) {
        return 0;
      }
      return results[1] || 0;
    };
    $(".js-sign-up").on("click", function(e) {
      var $t, email, year;
      $t = $(this);
      year = parseInt($t.siblings(".grad-signup").val());
      email = $t.siblings(".email-signup").val();
      if (email.indexOf("@tufts.edu") === -1 || email.indexOf(".") === -1 || email.length < 13) {
        e.preventDefault();
        return launchModal("Sorry, you need to provide a valid tufts email address.", 1500);
      } else if (isNaN(year) || year < 2014 || year > 2018) {
        e.preventDefault();
        return launchModal("Your graduation year must be a number between 2014 and 2018", 1500);
      }
    });
    findPeople = function(self, keydown) {
      var $t, filtered, left, list, str, top;
      $t = $(self);
      str = $t.val();
      if (keydown === true) {
        str = str.trimLast();
      }
      str = str.toLowerCase();
      if (str === "") {
        $(".filtered-list").remove();
        return;
      }
      list = users.models;
      filtered = _.filter(list, function(item) {
        var names;
        names = item.getName();
        return names.first.indexOf(str) !== -1 || names.last.indexOf(str) !== -1 || (names.first + " " + names.last).indexOf(str) !== -1;
      });
      top = $t.offset().top;
      left = $t.offset().left;
      $(".filtered-list").remove();
      list = $("<ul/>").addClass("filtered-list").css({
        left: left + "px",
        top: top + 30 + "px"
      }).html("<li>Loading....</li>");
      _.each(filtered, function(item) {
        item = new SelectableUser({
          model: item
        }).render().el;
        return list.append(item);
      });
      list.children().first().remove();
      return list.appendTo($(".small-container"));
    };
    $(".js-find-people").on({
      "keyup": function(e) {
        var code;
        code = e.keyCode || e.which;
        if (code >= 65 && code <= 90) {
          return findPeople(this, false);
        }
      },
      "keydown": function(e) {
        var code;
        code = e.keyCode || e.which;
        if (code === 46 || code === 8) {
          return findPeople(this, true);
        }
      }
    });
    msg = $.urlParam("msg");
    if (msg !== 0) {
      launchModal(messages[msg], 5000);
    }
    users = new Users();
    users.fetch();
    cc(window.user_data.matches);
    matches = new SmashList({
      collection: new Users(window.user_data.matches)
    });
    return cc(matches);
  });

}).call(this);
