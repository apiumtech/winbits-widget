'use strict'

# Cart-specific utilities
# ------------------------------

utils = require 'lib/utils'
i18n = require 'i18n/messages'
EventBroker = Chaplin.EventBroker
$ = Winbits.$
env = Winbits.env
_ = Winbits._
mediator = Winbits.Chaplin.mediator

cartUtils = {}
_(cartUtils).extend
  getCartResourceUrl:(itemId) ->
    resource = if itemId then "cart-items/#{itemId}.json" else 'cart-items.json'
    if not utils.isLoggedIn()
      resource = "virtual-#{resource}"
    utils.getResourceURL "orders/#{resource}"

  addToUserCart: (cartItems = {}) ->
    cartItems = @transformCartItems(cartItems)
    cartItems = @validateBits(cartItems)
    options =
      headers:
        'Wb-Api-Token': utils.getApiToken()
    options = @applyAddToCartRequestDefaults(cartItems, options)
    utils.ajaxRequest(@getCartResourceUrl(), options)
    .done((data)->@publishCartChangedEvent(data,cartItems))
    .fail(@showCartErrorMessage)

  validateBits:(cartItems)->
    $bitsList=[]
    for cartItem in cartItems
      if cartItem.bits
        $bitsList.push(cartItem.bits)
    if $bitsList.length > 0
      $bitsBalance = parseInt($('#wbi-my-bits').text().toString().replace(/\,/g,''))
      $bitsList = ((if cart.bits then cart.bits else 0) for cart in cartItems)
      $bits=0
      for bits in $bitsList
        $bits+=bits
      console.log ["Bits reduce", $bits]
      if($bits != 0 && $bitsBalance < $bits )
        cartItems = (for cartItem in cartItems
          delete cartItem.bits
          cartItem
        )
        if $bitsBalance
          cartItems[0].bits = $bitsBalance
    cartItems

  publishCartChangedEvent: (data, cartItems)->
    mediator.data.set( 'bits-to-cart',data.response.bitsTotal)
    EventBroker.publishEvent('cart-changed', data)
    if cartItems
      @doSaveCampaigns(cartItems)

  doSaveCampaigns:(cartItems)->
    if cartItems.length < 2
      @doSendCartItem(cartItems[0])
    else
      @doSendCartItems(cartItems)

  doSendCartItem:(cartItem)->
    item = @transformCartItemsToSend(cartItem)
    if(@validateCampaign(item))
      @doRequestSaveCartItemsWithCampaigns(item,'/orders/save-single-campaign.json')

  doSendCartItems:(cartItem)->
    items = (@transformCartItemsToSend(x) for x in cartItem)
    validItems = _.map(@validateCampaign(x) for x in items)
    if(validItems)
      @doRequestSaveCartItemsWithCampaigns(skuProfiles:items,'/orders/save-multi-campaign.json')

  doRequestSaveCartItemsWithCampaigns:(item,url ) ->
    options =
      type: 'PUT'
      context: @
      headers:
        'Accept-Language': 'es'
        'Content-Type': 'application/json;charset=utf-8'
        'Wb-Api-Token': utils.getApiToken()
      data: JSON.stringify(item)
    utils.ajaxRequest(env.get('api-url')+url,options)

  validateCampaign:(item)->
    item.campaignId isnt undefined and item.campaignType isnt undefined

  transformCartItemsToSend:(cartItem)->
    skuProfileId: cartItem.skuProfileId
    campaignId: cartItem.campaign
    campaignType: cartItem.type

  addToVirtualCart: (cartItems = {}) ->
    cartItems = @transformCartItems(cartItems)
    options =
      headers:
        'Accept-Language': 'es'
        'Content-Type': 'application/json;charset=utf-8'
        'Wb-VCart': utils.getCartItemsToVirtualCart()
    options = @applyAddToCartRequestDefaults(cartItems, options)
    utils.ajaxRequest(@getCartResourceUrl(), options)
    .done((data)-> @addToVirtualCartSuccess(data, cartItems))
    .fail(@showCartErrorMessage)

  addToVirtualCartSuccess: (data, cartItems) ->
    utils.saveVirtualCart(data.response)
    utils.saveVirtualCampaignsInStorage(cartItems, data.response.cartDetails)
    utils.getTotalBitsToVirtualCart(cartItems, data.response.cartDetails)
    @publishCartChangedEvent(data)



  transformCartItems: (cartItems) ->
    (@transformCartItem(x) for x in cartItems)

  transformCartItem: (cartItem) ->
    skuProfileId: cartItem.id
    quantity: cartItem.quantity
    bits: cartItem.bits
    campaign : cartItem.campaign
    type: cartItem.type


  showCartErrorMessage: (xhr, textStatus)->
    error = xhr.errorJSON or utils.safeParse(xhr.responseText)
    errorMessage = i18n.get(error.meta.code)
    if errorMessage
      message = "Error actualizando el registro #{textStatus}"
      message = error.meta.message if error?.meta?.message
      options =
        icon:'iconFont-info'
        title: i18n.get(error.meta.code).title or 'Error'
      utils.showMessageModal(message, options)
    else utils.showApiError.call(utils, arguments)

  showCartLoading: ->
    $('#wbi-loading-cart').removeClass('loader-hide')

  hideCartLoading: ->
    $('#wbi-loading-cart').addClass('loader-hide')

  doCartLoading: ->
    message = "Actualizando carrito ..."
    utils.showLoadingMessage(message)

  applyAddToCartRequestDefaults: (cartItems, options = {}) ->
    defaults =
      type: 'POST'
      dataType: 'json'
      data: JSON.stringify(cartItems: cartItems)
      context: @
      headers:
        'Accept-Language': 'es'
        'Content-Type': 'application/json;charset=utf-8'
    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions

  deleteCartItem: (cartItemId, options = {}) ->
    options = @applyDeleteCartItemRequestDefaults(options)
    utils.ajaxRequest(@getCartResourceUrl(cartItemId), options)
    .done(@publishCartChangedEvent)
    .fail(@deleteCartItemFail)

  deleteCartItemFail: ->
    console.log ['error en la api']

  applyDeleteCartItemRequestDefaults: (options = {}) ->
    defaults =
      type: 'DELETE'
      dataType: 'json'
      context: @
      headers:
        'Wb-Api-Token': utils.getApiToken()

    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions


# Prevent creating new properties and stuff.
Object.seal? cartUtils

module.exports = cartUtils
