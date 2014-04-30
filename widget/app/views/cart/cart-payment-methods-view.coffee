'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class CartPaymentMethodsView extends View
  container: '#wbi-cart-right-panel'
  template: require './templates/cart-payment-methods'
  id: 'wbi-cart-payment-methods'

  initialize: ->
    super
    @delegate 'click', '#wbi-cart-checkout-btn', -> @checkout.apply(@, arguments)
    @subscribeEvent 'checkout-requested', -> @checkout.apply(@, arguments)

  attach: ->
    super

  checkout: ->
    utils.showLoadingMessage('Generando orden...')
    @model.requestCheckout()
