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
    response.response

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


  transferVirtualCart: (virtualCart)->
    console.log ["transferVirtualCart"]
    that = @
    formData = virtualCartData: JSON.parse(virtualCart)
    $.ajax config.apiUrl + "/orders/assign-virtual-cart.json",
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
        that.set data.response
        mediator.proxy.post
          action: "storeVirtualCart"
          params: ['[]']

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.message

      complete: ->
        console.log "Request Completed!"

  updateUserCartDetail : (id, quantity, bits) ->
    console.log ["Updating cart detail..."]
    formData =
      quantity: quantity
      bits: bits or 0
    that = @
    $.ajax config.apiUrl + "/orders/cart-items/" + id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        that.set data.response

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "Request Completed!"

  updateVirtualCartDetail: (id, quantity)->
    console.log ["Updating cart detail..."]
    @url = config.apiUrl + "/orders/virtual-cart-items/" + id + ".json"
    formData = quantity: quantity
    that = @
    $.ajax config.apiUrl + "/orders/virtual-cart-items/" + id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "wb-vcart": util.getCookie(config.vcartTokenName)

      success: (data) ->
        console.log ["V: Virtual cart", data.response]
        that.storeVirtualCart data.response
        that.set data.response


      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        console.log error.meta.message

      complete: ->
        console.log "Request Completed!"


  deleteVirtualCartDetail: (id)->
    console.log ["deleteVirtualCartDetail"]
    that = @
    @url = config.apiUrl + "/orders/virtual-cart-items/" + id + ".json"
    @sync 'delete', @,
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-vcart': util.getCookie(config.vcartTokenName) }
      success: (data)->
        console.log "success deleteVirtaulCart"
        that.storeVirtualCart data.response
        that.set data.response

  deleteUserCartDetail : (id) ->
    that = @
    @url = config.apiUrl + "/orders/cart-items/" + id + ".json"
    @sync 'delete', @,
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.getCookie(config.apiTokenName) }
      success: (data) ->
        console.log ["V: User cart", data.response]
        that.set data.response
      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "Request Completed!"

  loadUserCart: ()->
    console.log ["loadUserCart"]
    @url = config.apiUrl + "/orders/cart-items.json"
    console.log @
    @fetch
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', "WB-Api-Token": util.getCookie(config.apiTokenName)},
      success: ->
        console.log "success loadUserCart"
        #that.$el.find(".myPerfil").slideDown()
          #that.$el.find(".editMiPerfil").slideUp()

  addToUserCart : (id, quantity, bits) ->
    console.log "Adding to user cart..."
    formData =
      skuProfileId: id
      quantity: quantity
      bits: bits
    that = this
    $.ajax config.apiUrl + "/orders/cart-items.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        that.set data.response
        #app.refreshCart $, data.response, true

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "Request Completed!"

  addToVirtualCart : (id, quantity) ->
    console.log "Adding to virtual cart..."
    formData =
      skuProfileId: id
      quantity: quantity
      bits: 0
    that = this
    $.ajax config.apiUrl + "/orders/virtual-cart-items.json",
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
        that.set data.response

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        console.log error.meta.message

      complete: ->
        console.log "Request Completed!"

  storeVirtualCart : (cart) ->
    console.log ["Storing virtual cart...", cart]
    vCart = []
    $.each cart.cartDetails or [], (i, cartDetail) ->
      vCartDetail = {}
      vCartDetail[cartDetail.skuProfile.id] = cartDetail.quantity
      vCart.push vCartDetail

    vCartToken = JSON.stringify(vCart)
    console.log ["vCartToken", vCartToken]
    util.setCookie config.vcartTokenName, vCartToken, 7
    mediator.proxy.post
      action: "storeVirtualCart"
      params: [vCartToken]
