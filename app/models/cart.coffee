ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
module.exports = class Cart extends ChaplinModel

  initialize: (attributes, option) ->
    super
    @subscribeEvent 'loadVirtualCart', @loadVirtualCart
    #@subscribeEvent 'fetchCart', @fetch

  parse: (response) ->
    console.log "Cart#parse"
    @completeCartModel(response.response)

  loadVirtualCart: ()->
    console.log "Loading virtual cart"
    @url = config.apiUrl + "/orders/virtual-cart-items.json"
    that = @
    @fetch
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-vcart': util.getCookie(config.vcartTokenName)}
      #headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.getCookie(config.apiTokenName)}
      success: ->
        console.log "success load Virtual cart"
      complete: ->
        console.log "complete"

  transferVirtualCart: (virtualCart)->
    console.log ["transferVirtualCart"]
    that = @
#    util.showAjaxIndicator()
    formData = virtualCartData: JSON.parse(virtualCart)
    Backbone.$.ajax config.apiUrl + "/orders/assign-virtual-cart.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        util.setCookie config.vcartTokenName, '[]', 7
        that.set that.completeCartModel(data.response)
        mediator.proxy.post
          action: "storeVirtualCart"
          params: ['[]']

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
#        util.hideAjaxIndicator()

  updateUserCartDetail : (cartItem, $cartPanel) ->
    formData =
      quantity: cartItem.quantity
      bits: cartItem.bits or 0
    that = @
    util.showAjaxIndicator('Actualizando carrito...')
    Backbone.$.ajax config.apiUrl + "/orders/cart-items/" + cartItem.id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      context: cartItem
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(config.apiTokenName)

      success: (data) ->
        that.set that.completeCartModel data.response
        if $cartPanel
          $cartPanel.slideDown()
        this.success.apply(this, arguments) if typeof this.success is 'function'

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)
        this.error.apply(this, arguments) if typeof this.error is 'function'

      complete: ->
        util.hideAjaxIndicator()
        this.complete.apply(this, arguments) if typeof this.complete is 'function'

  updateVirtualCartDetail: (cartItem, $cartPanel)->
    @url = config.apiUrl + "/orders/virtual-cart-items/" + cartItem.id + ".json"
    formData = quantity: cartItem.quantity
    that = @
    util.showAjaxIndicator('Actualizando carrito...')
    Backbone.$.ajax config.apiUrl + "/orders/virtual-cart-items/" + cartItem.id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      context: cartItem
      data: JSON.stringify(formData)
      context: cartItem
      headers:
        "Accept-Language": "es"
        "wb-vcart": util.getCookie(config.vcartTokenName)

      success: (data) ->
        that.storeVirtualCart data.response
        that.set that.completeCartModel(data.response)
        if $cartPanel
          $cartPanel.slideDown()
        this.success.apply(this, arguments) if typeof this.success is 'function'

      error: (xhr) ->
        console.log ['PROBLEMS', xhr.responseText]
        util.showAjaxError(xhr.responseText)
        this.error.apply(this, arguments) if typeof this.error is 'function'

      complete: ->
        util.hideAjaxIndicator()
        this.complete.apply(this, arguments) if typeof this.complete is 'function'

  deleteVirtualCartDetail: (id)->
    console.log ["deleteVirtualCartDetail"]
    that = @
    util.showAjaxIndicator('Eliminando artículo...')
    @url = config.apiUrl + "/orders/virtual-cart-items/" + id + ".json"
    @sync 'delete', @,
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-vcart': util.getCookie(config.vcartTokenName) }
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
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.getCookie(config.apiTokenName) }
      success: (data) ->
        console.log ["V: User cart", data.response]
        that.set that.completeCartModel data.response
        that.closeCartIfEmpty()
      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()

  loadUserCart: ()->
    console.log ["loadUserCart"]
    @url = config.apiUrl + "/orders/cart-items.json"
    @fetch
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.getCookie(config.apiTokenName)},
      success: ->
        console.log "success loadUserCart"
        #that.$el.find(".myPerfil").slideDown()
          #that.$el.find(".editMiPerfil").slideUp()
      complete: ->
        console.log "complete"

  addToUserCart : (cartItem, $cartPanel) ->
    console.log "Adding to user cart..."
    formData =
      skuProfileId: cartItem.id
      quantity: cartItem.quantity
      bits: cartItem.bits or 0
    that = this
    util.showAjaxIndicator('Agregando artículo...')
    Backbone.$.ajax config.apiUrl + "/orders/cart-items.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      context: cartItem
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        that.set that.completeCartModel data.response
        if $cartPanel
          $cartPanel.slideDown()
        this.success.apply(this, arguments) if typeof this.success is 'function'

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
        this.error.apply(this, arguments) if typeof this.error is 'function'

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()
        this.complete.apply(this, arguments) if typeof this.complete is 'function'

  addToVirtualCart : (cartItem, $cartPanel) ->
    console.log "Adding to virtual cart..."
    formData =
      skuProfileId: cartItem.id
      quantity: cartItem.quantity
      bits: 0
    that = this
    util.showAjaxIndicator('Agregando artículo...')
    Backbone.$.ajax config.apiUrl + "/orders/virtual-cart-items.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      context: cartItem
      headers:
        "Accept-Language": "es"
        "wb-vcart": util.getCookie(config.vcartTokenName)

      success: (data) ->
        console.log ["V: Virtual cart", data.response]
        that.storeVirtualCart data.response
        that.set that.completeCartModel(data.response)
        if $cartPanel
          $cartPanel.slideDown()
        this.success.apply(this, arguments) if typeof this.success is 'function'

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)
        this.error.apply(this, arguments) if typeof this.error is 'function'

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()
        this.complete.apply(this, arguments) if typeof this.complete is 'function'

  storeVirtualCart : (cart) ->
    console.log ["Storing virtual cart...", cart]
    vCart = []
    Backbone.$.each cart.cartDetails or [], (i, cartDetail) ->
      vCartDetail = {}
      vCartDetail[cartDetail.skuProfile.id] = cartDetail.quantity
      vCart.push vCartDetail

    vCartToken = JSON.stringify(vCart)
    console.log ["vCartToken", vCartToken]
    util.setCookie config.vcartTokenName, vCartToken, 7
    mediator.proxy.post
      action: "storeVirtualCart"
      params: [vCartToken]

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
    Backbone.$.ajax config.apiUrl + "/orders/update-cart-bits.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify({bitsTotal: bits})
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["Success: Update cart bits", data.response]
        @set 'bitsTotal', data.response.bitsTotal
        @publishEvent('cartBitsUpdated', data.response)

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
#        util.hideAjaxIndicator()
        
  closeCartIfEmpty: () ->
    $ = Backbone.$
    $cartDetailList = $('.wb-cart-detail-list')
    if $cartDetailList.children().length is 0
      $cartDetailList.closest('.dropMenu').slideUp()