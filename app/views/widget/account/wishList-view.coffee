template = require 'views/templates/account/wish-list'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class WishListView extends View
  autoRender: yes
  container: '#wishListContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @subscribeEvent 'wishListReady', @handlerModelReady

  attach: ->
    super

  handlerModelReady: ->
    @render()
