template = require 'views/templates/account/waiting-list'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class WaitingListView extends View
  autoRender: yes
  container: '#waitingListContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @subscribeEvent 'waitingListReady', @handlerModelReady

  attach: ->
    super

  handlerModelReady: ->
    @render()
