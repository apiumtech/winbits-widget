'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class FavoritesView extends View
  container: '#wb-favorites'
  template: require './templates/favorite'

  initialize: ->
    super
    @model.fetch()

