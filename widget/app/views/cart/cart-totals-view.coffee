View = require 'views/base/view'
$ = Winbits.$

module.exports = class CartTotalsView extends View
  container: '#wbi-cart-right-panel'
  template: require './templates/cart-totals'
  id: 'wbi-cart-totals'

  initialize: ->
    super

  attach: ->
    super
