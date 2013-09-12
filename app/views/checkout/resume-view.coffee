template = require 'views/templates/checkout/resume'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'
vendor = require 'lib/vendor'
clock = require 'lib/clock'

module.exports = class ResumeView extends View
  container: '.widgetWinbitsMain'
  autoRender: false
  template: template

  initialize: ->
    super
    @delegate 'click', '.closeButton', @deleteItem
    @delegate 'click', '.linkBack', @backToSite
    @delegate 'click', '#checkoutFromResume', @checkoutFromResume
    @delegate 'change', '.inputStepper', @updateQuantityItem
    @subscribeEvent 'showResume', @showResume
    @subscribeEvent 'resumeReady', @handlerModelReady

  attach: ->
    super
    vendor.customStepper(@$('.inputStepper'))
    clock.startCounter(@$el.find('#wb-resume-timer'))

  showResume: (data) ->
    console.log ['Resume', data]
    $ = Backbone.$
    $main = $('main').first()
    $main.children().hide()
    @publishEvent 'updateResumeModel', data

  handlerModelReady: ->
    @render()

  updateQuantityItem: (e) ->
    $currentTarget = @$(e.currentTarget)
    skuProfileId =  $currentTarget.attr("id").split("-")[1]
    skuProfileIdInt = parseInt(skuProfileId)
    orderDetails = @model.attributes.orderDetails
    quantity = parseInt $currentTarget.val()
    items = orderDetails.map( (it) ->
        if it.sku.id is skuProfileIdInt
          it.quantity = quantity
          it.amount = it.sku.price * quantity
        it
    )
    @updateResumeView items

  deleteItem: (e) ->
    $currentTarget = @$(e.currentTarget)
    skuProfileId =  $currentTarget.attr("id").split("-")[1]
    orderDetails = @model.attributes.orderDetails
    skuProfileIdInt = parseInt(skuProfileId)
    items = orderDetails.filter (it) ->  it.sku.id isnt skuProfileIdInt
    @updateResumeView items

  updateResumeView: (items)->
    itemsTotal = @calculateItemsTotal items
    cashTotal = @calculateCashTotal itemsTotal, @model.attributes.shippingTotal
    respMap = {
      orderDetails: items,
      itemsTotal: itemsTotal,
      cashTotal: cashTotal
    }
    @publishEvent 'updateResumeModel', respMap

  backToSite: (e) ->
    util.backToSite(e)

  checkoutFromResume: (e) ->
    @publishEvent 'postToCheckoutApp', @model.attributes

  calculateItemsTotal: (orderDetails) ->
    orderDetails.map( (a) -> a.amount ).reduce( (x, y) -> x + y )

  calculateCashTotal: (itemsTotal, shippingTotal) ->
    itemsTotal + shippingTotal

