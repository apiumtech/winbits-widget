'use strict'
require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
$ = Winbits.$
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

  sync: (method, model, options = {}) ->
    options.headers =
      'Wb-VCart': utils.getVirtualCart() if not utils.isLoggedIn()
    super(method, model, options)

  cartTotal: ->
    @sliderTotal() - @get('bitsTotal')

  sliderTotal: ->
    @get('itemsTotal') + @get('shippingTotal')


  itemsFullTotal: ->
    priceTotal = 0
    if(@get('cartDetails'))
      priceTotal = (detail.quantity * detail.skuProfile.fullPrice) for detail in @get('cartDetails')
    priceTotal



  cartPercentageSaved: ->
    cartTotal = @cartTotal()
    itemsTotal = @get('itemsTotal')
    if itemsTotal
      Math.ceil((1 - (cartTotal / itemsTotal)).toFixed(2) * 100 )
    else 0

  cartSaving: ->
    # TODO: Implementar algoritmo corecto cuando se defina
    @get 'bitsTotal'

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
      utils.showMessageModal('Para comprar, debe agregar artículos al carrito.')
      return

  hasCartItems: ->
    itemsCount = @get('itemsCount')
    itemsCount? and itemsCount > 0

  isCartEmpty: ->
    not @hasCartItems()

  requestCheckoutSucceeds: (data) ->
    # id = data.response.id
    # checkoutURL = env.get('checkout-url')
    # redirectURL = "#{checkoutURL}?orderId=#{id}"
    # window.location.assign(redirectURL)
    @postToCheckoutApp(data.response)

  postToCheckoutApp: (order) ->
    checkoutURL = env.get('checkout-url')
    $chkForm.attr('action', "#{checkoutURL}/checkout.php")
    formAttrs =
      id: 'chk-form'
      method: 'POST'
      style: 'display:none'
      action: "#{checkoutURL}/checkout.php"
    $chkForm = $('<form></form>', formAttrs)
    $('<input type="hidden" name="token"/>').val(utils.getApiToken())
      .appendTo($chkForm)
    $('<input type="hidden" name="order_id"/>').val(order.id)
      .appendTo($chkForm)
    bitsBalance = parseInt($('#wbi-my-bits').text() or '0')
    $('<input type="hidden" name="bits_balance"/>').val(bitsBalance)
      .appendTo($chkForm)
    currentVertical = env.get('current-vertical')
    $('<input type="hidden" name="vertical_id"/>').val(currentVertical.id)
      .appendTo($chkForm)
    $('<input type="hidden" name="vertical_url"/>').val(currentVertical.baseUrl)
      .appendTo($chkForm)
    $('<input type="hidden" name="timestamp"/>').val(new Date().getTime())
      .appendTo($chkForm)
    $chkForm.appendTo(document.body).submit()

  requestCheckoutFails: (xhr) ->
    data = JSON.parse(xhr.responseText)
    utils.showMessageModal(data.meta.message)
