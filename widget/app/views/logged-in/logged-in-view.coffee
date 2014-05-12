'use strict'

View = require 'views/base/view'
LoggedIn = require 'models/logged-in/logged-in'
utils = require 'lib/utils'
loginUtil = require 'lib/login-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class LoggedInView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta'
  template: require './templates/logged-in'
  model: new LoggedIn mediator.data.get 'login-data'

  initialize: ->
    super
    @listenTo @model, 'change', @render
    @subscribeEvent 'change-bits-data', @changeBitsValue
    @delegate 'click', '#wbi-checkout-btn', @triggerCheckout

  attach: ->
    super
    @$('#wbi-my-account-link').one('click', ->
      mediator.data.set('tabs-swapped', yes)
    )

  triggerCheckout: ->
    @publishEvent('checkout-requested')

  changeBitsValue:(bitsTotal = 0)->
    $bitsBalance = mediator.data.get('login-data').bitsBalance - bitsTotal
    @$('#wbi-my-bits').text $bitsBalance

