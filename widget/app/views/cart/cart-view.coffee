'use strict'
View = require 'views/base/view'
CartItemsView = require 'views/cart/cart-items-view'
CartTotalsView = require 'views/cart/cart-totals-view'
CartBitsView = require 'views/cart/cart-bits-view'
CartPaymentMethodsView = require 'views/cart/cart-payment-methods-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class CartView extends View
  container: '#wbi-cart-holder'
  template: require './templates/cart'
  noWrap: yes
  model: new Cart

  initialize: ->
    super
    # @listenTo @model, 'change', -> @render()
    @subscribeEvent 'cart-changed', -> @onCartChanged.apply(@, arguments)
    @model.fetch(success: $.proxy(@successFetch, @))

  render: ->
    super
    cartLeftPanel = @$el.find('#wbi-cart-left-panel').get(0)
    @subview 'cart-items', new CartItemsView container: cartLeftPanel, model: @model
    cartRightPanel = @$el.find('#wbi-cart-right-panel').get(0)
    @subview 'cart-totals', new CartTotalsView container: cartRightPanel, model: @model
    @subview 'cart-bits', new CartBitsView container: cartRightPanel, model: @model
    @subview 'cart-payment-methods', new CartPaymentMethodsView container: cartRightPanel, model: @model

  attach: ->
    super
    @$('#wbi-cart-info').dropMainMenu()

  onCartChanged: (cartData)->
    @model.setData(cartData)
    @render()

  successFetch: (data)->
    @onCartChanged data
    $bitsTotal= @model.get 'bitsTotal'
    @publishEvent 'change-bits-data', $bitsTotal

