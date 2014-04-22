View = require 'views/base/view'
env = Winbits.env
$ = Winbits.$

module.exports = class CartView extends View
  container: '#wbi-cart-holder'
  template: require './templates/cart'
  noWrap: yes

  initialize: ->
    super

  attach: ->
    super
    @$('#wbi-cart-drop').hide()
