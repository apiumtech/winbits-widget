ChaplinModel = require 'chaplin/models/model'
util = require 'lib/util'
config = require 'config'
module.exports = class Cart extends ChaplinModel

  initialize: (attributes, option) ->
    super
    #@subscribeEvent 'setCart', @set
    #@subscribeEvent 'fetchCart', @fetch

  parse: (response) ->
    console.log "Cart#parse"
    response.response

  loadVirtualCart: ()->
    console.log "Loading virtual cart"
    @url = config.apiUrl + "/orders/virtual-cart-items.json"
    @sync 'read', @,
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-cart': util.getCookie(config.vcartTokenName) }
      success: ->
        console.log "success load Virtual cart"


  transferVirtualCart: ()->
    console.log ["transferVirtualCart"]
    @url = config.apiUrl + "/orders/assign-virtual-cart.json"
    @sync 'create', @,
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-cart': util.getCookie(config.vcartTokenName) }
      success: ->
        console.log "success transferVirtualCart"

  updateUserCartDetail : (id, quantity, bits) ->
    console.log ["Updating cart detail...", cartDetail]
    $ = app.jQuery
    formData =
      quantity: quantity
      bits: bits or 0

    $.ajax app.config.apiUrl + "/orders/cart-items/" + id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": util.getCookie(conf.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "Request Completed!"

  updateVirtualCartDetail: (id, quantity)->
    console.log ["Updating cart detail...", cartDetail]
    @url = config.apiUrl + "/orders/virtual-cart-items/" + @model.id + ".json"
    formData = quantity: quantity
    id = $cartDetail.attr("data-id")
    $.ajax app.config.apiUrl + "/orders/virtual-cart-items/" + id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "wb-vcart": util.getCookie(config.vcartTokenName)

      success: (data) ->
        console.log ["V: Virtual cart", data.response]


      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        console.log error.meta.message

      complete: ->
        console.log "Request Completed!"

  updateCartDetail : (id, quantity, bits) ->
    console.log ["updateCartDetail"]
    if mediator.flags.loggedIn
      @updateUserCartDetail id, quantity, bits
    else
      @updateVirtualCartDetail id, quantity

  deleteVirtualCartDetail: ()->
    console.log ["deleteVirtualCartDetail"]
    @url = config.apiUrl + "/orders/virtual-cart-items/" + @model.id + ".json"
    @ 'delete', @,
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-cart': util.getCookie(config.vcartTokenName) }
      success: ->
        console.log "success loadUserCart"

  loadUserCart: ()->
    console.log ["loadUserCart"]
    @url = config.apiUrl + "/orders/cart-items.json"
    console.log @
    @fetch
      error: ->
        console.log "error",
      headers:{ 'Accept-Language': 'es', 'wb-cart': util.getCookie(config.vcartTokenName) }
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
        #app.refreshCart $, data.response, true

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "Request Completed!"

  addToVirtualCart : (id, quantity) ->
    console.log "Adding to virtual cart..."
    $ = app.jQuery
    formData =
      skuProfileId: id
      quantity: quantity
      bits: 0

    $.ajax app.config.apiUrl + "/orders/virtual-cart-items.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "wb-vcart": app.getCookie(app.vcartTokenName)

      success: (data) ->
        console.log ["V: Virtual cart", data.response]
        app.storeVirtualCart $, data.response
        app.refreshCart $, data.response, true

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        console.log error.meta.message

      complete: ->
        console.log "Request Completed!"
