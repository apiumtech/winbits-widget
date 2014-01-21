CartBalanceView = require 'views/widget/cartdetail/cart-balance-view'
template = require 'views/templates/widget/cart'
View = require 'views/base/view'
util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class CartView extends View
  autoRender: yes
  container: '#wbi-cart-container'
  template: template

  render: ->
    super

  initialize: () ->
    super
    @subscribeEvent 'restoreCart', @restoreCart
    @subscribeEvent 'renderCart', @render


  restoreCart: ()->
    console.log ["CartView#restoreCart"]
    vCart = util.retrieveKey(config.vcartTokenName)
    unless vCart is "[]"
      @model.transferVirtualCart vCart
    else
      @model.loadUserCart()

  addToCart : (cartItem, options)->
    console.log ['Add to cart object', cartItem]
    options = success: cartItem.success, error: cartItem.error, complete: cartItem.complete unless options
    cartItems = if Winbits.$.isArray(cartItem) then cartItem else [cartItem]
    ok = yes
    Winbits.$.each cartItems, (index, cartItem) ->
      if not cartItem
        util.showError("Please specify a cart item object: {id: 1, quantity: 1}")
        ok = no

      if not cartItem.id
        util.showError("Id required! Please specify a cart item object: {id: 1, quantity: 1}")  unless cartItem.id
        ok = no

      cartItem.id = parseInt(cartItem.id)
      if not cartItem.quantity or cartItem.quantity < 1
        console.log "Setting default quantity (1)..."
        cartItem.quantity = 1
      cartItem.quantity = parseInt(cartItem.quantity)

    if ok
      $cartPanel = @$el.closest('.miCarritoDiv')
      if mediator.flags.loggedIn
        @model.addToUserCart cartItems, $cartPanel, options
      else
        @model.addToVirtualCart cartItems, $cartPanel, options
    ok

  clickDeleteCartDetailLink: (e, model) ->
    e.preventDefault()
    console.log ["deleting Item from cart"]
    $cartDetail = Winbits.$(e.target).closest("li")
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
      $cartDetailStepper = Winbits.$(@)
      val = parseInt($cartDetailStepper.val())
      id = $cartDetailStepper.closest("li").data("id")
      that.updateCartDetail id: id, quantity: val

    that = @

    debounceSlide = _.debounce( ($slider, $amountEm, bits) ->
      emValue = parseInt($amountEm.text())
      if emValue is bits
        that.updateBalanceValues(that, $slider, bits)
    , 1500)

    vendor.customSlider(".wb-cart-bits-slider-account").on('slidechange', (e, ui) ->
      $slider = Winbits.$(@)
      $amountEm = Winbits.$(this).find(".amount em")
      debounceSlide $slider, $amountEm, ui.value
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

    container = Winbits.$.find('#wbi-cart-balance')
    balanceView = new CartBalanceView {@model, container}
    @listenToOnce balanceView, 'dispose', @render
    @subview 'balanceCartSubview', balanceView

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
    Winbits.$(e.currentTarget).closest('.dropMenu').slideUp()

  updateBalanceValues: (that, $slider, bits)->
    maxBits = $slider.slider('option', 'max')
    if maxBits > 0
      util.updateCartInfoView(that.model, bits, $slider)
      that.updateCartBits bits
