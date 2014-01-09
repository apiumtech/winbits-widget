ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
module.exports = class Cart extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'loadVirtualCart', @loadVirtualCart

  parse: (response) ->
    console.log "Cart#parse"
    @completeCartModel(response.response)

  loadVirtualCart: ()->
    console.log "Loading virtual cart"
    @url = config.apiUrl + "/orders/virtual-cart-items.json"
    @fetch
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-vcart': util.retrieveKey(config.vcartTokenName)}
      success: ->
        console.log "success load Virtual cart"
      complete: ->
        console.log "complete"

  transferVirtualCart: (virtualCart)->
    console.log ["transferVirtualCart"]
    that = @
    formData = virtualCartData: JSON.parse(virtualCart)
    util.ajaxRequest config.apiUrl + "/orders/assign-virtual-cart.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        util.storeKey config.vcartTokenName, '[]', 7
        that.set that.completeCartModel(data.response)
        Winbits.rpc.storeVirtualCart('[]')
        that.publishEvent 'doCheckout' if mediator.flags.autoCheckout

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        mediator.flags.autoCheckout = false

  updateUserCartDetail : (cartItem, $cartPanel) ->
    formData =
      quantity: cartItem.quantity
      bits: cartItem.bits or 0
    util.showAjaxIndicator('Actualizando carrito...')
    that = @
    util.ajaxRequest config.apiUrl + "/orders/cart-items/" + cartItem.id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
#      context: { cartItem: cartItem, $cartPanel: $cartPanel, model: @ }
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.retrieveKey(config.apiTokenName)

      success: (data) ->
        that.set that.completeCartModel data.response
        if $cartPanel
          $cartPanel.slideDown()
        cartItem.success.apply(cartItem, arguments) if w$.isFunction cartItem.success

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)
        cartItem.error.apply(cartItem, arguments) if w$.isFunction cartItem.error

      complete: ->
        util.hideAjaxIndicator()
        cartItem.complete.apply(cartItem, arguments) if w$.isFunction cartItem.complete


  updateVirtualCartDetail: (cartItem, $cartPanel)->
    @url = config.apiUrl + "/orders/virtual-cart-items/" + cartItem.id + ".json"
    formData = quantity: cartItem.quantity
    util.showAjaxIndicator('Actualizando carrito...')
    that = @
    util.ajaxRequest config.apiUrl + "/orders/virtual-cart-items/" + cartItem.id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
