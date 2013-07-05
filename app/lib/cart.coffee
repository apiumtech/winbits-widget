
module.exports = class Cart

  addToCart : (cartItem) ->
    console.log ["Vertical request to add item to cart", cartItem]
    alert "Please specify a cart item object: {id: 1, quantity: 1}"  unless cartItem
    alert "Id required! Please specify a cart item object: {id: 1, quantity: 1}"  unless cartItem.id
    cartItem.id = parseInt(cartItem.id)
    if not cartItem.quantity or cartItem.quantity < 1
      console.log "Setting default quantity (1)..."
      cartItem.quantity = 1
    cartItem.quantity = parseInt(cartItem.quantity)
    $cartDetail = app.$widgetContainer.find(".cart-holder:visible .cart-details-list").children("[data-id=" + cartItem.id + "]")
    if $cartDetail.length is 0
      if app.Flags.loggedIn
        app.addToUserCart cartItem.id, cartItem.quantity, cartItem.bits
      else
        app.addToVirtualCart cartItem.id, cartItem.quantity
    else
      qty = cartItem.quantity + parseInt($cartDetail.find(".cart-detail-quantity").val())
      app.updateCartDetail $cartDetail, qty, cartItem.bits

  addToUserCart : (id, quantity, bits) ->
    console.log "Adding to user cart..."
    $ = app.jQuery
    formData =
      skuProfileId: id
      quantity: quantity
      bits: bits

    $.ajax app.config.apiUrl + "/orders/cart-items.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": app.getCookie(app.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        app.refreshCart $, data.response, true

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "Request Completed!"


  storeVirtualCart : ($, cart) ->
    console.log ["Storing virtual cart...", cart]
    vCart = []
    $.each cart.cartDetails or [], (i, cartDetail) ->
      vCartDetail = {}
      vCartDetail[cartDetail.skuProfile.id] = cartDetail.quantity
      vCart.push vCartDetail

    vCartToken = JSON.stringify(vCart)
    console.log ["vCartToken", vCartToken]
    app.setCookie app.vcartTokenName, vCartToken, 7
    app.proxy.post
      action: "storeVirtualCart"
      params: [vCartToken]


  refreshCart : ($, cart, showCart) ->
    console.log ["Refreshing cart...", cart]
    $cartHolder = app.$widgetContainer.find(".cart-holder:visible")
    $cartHolder.find(".cart-items-count").text cart.itemsCount or 0
    $cartInfo = $cartHolder.find(".cart-info")
    $cartInfo.find(".cart-shipping-total").text cart.shippingTotal or "GRATIS"
    cartTotal = (cart.itemsTotal or 0) + (cart.shippingTotal or 0) - (cart.bitsTotal or 0)
    $cartInfo.find(".cart-total").text "$" + cartTotal
    $cartInfo.find(".cart-bits-total").text cart.bitsTotal or 0
    cartSaving = 0
    $cartInfo.find(".cart-saving").text cartSaving + "%"
    $cartDetailsList = $cartHolder.find(".cart-details-list").html("")
    $.each cart.cartDetails or [], (i, cartDetail) ->
      app.addCartDetailInto $, cartDetail, $cartDetailsList

    $cartHolder.find(".shopCarMin").trigger "click"  if showCart and not $cartHolder.find(".dropMenu").is(":visible")

  addCartDetailInto : ($, cartDetail, cartDetailsList) ->
    console.log ["Adding cart detail...", cartDetail]
    $cartDetailsList = app.$(cartDetailsList)
    $cartDetail = $("<li>" + "<a href=\"#\"><img class=\"cart-detail-thumb\" width=\"35\" height=\"45\"></a>" + "<p class=\"descriptionItem cart-detail-name\"></p>" + "<label>Cantidad</label>" + "<input type=\"text\" class=\"inputStepper cart-detail-quantity\">" + "<p class=\"priceItem cart-detail-attr\"\"></p>" + "<p class=\"priceItem cart-detail-price\"></p>" + "<span class=\"verticalName\">Producto de <em class=\"cart-detail-vertical\"></em></span>" + "<span class=\"deleteItem\"><a href=\"#\" class=\"cart-detail-delete-link\">eliminar</a></span>" + "</li>")
    $cartDetail.attr "data-id", cartDetail.skuProfile.id
    $cartDetail.find(".cart-detail-thumb").attr("src", cartDetail.skuProfile.item.thumbnail).attr "alt", "[thumbnail]"
    $cartDetail.find(".cart-detail-name").text cartDetail.skuProfile.item.name
    customStepper($cartDetail.find(".cart-detail-quantity").val(cartDetail.quantity)).on "step", (e, previous) ->
      $cartDetailStepper = $(this)
      val = parseInt($cartDetailStepper.val())
      unless previous is val
        console.log ["previous", "current", previous, val]
        app.updateCartDetail $cartDetailStepper.closest("li"), val

    attr = cartDetail.skuProfile.attributes[0]
    $cartDetail.find(".cart-detail-attr").text attr.label + ": " + attr.value  if attr
    $cartDetail.find(".cart-detail-price").text "$" + cartDetail.skuProfile.price
    $cartDetail.find(".cart-detail-vertical").text cartDetail.skuProfile.item.vertical.name
    $cartDetail.find(".cart-detail-delete-link").click app.EventHandlers.clickDeleteCartDetailLink
    $cartDetail.appendTo $cartDetailsList

  updateCartDetail : (cartDetail, quantity, bits) ->
    $cartDetail = app.$(cartDetail)
    if app.Flags.loggedIn
      app.updateUserCartDetail $cartDetail, quantity, bits
    else
      app.updateVirtualCartDetail $cartDetail, quantity

  updateUserCartDetail : (cartDetail, quantity, bits) ->
    console.log ["Updating cart detail...", cartDetail]
    $cartDetail = app.$(cartDetail)
    $ = app.jQuery
    formData =
      quantity: quantity
      bits: bits or 0

    id = $cartDetail.attr("data-id")
    $.ajax app.config.apiUrl + "/orders/cart-items/" + id + ".json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": app.getCookie(app.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        app.refreshCart $, data.response, true

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "Request Completed!"


  deleteUserCartDetail : (cartDetail) ->
    console.log ["Deleting user cart detail...", cartDetail]
    $ = app.jQuery
    $cartDetail = app.$(cartDetail)
    id = $cartDetail.attr("data-id")
    $.ajax app.config.apiUrl + "/orders/cart-items/" + id + ".json",
      type: "DELETE"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": app.getCookie(app.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        app.refreshCart $, data.response

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


  updateVirtualCartDetail : (cartDetail, quantity) ->
    console.log ["Updating cart detail...", cartDetail]
    $cartDetail = app.$(cartDetail)
    $ = app.jQuery
    formData = quantity: quantity
    id = $cartDetail.attr("data-id")
    $.ajax app.config.apiUrl + "/orders/virtual-cart-items/" + id + ".json",
      type: "PUT"
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


  deleteVirtualCartDetail : (cartDetail) ->
    console.log ["Deleting virtual cart detail...", cartDetail]
    $ = app.jQuery
    $cartDetail = app.$(cartDetail)
    id = $cartDetail.attr("data-id")
    $.ajax app.config.apiUrl + "/orders/virtual-cart-items/" + id + ".json",
      type: "DELETE"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "wb-vcart": app.getCookie(app.vcartTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        app.storeVirtualCart $, data.response
        app.refreshCart $, data.response

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        console.log error.meta.message

      complete: ->
        console.log "Request Completed!"

  loadUserCart : ($) ->
    $.ajax app.config.apiUrl + "/orders/cart-items.json",
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": app.getCookie(app.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        app.refreshCart $, data.response

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.message

      complete: ->
        console.log "Request Completed!"


  loadVirtualCart : ($) ->
    $.ajax app.config.apiUrl + "/orders/virtual-cart-items.json",
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "wb-vcart": app.getCookie(app.vcartTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        app.refreshCart $, data.response

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.message

      complete: ->
        console.log "Request Completed!"




  restoreCart : ($) ->
    vCart = app.getCookie(app.vcartTokenName)
    unless vCart is "[]"
      app.transferVirtualCart $, vCart
    else
      app.loadUserCart $

  transferVirtualCart : ($, virtualCart) ->
    formData = virtualCartData: JSON.parse(virtualCart)
    $.ajax app.config.apiUrl + "/orders/assign-virtual-cart.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": app.getCookie(app.apiTokenName)

      success: (data) ->
        console.log ["V: User cart", data.response]
        app.setCookie app.vcartTokenName, "[]", 7
        app.proxy.post
          action: "storeVirtualCart"
          params: ["[]"]

        app.refreshCart $, data.response

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.message

      complete: ->
        console.log "Request Completed!"

