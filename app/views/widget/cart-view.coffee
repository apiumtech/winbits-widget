template = require 'views/templates/widget/cart'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class CartView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#cart-container'
  template: template
  id: "cart-view"

  render: ->
    super

  initialize: () ->
    super
    @subscribeEvent 'restoreCart', @restoreCart
    @subscribeEvent 'addToCart', @addToCart

  restoreCart: ()->
    console.log ["CartView#restoreCart"]
    vCart = util.getCookie(config.vcartTokenName)
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
    cartDetail = @model.findCartDetail(cartItem.id)
    if not cartDetail
      if mediator.flags.loggedIn
        @model.addToUserCart cartItem.id, cartItem.quantity, cartItem.bits
      else
        @model.addToVirtualCart cartItem.id, cartItem.quantity
    else
      qty = cartItem.quantity + cartDetail.quantity
      @updateCartDetail cartItem.id, qty, cartItem.bits
    @$el.closest('.miCarritoDiv').slideDown()


  clickDeleteCartDetailLink: (e, model) ->
    e.preventDefault()
    console.log ["deleting Item from cart"]
    $cartDetail = w$(e.target).closest("li")
    console.log $cartDetail
    id = $cartDetail.attr("data-id")
    if mediator.flags.loggedIn
      model.deleteUserCartDetail id
    else
      model.deleteVirtualCartDetail id


  attach: ()->
    super
    console.log "CartView#attach"
    that = @
    @publishEvent "updateCartCounter", @model.get("itemsCount")
    vendor.customStepper(@$el.find(".cart-detail-quantity")).on "step", (e, previous) ->
      $cartDetailStepper = that.$(this)
      val = parseInt($cartDetailStepper.val())
      unless previous is val
        console.log ["previous", "current", previous, val]
        id = $cartDetailStepper.closest("li").attr("data-id")
        that.updateCartDetail id, val

    vendor.customSlider(".slideInput").on 'slidechange', (e, ui) ->
#      TODO: Create view CartInfo and maintain slider out of that view
      maxBits = w$(ui.handle).closest('.slider-holder').slider('option', 'max')
      if maxBits > 0
        that.updateCartBits ui.value

    that = @
    @$el.find('.wb-cart-detail-delete-link').click (e) ->
      that.clickDeleteCartDetailLink(e, that.model)

    vendor.scrollpane ".scrollPanel", ".miCarritoDiv"
    vendor.dropMenu
      obj: ".miCarritoDiv"
      clase: ".dropMenu"
      trigger: ".shopCarMin"
      other: ".miCuentaDiv"
      carro: true

    @$el.find('.wb-continue-shopping-link').click @closeCart

  updateCartDetail : (id, quantity, bits) ->
    console.log ["updateCartDetail"]
    if mediator.flags.loggedIn
      @model.updateUserCartDetail id, quantity, bits
    else
      @model.updateVirtualCartDetail id, quantity

  updateCartBits: (bits) ->
    if mediator.flags.loggedIn
      @model.updateCartBits(bits)
    else
      @model.set 'bitsTotal', bits

  closeCart: (e) ->
    e.preventDefault()
    w$(e.currentTarget).closest('.dropMenu').slideUp()