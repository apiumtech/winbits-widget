View = require 'views/base/view'
$ = Winbits.$

module.exports = class CartBitsView extends View
  container: '#wbi-cart-right-panel'
  template: require './templates/cart-bits'
  id: 'wbi-cart-bits'
  className: 'winSave'

  initialize: ->
    super

  attach: ->
    super
    @$('#wbi-cart-bits-slider').customSlider()
