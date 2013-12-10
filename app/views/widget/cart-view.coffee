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
    console.log ['Add to cart object', cartItem]
    util.showError("Please specify a cart item object: {id: 1, quantity: 1}")  unless cartItem
    util.showError("Id required! Please specify a cart item object: {id: 1, quantity: 1}")  unless cartItem.id
    cartItem.id = parseInt(cartItem.id)
    if not cartItem.quantity or cartItem.quantity < 1
      console.log "Setting default quantity (1)..."
      cartItem.quantity = 1
    cartItem.quantity = parseInt(cartItem.quantity)
    cartDetail = @model.findCartDetail(cartItem.id)
    $cartPanel = @$el.closest('.miCarritoDiv')
    if not cartDetail
      if mediator.flags.loggedIn
        @model.addToUserCart cartItem, $cartPanel
      else
        @model.addToVirtualCart cartItem, $cartPanel
    else
      cartItem.quantity = cartItem.quantity + cartDetail.quantity
      @updateCartDetail cartItem, $cartPanel


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
    vendor.customSelect(@$el.find(".wb-cart-detail-quantity")).on "change", (e, previous) ->
      $cartDetailStepper = Backbone.$(@)
      val = parseInt($cartDetailStepper.val())
      id = $cartDetailStepper.closest("li").data("id")
      that.updateCartDetail id: id, quantity: val

    that = @
    vendor.customSlider("#wb-cart-bits-slider-account").on('slidechange', (e, ui) ->
      # TODO: Create view CartInfo and maintain slider out of that view
      $slider = Backbone.$(@)
      maxBits = $slider.slider('option', 'max')
      if maxBits > 0
        util.updateCartInfoView(that.model, ui.value, $slider)
        that.updateCartBits ui.value
    ).on('slide', (e, ui) ->
      util.updateCartInfoView(that.model, ui.value, Backbone.$(@))
    )

    @$el.find('.wb-cart-detail-delete-link').click (  e) ->
      that.clickDeleteCartDetailLink(e, that.model)

    vendor.scrollpane ".scrollPanel", ".miCarritoDiv"
    vendor.dropMenu
      obj: ".miCarritoDiv"
      clase: ".dropMenu"
      trigger: ".shopCarMin"
      other: ".miCuentaDiv"
      carro: true

    @$el.find('.wb-continue-shopping-link').click @closeCart
    @$el.find('.wb-checkout-btn').click (e)->
      that.closeCart(e)
      if mediator.flags.loggedIn
        that.publishEvent 'doCheckout'
      else
        mediator.flags.autoCheckout = true
        that.publishEvent 'showLogin'

  updateCartDetail : (cartItem, $cartPanel) ->
    console.log ["updateCartDetail"]
    if mediator.flags.loggedIn
      @model.updateUserCartDetail cartItem, $cartPanel
    else
      @model.updateVirtualCartDetail cartItem, $cartPanel

  updateCartBits: (bits) ->
    if mediator.flags.loggedIn
      @model.updateCartBits(bits)
    else
      @model.set 'bitsTotal', bits

  closeCart: (e) ->
    e.preventDefault()
    w$(e.currentTarget).closest('.dropMenu').slideUp()
