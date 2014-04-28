View = require 'views/base/view'
CartItemsView = require 'views/cart/cart-items-view'
CartTotalsView = require 'views/cart/cart-totals-view'
CartBitsView = require 'views/cart/cart-bits-view'
CartPaymentMethodsView = require 'views/cart/cart-payment-methods-view'
$ = Winbits.$

module.exports = class CartView extends View
  container: '#wbi-cart-holder'
  template: require './templates/cart'
  noWrap: yes

  initialize: ->
    super
    @listenTo @model, 'change', -> @render()
    @model.fetch()

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
