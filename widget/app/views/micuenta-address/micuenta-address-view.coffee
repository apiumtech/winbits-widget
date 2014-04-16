'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class MiCuentaAddressView extends View
  container: '.wbc-my-account-container'
  id: 'wbi-micuenta-address'
  template: require './templates/micuenta-address'

  initialize: ->
    super

  attach: ->
    super