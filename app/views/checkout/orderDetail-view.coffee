View = require 'views/base/view'
template = require 'views/templates/checkout/order-detail'
util = require 'lib/util'
config = require 'config'

# Site view is a top-level view which is bound to body.
module.exports = class OrderDetailView extends View
  container: '#order-detail'
  autoRender: false
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super
  attach: ->
    super
    that = @
    util.customSlider(".slideInput").on 'slidechange', (e, ui) ->
#      TODO: Create view OrderInfo and maintain slider out of that view
      that.updateOrderBits ui.value

  updateOrderBits: (bits) ->
    console.log ['Updating order bits']
