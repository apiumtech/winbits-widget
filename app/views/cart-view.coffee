template = require 'views/templates/cart'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'

module.exports = class CartView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#cart-container'
  template: template
  id: "cart-view"

  render: ->
    console.log "(>_<>_>)"
    super
  initialize: () ->
    super
    console.log "CartView#initialize"
    @subscribeEvent 'restoreCart', @restoreCart
    @delegate 'click', '.cart-detail-delete-link', @clickDeleteCartDetailLink
    @subscribeEvent 'addToCart', @addToCart


  restoreCart: ()->
    console.log ["CartView#restoreCart"]
    vCart = util.getCookie(config.vcartTokenName)
    console.log vCart
    unless vCart is "[]"
      @model.transferVirtualCart vCart
    else
      @model.loadUserCart()

  addToCart : (cartItem)->
    console.log ["Vertical request to add item to cart", cartItem]
    alert "Please specify a cart item object: {id: 1, quantity: 1}"  unless cartItem
    alert "Id required! Please specify a cart item object: {id: 1, quantity: 1}"  unless cartItem.id
    cartItem.id = parseInt(cartItem.id)
    if not cartItem.quantity or cartItem.quantity < 1
      console.log "Setting default quantity (1)..."
      cartItem.quantity = 1
    cartItem.quantity = parseInt(cartItem.quantity)
    console.log @
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


  clickDeleteCartDetailLink: (e) ->
    e.stopPropagation()
    console.log ["deleting Item from cart"]
    $cartDetail = $(e.target).closest("li")
    console.log $cartDetail
    id = $cartDetail.attr("data-id")
    if mediator.flags.loggedIn
      @model.deleteUserCartDetail id
    else
      @model.deleteVirtualCartDetail id


  attach: ()->
    super
    console.log "CartView#attach"
    that = @
    util.customStepper(@$el.find(".cart-detail-quantity")).on "step", (e, previous) ->
      $cartDetailStepper = $(this)
      val = parseInt($cartDetailStepper.val())
      unless previous is val
        console.log ["previous", "current", previous, val]
        id = $cartDetailStepper.closest("li").attr("data-id")
        that.updateCartDetail id, val
    #console.log @$el
    #console.log @$el.find(".cart-detail-delete-link")

  updateCartDetail : (id, quantity, bits) ->
    console.log ["updateCartDetail"]
    if mediator.flags.loggedIn
      @model.updateUserCartDetail id, quantity, bits
    else
      @model.updateVirtualCartDetail id, quantity

