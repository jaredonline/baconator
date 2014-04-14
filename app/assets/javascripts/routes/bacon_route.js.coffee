Bacon.BaconRoute = Ember.Route.extend
  model: () ->
    $.getJSON('/actors').then (response) ->
      for actor in response
        Ember.Object.create
          name:      actor.name
          image_url: actor.image_url
          actor_id:  actor.id

  setupController: (controller, model) ->
    $("#loading").hide()
    controller.setProperties
      model:       model