#      context: { cartItem: cartItem, $cartPanel: $cartPanel, model: @ }
      headers:
        "Accept-Language": "es"
        "wb-vcart": util.retrieveKey(config.vcartTokenName)

      success: (data) ->
        that.storeVirtualCart data.response
        that.set that.completeCartModel(data.response)
        if $cartPanel
          $cartPanel.slideDown()
        cartItem.success.apply(cartItem, arguments) if w$.isFunction cartItem.success

      error: (xhr) ->
        console.log ['PROBLEMS', xhr.responseText]
        util.showAjaxError(xhr.responseText)
        cartItem.error.apply(cartItem, arguments) if w$.isFunction cartItem.error

      complete: ->
        util.hideAjaxIndicator()
        cartItem.complete.apply(cartItem, arguments) if w$.isFunction cartItem.complete

  deleteVirtualCartDetail: (id)->
    console.log ["deleteVirtualCartDetail"]
    that = @
    util.showAjaxIndicator('Eliminando artículo...')
    @url = config.apiUrl + "/orders/virtual-cart-items/" + id + ".json"
    @sync 'delete', @,
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-vcart': util.retrieveKey(config.vcartTokenName) }
      success: (data)->
        console.log "success deleteVirtaulCart"
        that.storeVirtualCart data.response
        that.set that.completeCartModel(data.response)
        that.closeCartIfEmpty()
      complete: ->
        util.hideAjaxIndicator()

  deleteUserCartDetail : (id) ->
    that = @
    util.showAjaxIndicator('Eliminando artículo...')
    @url = config.apiUrl + "/orders/cart-items/" + id + ".json"
    @sync 'delete', @,
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.retrieveKey(config.apiTokenName) }
      success: (data) ->
        that.set that.completeCartModel data.response
        that.closeCartIfEmpty()
      error: (xhr) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        util.hideAjaxIndicator()

  loadUserCart: ()->
    console.log ["loadUserCart"]
    @url = config.apiUrl + "/orders/cart-items.json"
    console.log "LOADING USER CART COOKIE ->>> "+util.getCookie(config.apiTokenName)
    @fetch
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.retrieveKey(config.apiTokenName)},
      error: ->
        console.log "error",
      success: ->
        console.log "success loadUserCart"
        #that.$el.find(".myPerfil").slideDown()
          #that.$el.find(".editMiPerfil").slideUp()

      complete: ->
        console.log "complete transaction"

  addToUserCart : (cartItems, $cartPanel, options) ->
    console.log "Adding to user cart..."
    @addToCart
      cartItems: cartItems
      $cartPanel: $cartPanel
      options: options
      url: "/orders/cart-items.json"
      headers: "WB-Api-Token": util.retrieveKey(config.apiTokenName)

  addToCart : (data) ->
    cartItems = data.cartItems
    $cartPanel = data.$cartPanel
    options = data.options
    formData = cartItems: []
    w$.each cartItems, (index, cartItem) ->
      formData.cartItems.push skuProfileId: cartItem.id, quantity: cartItem.quantity, bits: cartItem.bits or 0
    util.showAjaxIndicator('Agregando artículo(s)...')
    headers = w$.extend {"Accept-Language": "es"}, data.headers
    that =@
    util.ajaxRequest( config.apiUrl + data.url,
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
#      context: model: @, cartItems: cartItems, options: options, $cartPanel: $cartPanel
      headers: headers
      success: (data) ->
        that.set that.completeCartModel data.response
        if $cartPanel
          $cartPanel.slideDown()
        options.success.apply(cartItems, arguments) if w$.isFunction options.success
      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
        options.error.apply(cartItems, arguments) if w$.isFunction options.error
      complete: ->
        util.hideAjaxIndicator()
        options.complete.apply(cartItems, arguments) if w$.isFunction options.complete
    )

  addToVirtualCart : (cartItems, $cartPanel, options) ->
    console.log "Adding to virtual cart..."
    @addToCart
      cartItems: cartItems
      $cartPanel: $cartPanel
      options: options
      url: "/orders/virtual-cart-items.json"
      headers: "wb-vcart": util.retrieveKey(config.vcartTokenName)

  storeVirtualCart : (cart) ->
    console.log ["Storing virtual cart...", cart]
    vCart = []
    Winbits.$.each cart.cartDetails or [], (i, cartDetail) ->
      vCartDetail = {}
      vCartDetail[cartDetail.skuProfile.id] = cartDetail.quantity
      vCart.push vCartDetail

    vCartToken = JSON.stringify(vCart)
    console.log ["vCartToken", vCartToken]
    util.storeKey config.vcartTokenName, vCartToken, 7
    Winbits.rpc.storeVirtualCart(vCartToken)

  completeCartModel: (model) ->
    total = model.itemsTotal + model.shippingTotal
    model.total = total
    bitsTotal = @get('bitsTotal') || 0
    if mediator.flags.loggedIn
      bitsTotal = model.bitsTotal
      model.maxBits = Math.min(mediator.profile.bitsBalance, total)

    else
      bitsTotal = Math.min(bitsTotal, model.total)
      model.maxBits = total
    model.bitsTotal = bitsTotal
    @publishEvent('cartBitsUpdated', model)
    model

  findCartDetail: (id) ->
    cartDetails = @get('cartDetails') || []
    cartDetail = `undefined`
    w$.each cartDetails, (index, detail) ->
      if detail.skuProfile.id is id
        cartDetail = detail
        return false
    cartDetail

  updateCartBits: (bits) ->
#    util.showAjaxIndicator('Actualizando bits...')
    that = @
    util.ajaxRequest config.apiUrl + "/orders/update-cart-bits.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify({bitsTotal: bits})
#      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        that.set 'bitsTotal', data.response.bitsTotal
        that.publishEvent('cartBitsUpdated', data.response)

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
#        util.hideAjaxIndicator()
        
  closeCartIfEmpty: () ->
    $ = Winbits.$
    $cartDetailList = $('.wb-cart-detail-list')
    if $cartDetailList.children().length is 0
      $cartDetailList.closest('.dropMenu').slideUp()
