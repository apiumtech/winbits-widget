'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator
_ = Winbits._

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
    paymentMethods = @model.get('paymentMethods')
    if paymentMethods
      @setIndentifiers paymentMethods

  setIndentifiers: (paymentsMethods)->
    identifiers = _.map paymentsMethods, (paymentMethod)-> paymentMethod.identifier
    console.log ["Identifiers from model", identifiers]


  checkout: ->
    if utils.isLoggedIn()
      utils.showLoaderToCheckout()
      @model.requestCheckout()
    else
      mediator.data.set 'virtual-checkout', yes
      utils.redirectTo controller:'login', action:'index'

  closeCartView: ->
    $('#wbi-cart-drop').slideUp()
