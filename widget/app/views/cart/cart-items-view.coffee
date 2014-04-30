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
    cartUtils.doCartLoading()
    @model.requestToUpdateCart(data, itemId , requestOptions)
    .done(@doUpdateItemRequestSuccess)
    .fail(@doUpdateItemRequestError)

  doUpdateItemRequestSuccess: (data) ->
    $.fancybox.close()
    if not utils.isLoggedIn()
      cartUtils.addToVirtualCartSuccess(data)
    else
      cartUtils.publishCartChangedEvent(data)
    $('#wbi-cart-info').click()

  doUpdateItemRequestError: (xhr, textStatus)->
    @render()
    cartUtils.showCartErrorMessage(xhr, textStatus)