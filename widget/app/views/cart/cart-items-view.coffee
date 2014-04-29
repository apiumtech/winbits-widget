View = require 'views/base/view'
$ = Winbits.$
utils = require 'lib/utils'

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
    if not utils.isLoggedIn()
      requestOptions.headers = {"Accept-Language": "es",'wb-vcart':utils.getVirtualCart()}

    console.log  ['item Id ', itemId, 'data', data]
#    generar fancy-loading
#    enviar la peticion
    @model.requestToUpdateCart(data, itemId , requestOptions)
      .done(@doUpdateItemRequestSuccess)
      .fail(@doUpdateItemRequestError)
#    reject
#    always

  doUpdateItemRequestSuccess: (data) ->
    console.log ['success', data]

  doUpdateItemRequestError: (xhr) ->
    console.log ['error', xhr]


