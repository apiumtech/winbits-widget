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
    @delegate 'click', '.wbc-item-delete-link', @doDeleteItem

  attach: ->
    super
    @$el.scrollpane(parent: '#wbi-cart-drop')
    @$('.wbc-item-quantity').customSelect()
      .on("change", $.proxy(@doUpdateItem, @))

  doUpdateItem:(e) ->
    e.preventDefault()
    quantity = @$(e.currentTarget)
    itemId = quantity.closest("li").data("id")
    data = "quantity": quantity.val(), bits : 0
    cartUtils.doCartLoading()
    @model.requestToUpdateCart(data, itemId , @cartRequestOptions())
      .done(@doUpdateItemRequestSuccess)
      .fail(@doUpdateItemRequestError)
      .always(@requestToUpdateCartCompletes)

  doUpdateItemRequestSuccess: (data) ->
    if not utils.isLoggedIn()
      cartUtils.addToVirtualCartSuccess(data)
    else
      cartUtils.publishCartChangedEvent(data)

  doUpdateItemRequestError: (xhr, textStatus)->
    @render()
    cartUtils.showCartErrorMessage(xhr, textStatus)

  requestToUpdateCartCompletes: ->
    utils.closeMessageModal()

  doDeleteItem: (e)->
    e.preventDefault()
    $itemId = $(e.currentTarget).closest('li').data("id")
    requestOptions = @cartRequestOptions()
    requestOptions.type = 'DELETE'
    @doCartDeleteLoading()
    @model.requestToUpdateCart(null,$itemId,requestOptions)
      .done(@doUpdateItemRequestSuccess)
      .fail(@doDeleteItemRequestError)
      .always(@requestToUpdateCartCompletes)

  cartRequestOptions: ->
    requestOptions = context:@
    isLoggedIn = utils.isLoggedIn()
    if not isLoggedIn
      requestOptions.headers =
        "Accept-Language": "es"
        'wb-vcart':utils.getCartItemsToVirtualCart()
    requestOptions

  doCartDeleteLoading: ->
    message = 'Eliminando artículo...'
    utils.showLoadingMessage(message)

  doDeleteItemRequestError: (xhr, textStatus)->
    cartUtils.showCartErrorMessage(xhr, textStatus)
