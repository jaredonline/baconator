# The BaconController is the main controller for the ember app
#
# It's responsible for maintaining the selected actor and firing
# off the request to the server once an actor has been selected.
# It also parses the response for use in the view.
#
Bacon.BaconController = Ember.Controller.extend
  selectedActor: null

  link: (() -> []).property("baconLink")

  baconLink: (() ->
    url   = "/actors/#{@get("selectedActor").get("actor_id")}"
    _that = @

    $.getJSON(url).then (response) ->
      result = for link in response
        # This very verbose builder is taking the JSON from the server
        # and initializing objects with it. It's then checking to see
        # whether or not the server provided an image_url for this object.
        # If not, it doesn't set one on the initialized object, this way
        # the default will be maintained
        #
        first = Bacon.Actor.create
          name: link.first.name

        if link.first.image_url?
          first.set("image_url", link.first.image_url)

        last = Bacon.Actor.create
          name: link.last.name

        if link.last.image_url?
          last.set("image_url", link.last.image_url)

        movie = Bacon.Movie.create
          name: link.movie.name

        if link.movie.image_url?
          movie.set("image_url", link.movie.image_url)

        Ember.Object.create
          first:     first
          movie:     movie
          last:      last

      _that.set("link", result)

  ).property("selectedActor")
