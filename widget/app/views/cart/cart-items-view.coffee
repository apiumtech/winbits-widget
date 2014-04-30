'use strict'
View = require 'views/base/view'
$ = Winbits.$
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'

module.exports = class CartItemsView extends View
  container: '#wbi-cart-left-panel'
  template: require './templates/cart-items'
  id: 'wbi-cart-items'
  className: 'carritoContainer scrollPanel'
  attributes:
    'data-content': 'carritoContent'

  initialize: ->
    super

  attach: ->
    super
    @$el.scrollpane(parent: '#wbi-cart-drop')
    @$('.wbc-item-quantity').customSelect().on "change", $.proxy @doUpdateItem, @

  doUpdateItem:() ->
    quantity = @$('.wbc-item-quantity')
    itemId = quantity.closest("li").data("id")
    data = "quantity": quantity.val(), bits : 0
    requestOptions = context:@
    isLoggedIn = utils.isLoggedIn()
    if not isLoggedIn
      requestOptions.headers = {"Accept-Language": "es",'wb-vcart':utils.getVirtualCart()}
    @doCartLoading(isLoggedIn)
    @model.requestToUpdateCart(data, itemId , requestOptions)
      .done(@doUpdateItemRequestSuccess)
      .fail(@doUpdateItemRequestError)
      .always ->
        $('#wbi-cart-info').click()

  doUpdateItemRequestSuccess: (data) ->
    if not utils.isLoggedIn()
      cartUtils.addToVirtualCartSuccess(data)
    else
      cartUtils.publishCartChangedEvent(data)


  doUpdateItemRequestError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error actualizando el registro #{textStatus}"
    message = if error then error.meta.message else messageText
    options = value: "Cerrar", title:'Error', onClosed: utils.redirectToLoggedInHome()
    utils.showMessageModal(message, options)

  doCartLoading: (isLoggedIn)->
    message = "<div class='wbc-loader'/>"
    options = icon:'iconFont-clock2',title:'Actualizando carrito ...', onClosed: utils.redirectToNotLoggedInHome()
    if (isLoggedIn)
      options.onClosed =  utils.redirectToLoggedInHome()
    console.log ['options', options]
    utils.showOnlyMessageModal(message, options)