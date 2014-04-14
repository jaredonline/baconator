# This Route does two things; first it grabs the set of
# actors from the server. Because this list if very large
# it's loaded asynchronously. While loading a spinner is
# displayed on the homepage.
#
# The second thing it does is initialize the data in the
# corresponding BaconController class. It also hides the
# spinner.
#
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
