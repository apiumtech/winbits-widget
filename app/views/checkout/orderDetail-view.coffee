View = require 'views/base/view'
template = require 'views/templates/checkout/order-detail'
util = require 'lib/util'
config = require 'config'
vendor = require 'lib/vendor'

# Site view is a top-level view which is bound to body.
module.exports = class OrderDetailView extends View
  container: '#order-detail'
  autoRender: false
  template: template

  initialize: ->
    super
  attach: ->
    super
    that = @
    if window.bits_balance > 0
      vendor.customSlider("#wbi-bits-slide-checkout").on('slidechange', (e, ui) ->
#      TODO: Create view OrderInfo and maintain slider out of that view
        util.updateOrderDetailView(that.model, ui.value, Backbone.$(@))
        that.updateOrderBits ui.value
      ).on('slide', (e, ui) ->
        util.updateOrderDetailView(that.model, ui.value, Backbone.$(@))
      )

    if this.model.get("cashTotal") is 0
        @publishEvent "showBitsPayment"


  updateOrderBits: (bits) ->
    @model.updateOrderBits(bits)
