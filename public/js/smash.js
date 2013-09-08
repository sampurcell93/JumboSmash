// Generated by CoffeeScript 1.6.3
(function() {
  $(document).ready(function() {
    var SelectableUser, SmashItem, SmashList, User, Users, clean, findPeople, logged_in, matches, matchlist, messages, msg, users;
    window.cc = function(arg) {
      return console.log(arg);
    };
    String.prototype.clean = function() {
      return this.charAt(0).toUpperCase() + this.slice(1);
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
      url: "/matches",
      defaults: {
        match: false
      },
      initialize: function() {
        return this.getName();
      },
      getName: function() {
        var first, first_name, last, last_name, name;
        name = this.get("email").split(".");
        first_name = first = name[0].toLowerCase().clean();
        last_name = last = name[1].split("@")[0].toLowerCase().clean();
        this.first = first_name;
        return this.last = last_name;
      }
    });
    Users = Backbone.Collection.extend({
      url: "/users",
      model: User
    });
    SelectableUser = Backbone.View.extend({
      template: $("#person-select").html(),
      tagName: 'li',
      initialize: function() {
        var self;
        self = this;
        return this.listenTo(this.model, {
          remove: function() {
            return self.$el.delay(300).slideUp("fast");
          }
        });
      },
      render: function() {
        var data;
        data = _.template(this.template, {
          first: this.model.first,
          last: this.model.last
        });
        this.$el.append(data);
        return this;
      },
      events: {
        "click .js-choose": function(e) {
          var $t, desirable, email, self;
          self = this;
          $t = $(e.currentTarget);
          email = this.model.get("email");
          this.$el.addClass("selected");
          matches.add(desirable = new User({
            email: email
          }));
          return logged_in.save(null, {
            success: function() {
              return $.ajax({
                url: '/matches',
                data: {
                  search: email
                },
                dataType: 'json',
                success: function(json) {
                  if (json.match === true) {
                    launchModal("You got a match, biaatch", 4000);
                  }
                  return self.model.collection.remove(self.model);
                }
              });
            },
            error: function() {
              return cc("error");
            }
          });
        }
      }
    });
    SmashItem = Backbone.View.extend({
      tagName: 'li',
      template: "<%= first + ' ' + last %>",
      initialize: function() {
        var self;
        self = this;
        return this.listenTo(this.model, {
          remove: function() {
            return self.$el.slideUp("fast", function() {
              return $(this).remove();
            });
          }
        });
      },
      render: function() {
        this.$el.html(_.template(this.template, {
          first: this.model.first,
          last: this.model.last
        }));
        return this;
      }
    });
    SmashList = Backbone.View.extend({
      el: '.smash-list',
      initialize: function() {
        var self;
        self = this;
        return this.listenTo(this.collection, {
          add: this.appendDesirable,
          remove: function() {
            if (self.collection.length === 0) {
              return self.$(".placeholder").show();
            }
          }
        });
      },
      appendDesirable: function(person) {
        this.$(".placeholder").hide();
        person = new SmashItem({
          model: person
        });
        this.$el.append($(person.render().el).hide().fadeIn("slow"));
        return this;
      }
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
      str = $t.val().toLowerCase();
      if (keydown === true) {
        str = str.trimLast();
      }
      if (str === "") {
        $(".filtered-list").remove();
        return;
      }
      list = users.models;
      cc(list.length);
      filtered = _.filter(list, function(item) {
        var first, last;
        first = item.first.toLowerCase();
        last = item.last.toLowerCase();
        return first.indexOf(str) !== -1 || last.indexOf(str) !== -1 || (first + " " + last).indexOf(str) !== -1;
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
    logged_in = new User(window.user_data);
    matches = new Users();
    matchlist = new SmashList({
      collection: matches
    });
    _.each(logged_in.get("matches"), function(match) {
      var user;
      return matches.add(user = new User(match));
    });
    logged_in.set("matches", matches);
    users = new Users();
    clean = [];
    _.each(matches.models, function(item) {
      return clean.push(item.toJSON().email);
    });
    users.fetch({
      data: {
        ignore: clean
      }
    });
    return $(".name").text(logged_in.first);
  });

}).call(this);
