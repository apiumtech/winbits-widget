'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class VerifyMobileView extends View
  container: '#wb-profile'
  id : 'wbi-verify-mobile'
  className: 'column micuenta-mobile'
  template: require './templates/verify-mobile-view'

  initialize: ->
    super

