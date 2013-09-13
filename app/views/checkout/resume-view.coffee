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

  updateBitsTotal: (bitsTotal) ->
    console.log ['update bits total', bitsTotal]

  updateResumeView: (items)->
    itemsTotal = @calculateItemsTotal items
    shippingTotal = @calculateShippingTotal @model.attributes.shippingTotal, items
    total = @calculateTotal itemsTotal, shippingTotal
    cashTotal = @calculateCashTotal total, @model.attributes.bitsTotal
    orderSaving = @calculateOrderSaving itemsTotal, items
    maxBits = Math.min(total, mediator.profile.bitsBalance)
    resultMap = {
      orderDetails: items,
      itemsTotal: itemsTotal,
      shippingTotal: shippingTotal,
      cashTotal: cashTotal,
      total: total,
      orderSaving: orderSaving,
      maxBits: maxBits
    }
    @publishEvent 'updateResumeModel', resultMap

  backToSite: (e) ->
    util.backToSite(e)

  checkoutFromResume: (e) ->
    @publishEvent 'postToCheckoutApp', @model.attributes

  calculateItemsTotal: (orderDetails) ->
    orderDetails.map( (a) -> a.amount ).reduce( (x, y) -> x + y )

  calculateCashTotal: (total, bitsTotal) ->
    total - bitsTotal

  calculateTotal: (itemsTotal, shippingTotal) ->
    itemsTotal + shippingTotal

  calculateShippingTotal: (shippingTotal, items) ->
    requiredShippingItem = items.filter (it) ->  it.requiresShipping is true
    if requiredShippingItem?
      shippingTotal
    else
      0

  calculateOrderSaving: (itemsTotal, items) ->
    orderFullPrice = util.calculateOrderFullPrice(items)
    orderFullPrice - itemsTotal