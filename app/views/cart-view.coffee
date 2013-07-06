template = require 'views/templates/cart'
View = require 'views/base/view'

module.exports = class LoginView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#cart-container'
  template: template

  render: ->
    console.log "(>_<)"
    super
  initialize: () ->
    super
    Window.Winbits.addToCart = @addToCart
    @subscribeEvent 'restoreCart', @restoreCart


  restoreCart: ()->
    vCart = util.getCookie(conf.vcartTokenName)
    unless vCart is "[]"
      @model.transferVirtualCart vCart
    else
      @model.loadUserCart

  addToCart : (cartItem)->
    console.log ["Vertical request to add item to cart", cartItem]
    alert "Please specify a cart item object: {id: 1, quantity: 1}"  unless cartItem
    alert "Id required! Please specify a cart item object: {id: 1, quantity: 1}"  unless cartItem.id
    cartItem.id = parseInt(cartItem.id)
    if not cartItem.quantity or cartItem.quantity < 1
      console.log "Setting default quantity (1)..."
      cartItem.quantity = 1
    cartItem.quantity = parseInt(cartItem.quantity)
    $cartDetail = @$el.find(".cart-holder:visible .cart-details-list").children("[data-id=" + cartItem.id + "]")
    id = $cartDetail.attr("data-id")
    if $cartDetail.length is 0
      if mediator.flags.loggedIn
        @model.addToUserCart cartItem.id, cartItem.quantity, cartItem.bits
      else
        @model.addToVirtualCart cartItem.id, cartItem.quantity
    else
      qty = cartItem.quantity + parseInt($cartDetail.find(".cart-detail-quantity").val())
      @model.updateCartDetail id, qty, cartItem.bits
