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
    @listenTo @model, 'change', @render
    @subscribeEvent 'bits-updated', @updateBits

  updateBits: ->
    @model.set 'bitsTotal', mediator.data.get('login-data').bitsBalance



