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
    util.showAjaxIndicator()
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
        util.hideAjaxIndicator()

  transferVirtualCart: (virtualCart)->
    console.log ["transferVirtualCart"]
    that = @
    util.showAjaxIndicator()
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
        util.hideAjaxIndicator()

  updateUserCartDetail : (id, quantity, bits, $cartPanel) ->
    formData =
      quantity: quantity
      bits: bits or 0
    that = @
    util.showAjaxIndicator()
    Backbone.$.ajax config.apiUrl + "/orders/cart-items/" + id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(config.apiTokenName)

      success: (data) ->
        that.set that.completeCartModel data.response
        if $cartPanel
          $cartPanel.slideDown()

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()

  updateVirtualCartDetail: (id, quantity, $cartPanel)->
    @url = config.apiUrl + "/orders/virtual-cart-items/" + id + ".json"
    formData = quantity: quantity
    that = @
    util.showAjaxIndicator()
    Backbone.$.ajax config.apiUrl + "/orders/virtual-cart-items/" + id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "wb-vcart": util.getCookie(config.vcartTokenName)

      success: (data) ->
        that.storeVirtualCart data.response
        that.set that.completeCartModel(data.response)
        if $cartPanel
          $cartPanel.slideDown()

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()


  deleteVirtualCartDetail: (id)->
    console.log ["deleteVirtualCartDetail"]
    that = @
    util.showAjaxIndicator()
    @url = config.apiUrl + "/orders/virtual-cart-items/" + id + ".json"
    @sync 'delete', @,
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-vcart': util.getCookie(config.vcartTokenName) }
      success: (data)->
        console.log "success deleteVirtaulCart"
        that.storeVirtualCart data.response
        that.set that.completeCartModel(data.response)
      complete: ->
        util.hideAjaxIndicator()

  deleteUserCartDetail : (id) ->
    that = @
    util.showAjaxIndicator()
    @url = config.apiUrl + "/orders/cart-items/" + id + ".json"
    @sync 'delete', @,
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.getCookie(config.apiTokenName) }
      success: (data) ->
        console.log ["V: User cart", data.response]
        that.set that.completeCartModel data.response
      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()

  loadUserCart: ()->
    console.log ["loadUserCart"]
    util.showAjaxIndicator()
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
        util.hideAjaxIndicator()

  addToUserCart : (id, quantity, bits, $cartPanel) ->
    console.log "Adding to user cart..."
    formData =
      skuProfileId: id
      quantity: quantity
      bits: bits
    that = this
    util.showAjaxIndicator()
    Backbone.$.ajax config.apiUrl + "/orders/cart-items.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        that.set that.completeCartModel data.response
        if $cartPanel
          $cartPanel.slideDown()

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()

  addToVirtualCart : (id, quantity, $cartPanel) ->
    console.log "Adding to virtual cart..."
    formData =
      skuProfileId: id
      quantity: quantity
      bits: 0
    that = this
    util.showAjaxIndicator()
    Backbone.$.ajax config.apiUrl + "/orders/virtual-cart-items.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "wb-vcart": util.getCookie(config.vcartTokenName)

      success: (data) ->
        console.log ["V: Virtual cart", data.response]
        that.storeVirtualCart data.response
        that.set that.completeCartModel(data.response)
        if $cartPanel
          $cartPanel.slideDown()

      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "Request Completed!"
        util.hideAjaxIndicator()

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
    util.showAjaxIndicator()
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
        util.hideAjaxIndicator()