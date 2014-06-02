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
    @delegate 'click', '.wbc-delete-brand-link', @doDeleteBrand

  onFavoritesChanged: (data)->
    @model.setData(data)

  doDeleteBrand: (e)->
    e.preventDefault()
    $itemId = $(e.currentTarget).closest('li').data('id')
    message = '¿Estás seguro que deseas eliminar esta marca de tus favoritos?'
    options =
      value: 'Aceptar'
      title: 'Eliminar de Favoritos'
      icon: 'iconFont-question'
      context: @
      acceptAction: () -> @doRequestDeleteBrand($itemId)
    utils.showConfirmationModal(message, options)

  doRequestDeleteBrand: (brandId)->
    favoriteUtils.deleteFromWishList({brandId:brandId})
    utils.closeMessageModal()





