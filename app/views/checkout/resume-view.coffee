template = require 'views/templates/checkout/resume'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'
vendor = require 'lib/vendor'

# Site view is a top-level view which is bound to body.
module.exports = class ResumeView extends View
  container: '.widgetWinbitsMain'
  autoRender: false
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  template: template

  initialize: ->
    super
    @delegate 'click', '.closeButton', @deleteItem
    @delegate 'click', '.linkBack', @backToSite
    @delegate 'click', '#checkoutFromResume', @checkoutFromResume
    @subscribeEvent 'showResume', @showResume
    @subscribeEvent 'resumeReady', @handlerModelReady

  attach: ->
    super
    vendor.customStepper(@$('.inputStepper'))

  showResume: (data) ->
    console.log ['Resume', data]
    $ = Backbone.$
    $main = $('main').first()
    $main.children().hide()
    @publishEvent 'updateResumeModel', data

  handlerModelReady: ->
    @render()

  deleteItem: (e) ->
    $currentTarget = @$(e.currentTarget)
    skuProfileId =  $currentTarget.attr("id").split("-")[1]
    console.log ['Eliminando el producto del carrito.', skuProfileId]
    url = config.apiUrl + "/orders/order-items/" + skuProfileId + ".json"
    Backbone.$.ajax url,
      type: "DELETE"
      contentType: "application/json"
      dataType: "json"
      xhrFields:
        withCredentials: true
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        resp = data.response
        respMap = {
          orderDetails: resp.orderDetails, itemsTotal: resp.itemsTotal,
          shippingTotal: resp.shippingTotal, bitsTotal: resp.bitsTotal,
          maxBits: resp.maxBits, cashTotal: resp.cashTotal
        }
        @publishEvent 'updateResumeModel', respMap

      error: (xhr, textStatus, errorThrown) ->
        console.log "delete item Error!"
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "delete item Completed!"


  backToSite: (e) ->
    util.backToSite(e)

  checkoutFromResume: (e) ->
    @publishEvent 'postToCheckoutApp', @model.attributes