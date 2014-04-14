# Very bare bones object to represent the Movie information
# sent back from the sever. Initialized with a default image
#
Bacon.Movie = Ember.Object.extend
  init: () ->
    @_super()
    @set('image_url', '/static-images/theater.png')

