Bacon.BaconController = Ember.Controller.extend
  selectedActor: null
  showSpinner: true

  link: (() -> []).property("baconLink")

  baconLink: (() ->
    url   = "/actors/#{@get("selectedActor").get("actor_id")}"
    _that = @

    $.getJSON(url).then (response) ->
      result = for link in response
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

      console.log result
      _that.set("link", result)

  ).property("selectedActor")
