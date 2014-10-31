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
    @subscribeEvent 'cart-changed', @changeBitsValue
    @subscribeEvent 'cashback-bits-won', @cashBackBitsChange
    @delegate 'click', '#wbi-checkout-btn', @triggerCheckout
    @delegate 'click', '#wbi-bits-link-btn', @redirectBitsHistory

  attach: ->
    super
    @$('#wbi-my-account-link').one('click', ->
      mediator.data.set('tabs-swapped', yes)
    )

  redirectBitsHistory:(e)->
    e.preventDefault()
    e.stopPropagation()
    utils.redirectTo(controller: 'bits-history', action: 'index')

  triggerCheckout: ->
    @publishEvent('checkout-requested')

  changeBitsValue: ->
    bitsTotal = mediator.data.get('bits-to-cart')
    $bitsBalance = mediator.data.get('login-data').bitsBalance - bitsTotal
    Winbits.trigger('changeBits', [bitsTotal:$bitsBalance])
    @$('#wbi-my-bits').text utils.formatNumWithComma($bitsBalance)

  cashBackBitsChange:(cashback) ->
    if cashback > 0
      message = "¡Felicidades! Has ganado $#{cashback} bits por completar tu registro"
      options = icon:"iconFont-computer", value : "Aceptar", title:"¡Registro completo!", onClosed:utils.redirectToLoggedInHome
      utils.showMessageModal(message, options)
      @changeBitsValue()