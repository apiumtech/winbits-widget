'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
favoriteUtils = require 'lib/favorite-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class FavoritesView extends View
  container: '#wb-favorites'
  id: 'wb-micuenta-favorites'
  template: require './templates/favorite'

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @model.fetch()
    @subscribeEvent 'favorites-changed', -> @onFavoritesChanged.apply(@, arguments)

  onFavoritesChanged: (data)->
    @model.setData(data)




