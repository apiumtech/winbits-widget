'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class HistoryHeaderView extends View
  container: '.wb-history-header'
  id: 'wbi-history-header'
  className: 'miCuenta-history miCuenta-tab'
  template: require './templates/account-history'

  initialize: ->
    super
    @listenTo @model, 'change', @render
    @subscribeEvent 'bits-updated', @updateBits

  updateBits: ->
    @model.set 'bitsTotal', mediator.data.get('login-data').bitsBalance


