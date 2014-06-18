'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

module.exports = class CartPaymentMethodsView extends View
  container: '#wbi-cart-right-panel'
  template: require './templates/cart-payment-methods'
  id: 'wbi-cart-payment-methods'

  initialize: ->
    super
    @delegate 'click', '#wbi-continue-shopping-link', @closeCartView
    @delegate 'click', '#wbi-cart-checkout-btn', ->
      @checkout.apply(@, arguments)
    @subscribeEvent 'checkout-requested', -> @checkout.apply(@, arguments)

  attach: ->
    super

  checkout: ->
    if utils.isLoggedIn()
      utils.showLoadingMessage('Generando orden...')
      @model.requestCheckout()
    else
      mediator.data.set 'virtual-checkout', yes
      utils.redirectTo controller:'login', action:'index'

  closeCartView: ->
    $('#wbi-cart-drop').slideUp()
