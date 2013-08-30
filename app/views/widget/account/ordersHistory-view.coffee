template = require 'views/templates/account/order-history'
View = require 'views/base/view'
util = require 'lib/util'
vendor = require 'lib/vendor'

module.exports = class OrdersHistoryView extends View
  autoRender: yes
  container: '#ordersHistoryContent'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'change', '.orderHistoryFilter', @filterOrderHistory
    @subscribeEvent 'orderRecordReady', @handlerModelReady

  attach: ->
    super
    vendor.customSelect(@$('.select'))

  handlerModelReady: ->
    @render()


  filterOrderHistory: (e) ->
    e.preventDefault()
    console.log('amigo')
    $form = @$el.find("#orderHistoryFilterForm")
    formData = util.serializeForm($form)
    @publishEvent 'showOrdersHistory', formData
