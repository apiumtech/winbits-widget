View = require 'views/base/view'
CartItemsView = require 'views/cart/cart-items-view'
CartTotalsView = require 'views/cart/cart-totals-view'
CartBitsView = require 'views/cart/cart-bits-view'
$ = Winbits.$

module.exports = class CartView extends View
  container: '#wbi-cart-holder'
  template: require './templates/cart'
  noWrap: yes

  initialize: ->
    super

  render: ->
    super
    @subview 'cart-items', new CartItemsView container: @$el.find('#wbi-cart-left-panel').get(0)
    cartRightPanel = @$el.find('#wbi-cart-right-panel').get(0)
    @subview 'cart-totals', new CartTotalsView container: cartRightPanel
    @subview 'cart-bits', new CartBitsView container: cartRightPanel

  attach: ->
    super
    @$('#wbi-cart-info').dropMainMenu()
