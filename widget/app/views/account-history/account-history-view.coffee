'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class HistoryView extends View
  container: '#wb-account-history'
  id: 'wb-micuenta-history'
  template: require './templates/account-history'

  initialize: ->
    super
    @render
#    @listenTo @model,  'change', -> @render()
#    @model.fetch()
#    @subscribeEvent 'favorites-changed', -> @onFavoritesChanged.apply(@, arguments)

#  onFavoritesChanged: (data)->
#    @model.setData(data)



