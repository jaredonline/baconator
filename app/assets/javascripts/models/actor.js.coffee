# Very bare bones object to represent the Actor information
# sent back from the sever. Initialized with a default image
#
Bacon.Actor = Ember.Object.extend
  init: () ->
    @_super()
    @set('image_url', '/static-images/monster.png')
