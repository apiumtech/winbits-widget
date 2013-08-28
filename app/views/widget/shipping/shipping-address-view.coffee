template = require 'views/templates/shipping/address'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
vendor = require 'lib/vendor'

module.exports = class ShippingAddressView extends View
  autoRender: yes
  container: '#shippingAddressContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @subscribeEvent 'shippingReady', @handlerModelReady

  attach: ->
    super

  handlerModelReady: ->
    @render()
