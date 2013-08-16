template = require 'views/templates/account/account-history'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class OrdersHistoryView extends View
  autoRender: yes
  container: '#ordersHistoryContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'change', '.orderHistoryFilter', @filterOrderHistory
    @delegate 'click', '#ordersHistoryAccordion', @showOrdersHistoryAccordion
    @subscribeEvent 'orderRecordReady', @handlerModelReady

  attach: ->
    super

  handlerModelReady: ->
    @render()


  filterOrderHistory: (e) ->
    e.preventDefault()
    $form = @$el.find("#orderHistoryFilterForm")
    formData = util.serializeForm($form)
    @publishEvent 'showOrdersHistory', formData

  showOrdersHistoryAccordion: (e) ->
    console.log 'abriendo historial de ordenes'
    e.preventDefault()
    @publishEvent 'showOrdersHistory'
