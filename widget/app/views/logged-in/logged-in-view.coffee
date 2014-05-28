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
    @subscribeEvent 'profile-changed', @loadBalance
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

  loadBalance:(data) ->
    console.log ["SUBSCRIBE EVENT IN SAVE PROFILE", data.response.bitsBalance]
    console.log ["MODEL IN LOGGED IN VIEW", @model.get('bitsBalance')]
    if data.response.cashback > 0
      @changeBitsValue(-data.response.cashback)
      $('#wbi-account-bits-total').text(data.response.bitsBalance)