View = require 'views/base/view'
$ = Winbits.$

module.exports = class CartItemsView extends View
  container: '#wbi-cart-left-panel'
  template: require './templates/cart-items'
  id: 'wbi-cart-items'
  className: 'carritoContainer scrollPanel'
  attributes:
    'data-content': 'carritoContent'

  initialize: ->
    super
    console.log 'CartItemsView#initialize'

  attach: ->
    super
    @$el.scrollpane(parent: '#wbi-cart-drop')
    @$('.wbc-item-quantity').customSelect()
