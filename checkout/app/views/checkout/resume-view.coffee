template = require 'views/templates/checkout/resume'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'
vendor = require 'lib/vendor'
clock = require 'lib/clock'
mediator = require 'chaplin/mediator'

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
    that = @
    util.customStepper(@$('.inputStepper'))
    $timer = @$el.find('#wbi-resume-timer')
    $timer.data('orderId', @model.attributes.id)
    $timer.data('contentTimerId', "#wbi-alternate-checkout-flow")
    clock.startCounter( $timer )

    debounceSlide = _.debounce( ($slider, $amountEm, bits) ->
      emValue = parseInt($amountEm.text())
      if emValue is bits
        util.updateOrderDetailView(that.model, bits, $slider)
        that.updateBitsTotal bits
    , 1500)

    if mediator.profile.bitsBalance > 0
      vendor.customSlider("#wbi-bits-slide-resume").on('slidechange', (e, ui) ->
        $slider = Winbits.$(@)
        $amountEm = Winbits.$(this).find(".amount em")
        debounceSlide $slider, $amountEm, ui.value
      )


  showResume: (data) ->
    console.log ['Resume', data]
    $ = Winbits.$
    $main = $('main').first()
    $main.children().hide()
    data.maxBits = @calculateMaxBits data.total, mediator.profile.bitsBalance
    @publishEvent 'updateResumeModel', data

  handlerModelReady: ->
    @render()
    util.showWrapperView("#wbi-alternate-checkout-flow")
    $currentClock = @model.attributes.currentClock
    if $currentClock?
      $timer = @$el.find('#wbi-resume-timer')
      data = $currentClock.split(":")
      $timer.data('minutes', parseInt(data[0]) )
      $timer.data('seconds', ( parseInt(data[1]) ) )
      $timer.text $currentClock

  updateQuantityItem: (e) ->
    $currentTarget = @$(e.currentTarget)
    skuProfileId =  $currentTarget.attr("id").split("-")[1]
    skuProfileIdInt = parseInt(skuProfileId)
    quantity = parseInt $currentTarget.val()
    orderId = @model.attributes.id

    data = {skuProfileId: skuProfileId, orderId: orderId, quantity: quantity}
    url = config.apiUrl + "/orders/order-item/add.json"
    util.showAjaxIndicator()
    that = @
    util.ajaxRequest( url,
      type: "POST"
      contentType: "application/json"
      dataType: "json"
#      context: @
      data: JSON.stringify(data)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)
      success: (data) ->
        console.log ["Add order item Success!", data]
        orderDetails = that.model.attributes.orderDetails
        items = orderDetails.map( (it) ->
          if it.sku.id is skuProfileIdInt
            it.quantity = quantity
            it.amount = it.sku.price * quantity
          it
        )
        that.updateResumeView items
      error: (xhr) ->
        that.updateResumeView that.model.attributes.orderDetails
        console.log xhr
        util.showAjaxError(xhr.responseText)
      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()
    )


  deleteItem: (e) ->
    $currentTarget = @$(e.currentTarget)
    skuProfileId =  $currentTarget.attr("id").split("-")[1]
    orderDetails = @model.attributes.orderDetails
    skuProfileIdInt = parseInt(skuProfileId)
    items = orderDetails.filter (it) ->  it.sku.id isnt skuProfileIdInt
    if items? and items.length > 0
      @updateResumeView items
    else
      if confirm "Tu orden será cancelada al quitar el último \nartículo de tu carrito. ¿Deseas continuar?"
        @cancelOrder @model.attributes.id
        @publishEvent 'restoreCart'
        util.backToSite(e)

  cancelOrder: (orderId) ->
    url = config.apiUrl + "/orders/orders/"+orderId+".json"
    util.showAjaxIndicator()
    util.ajaxRequest( url,
      type: "DELETE"
      contentType: "application/json"
      dataType: "json"
#      context: @
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)
      success: (data) ->
        console.log ["Cancel order Success!", data]
      error: (xhr) ->
        console.log xhr
        util.showAjaxError(xhr.responseText)
      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()
    )

  updateBitsTotal: (bitsTotal) ->
    console.log ['update bits total', bitsTotal]
    cashTotal = @calculateCashTotal @model.attributes.total, bitsTotal
    @publishEvent 'updateResumeModel', {bitsTotal: bitsTotal, cashTotal: cashTotal}

  updateResumeView: (items)->
    itemsTotal = @calculateItemsTotal items
    shippingTotal = @calculateShippingTotal @model.attributes.shippingTotal, items
    total = @calculateTotal itemsTotal, shippingTotal
    bitsTotal = @calculateBitsTotal total, @model.attributes.bitsTotal
    cashTotal = @calculateCashTotal total, bitsTotal
    orderSaving = @calculateOrderSaving total, items, bitsTotal, shippingTotal
    maxBits = @calculateMaxBits total, mediator.profile.bitsBalance
    currentClock = @$el.find('#wbi-resume-timer').text()
    resultMap = {
      orderDetails: items,
      itemsTotal: itemsTotal,
      shippingTotal: shippingTotal,
      bitsTotal: bitsTotal,
      cashTotal: cashTotal,
      total: total,
      orderSaving: orderSaving,
      maxBits: maxBits,
      currentClock: currentClock
    }
    @publishEvent 'updateResumeModel', resultMap

  backToSite: (e) ->
    clock.expireOrder @model.attributes.id
    util.backToSite(e)

  checkoutFromResume: (e) ->
    updateData = {bitsTotal: @model.attributes.bitsTotal, orderId: @model.attributes.id }
    that=@
    util.ajaxRequest( config.apiUrl + "/orders/update-order-bits.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(updateData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        console.log ["Success: Syncronize bits", data.response]
        that.publishEvent 'postToCheckoutApp', that.model.attributes
      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
    )

  calculateItemsTotal: (orderDetails) ->
    amounts = _.map orderDetails, (a) -> a.amount
    _.reduce amounts, (x, y) -> x + y

  calculateCashTotal: (total, bitsTotal) ->
    total - bitsTotal

  calculateTotal: (itemsTotal, shippingTotal) ->
    itemsTotal + shippingTotal

  calculateShippingTotal: (shippingTotal, items) ->
    requiredShippingItem = items.filter (it) ->  it.requiresShipping is true
    if requiredShippingItem? and requiredShippingItem.length > 0
      shippingTotal
    else
      0

  calculateOrderSaving: (total, items, bitsTotal, shippingTotal) ->
    orderFullPrice = util.calculateOrderFullPrice(items) + shippingTotal
    orderFullPrice - total + bitsTotal

  calculateMaxBits: (total, bitsBalance) ->
    Math.min(total, bitsBalance)

  calculateBitsTotal: (total, bitsTotal) ->
    Math.min(total, bitsTotal)
