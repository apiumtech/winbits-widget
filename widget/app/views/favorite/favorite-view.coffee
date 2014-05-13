'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
favoriteUtils = require 'lib/favorite-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class FavoritesView extends View
  container: '#wb-favorites'
  template: require './templates/favorite'

  initialize: ->
    super
    @listenTo @model,  'change', -> @render()
    @model.fetch()
    @delegate 'click', '#wbi-add-favorite-brand-test', @addFavorite

  addFavorite: ->
    options = brandId: '1'
    console.log ['BRAND OPTIONS', options]
    favoriteUtils.addToWishList(options)

