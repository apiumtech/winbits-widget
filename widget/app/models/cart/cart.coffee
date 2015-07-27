'use strict'

require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator
env = Winbits.env

module.exports = class Cart extends Model
  url: cartUtils.getCartResourceUrl
  needsAuth: yes
  accessors: [
    'cartTotal'
    'cartPercentageSaved'
    'cartSaving'
    'itemsFullTotal'
    'sliderTotal'
  ]
  defaults:
    itemsTotal: 0,
    bitsTotal: 0,
    shippingTotal: 0,
    cashback: 0

  initialize: () ->
    super

  parse: ()->
    data = super
    data.bitsTotal = utils.getBitsToVirtualCart() if not utils.isLoggedIn() and data?
    data

  sync: (method, model, options = {}) ->
    options.headers =
      'Wb-VCart': utils.getCartItemsToVirtualCart() if not utils.isLoggedIn()
    super(method, model, options)

  cartTotal: ->
    @sliderTotal() - @get('bitsTotal')

  sliderTotal: ->
    @get('itemsTotal') + @get('shippingTotal')

  itemsFullTotal: ->
    priceTotal = 0
    cartDetails = @get('cartDetails')
    if cartDetails
      priceTotal += (d.quantity * d.skuProfile.fullPrice) for d in cartDetails
    priceTotal

  cartPercentageSaved: ->
    cartTotal = @cartTotal()
    itemsFullTotal = @itemsFullTotal()
    if itemsFullTotal
      percentageSaved = (100 * ((cartTotal / itemsFullTotal) - 1)).toFixed(2)
      -1 * Math.ceil(percentageSaved)
    else 0

  cartSaving: ->
    (@itemsFullTotal() - @cartTotal()).toFixed(2)

  requestToUpdateCart:(formData,itemId, options) ->
    defaults =
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data:JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(
      cartUtils.getCartResourceUrl(itemId),
      $.extend(defaults, options)
    )

  requestToTransferVirtualCartReference:(formData, options) ->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data:JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(
        cartUtils.getCartReferenceResourceUrl(),
        $.extend(defaults, options)
    )

  updateCartBits:(formData, options) ->
    defaults =
      type: "PUT"
      data:JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(
      utils.getResourceURL("orders/update-cart-bits.json"),
      $.extend(defaults, options)
    )

  toRestoreVirtualCart:(formData,options)->
    defaults =
      headers:
        "Wb-VCart": JSON.stringify(formData)
    utils.ajaxRequest(
      utils.getResourceURL("orders/virtual-cart-items.json"),
      $.extend(defaults, options)
    )


  transferVirtualCart:(formData, options) ->
    defaults =
      type: "POST"
      data:JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()

    utils.ajaxRequest(
      utils.getResourceURL("orders/assign-virtual-cart.json"),
      $.extend(defaults, options)
    )

  requestCheckout: (options)->
    if @hasCartItems()
      defaults =
        type: 'POST'
        context: @
        headers:
          'Wb-Api-Token': utils.getApiToken()
        data: JSON.stringify(verticalId: utils.getCurrentVerticalId())
      ajaxOptions = utils.setupAjaxOptions(options, defaults)
      url = utils.getResourceURL('orders/checkout.json')
      utils.ajaxRequest(url, ajaxOptions)
        .done(@requestCheckoutSucceeds)
        .fail(@requestCheckoutFails)
    else
      utils.hideLoaderToCheckout()
      utils.showMessageModal('Para comprar, debe agregar artículos al carrito.')
      return

  requestPaymentMethods:(context)->
    cartItems = utils.getCartItemsToVirtualCart()
    utils.ajaxRequest env.get('api-url') + "/orders/virtual-cart-items/paymentMethods.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      context: context
      data: JSON.stringify(cartItems: JSON.parse(cartItems), amount: @cartTotal())
      headers:
        "Accept-Language": "es"

  hasCartItems: ->
    itemsCount = @get('itemsCount')
    itemsCount? and itemsCount > 0

  isCartEmpty: ->
    not @hasCartItems()

  requestCheckoutSucceeds: (data) ->
    @publishEvent 'checkout-completed'
    if(@validateTransferErrors(data.response))
      @postToCheckoutApp(data.response)
    else
      mediator.data.set('checkout-timestamp', _.now())
      mediator.data.set 'checkout-temp-error', data.response
      utils.redirectTo controller:'checkout-temp', action:'index'

  postToCheckoutApp: (order) ->
    checkoutURL = env.get('checkout-url')
    urlComplete = document.URL
    cookie = @obtainCookie(urlComplete)
    formAttrs =
      id: 'chk-form'
      method: 'POST'
      style: 'display:none'
      action: "#{checkoutURL}/checkout.php?_ga="+cookie
    $chkForm = $('<form></form>', formAttrs)
    $('<input type="hidden" name="token"/>').val(utils.getApiToken())
      .appendTo($chkForm)
    $('<input type="hidden" name="order_id"/>').val(order.id)
      .appendTo($chkForm)
    bitsBalance = parseInt(mediator.data.get('login-data').bitsBalance or '0')
    $('<input type="hidden" name="bits_balance"/>').val(bitsBalance)
      .appendTo($chkForm)
    currentVertical = env.get('current-vertical')
    $('<input type="hidden" name="vertical_id"/>').val(currentVertical.id)
      .appendTo($chkForm)
    $('<input type="hidden" name="vertical_url"/>').val(currentVertical.baseUrl)
      .appendTo($chkForm)
    timestamp = mediator.data.get('checkout-timestamp') or _.now()
    $('<input type="hidden" name="timestamp"/>').val(timestamp)
      .appendTo($chkForm)
    $chkForm.appendTo(document.body).submit()

  obtainCookie:(url) ->
    cookie = url.split '_ga='
    cookie = cookie[1].split '#'
    cookie = cookie[0]
    console.log("cookie -> " + cookie)
    cookie

  requestCheckoutFails: (xhr) ->
    utils.hideLoaderToCheckout()
    data = JSON.parse(xhr.responseText)
    utils.showMessageModal(data.meta.message)

  validateTransferErrors: (response)->
    warnings = _.map((response.cartDetails or response.orderDetails), (cartDetail) -> if cartDetail.warnings then cartDetail.warnings else [])
    warnings = _.flatten(warnings)
    isValid =  if (response.failedCartDetails or !$.isEmptyObject(warnings) ) then no else yes
    isValid

  doTransferVirtualCampaigns:(cartItems)->
    campaignsToTransfer = @getOfVirtualCampaignsToTransfer(cartItems)
    cartUtils.doSaveCampaigns(campaignsToTransfer)
    @cleanVirtualCampaigns()

  cleanVirtualCampaigns:->
    mediator.data.set('virtual-campaigns', '{"campaigns":{}}')
    env.get('rpc').storeVirtualCampaigns('{"campaigns":{}}')

  getOfVirtualCampaignsToTransfer:(cartItems)->
    campaignsToTransfer = []
    vCampaigns = JSON.parse(mediator.data.get('virtual-campaigns')).campaigns
    for item in cartItems
      if vCampaigns[item.skuProfile.id].campaignId
        campaignsToTransfer.push
          skuProfileId: item.skuProfile.id
          campaign: vCampaigns[item.skuProfile.id].campaignId
          type: vCampaigns[item.skuProfile.id].campaignType
    campaignsToTransfer
