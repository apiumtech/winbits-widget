template = require 'views/templates/shipping/shipping-main'
View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
vendor = require 'lib/vendor'

module.exports = class ShippingMainView extends View
  autoRender: yes
  container: 'main'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '.btnBackToSite', @backToSite


  attach: ->
    super
    Backbone.$("#shippingAddressMain").hide()

  backToSite: (e) ->
    util.backToSite(e)