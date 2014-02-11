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

  delay = false

  render: ->
    super

  initialize: () ->
    super
    @subscribeEvent 'restoreCart', @restoreCart
    @subscribeEvent 'renderCart', @render
    @subscribeEvent 'loggedOut', @resetModel

  resetModel: ->
    @model.clear()


  restoreCart: ()->
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
        cartItem.quantity = 1
      cartItem.quantity = parseInt(cartItem.quantity)

    if ok
      $cartPanel = @$el.closest('.miCarritoDiv')
      if cartItems.length is 1
        existingCartItem = @model.findCartDetail(cartItems[0].id)
        if existingCartItem
          cartItem = cartItems[0]
          cartItem.quantity += existingCartItem.quantity
          @updateCartDetail(cartItem,$cartPanel)
          return ok

      if mediator.flags.loggedIn
        @model.addToUserCart cartItems, $cartPanel, options
      else
        @model.addToVirtualCart cartItems, $cartPanel, options
    ok

  clickDeleteCartDetailLink: (e, model) ->
    e.preventDefault()
    $cartDetail = Winbits.$(e.target).closest("li")
    id = $cartDetail.attr("data-id")
    if mediator.flags.loggedIn
      model.deleteUserCartDetail id
    else
      model.deleteVirtualCartDetail id

  attach: ()->
    super
    that = @
    @publishEvent "updateCartCounter", @model.get("itemsCount")
    vendor.customSelect(@$el.find(".wb-cart-detail-quantity")).on "change", (e, previous) ->
      $cartDetailStepper = Winbits.$(@)
      val = parseInt($cartDetailStepper.val())
      id = $cartDetailStepper.closest("li").data("id")
      that.updateCartDetail id: id, quantity: val

    that = @

    debounceSlide = _.debounce( ($slider, $amountEm, bits) ->
      that.delay = false
      emValue = parseInt($amountEm.text())
      if emValue is bits
        that.updateBalanceValues(that, $slider, bits)
    , 1500)

    vendor.customSlider(".wb-cart-bits-slider-account").on('slidechange', (e, ui) ->
      $slider = Winbits.$(@)
      $amountEm = Winbits.$(this).find(".amount em")
      that.delay = true
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
          that.publishEvent 'doCheckout', that.delay
          
      else
        mediator.flags.autoCheckout = true
        that.publishEvent 'showLogin'

    container = Winbits.$.find('#wbi-cart-balance')
    balanceView = new CartBalanceView {@model, container}
    @listenToOnce balanceView, 'dispose', @render
    @subview 'balanceCartSubview', balanceView

  updateCartDetail : (cartItem, $cartPanel) ->
    if mediator.flags.loggedIn
      @model.updateUserCartDetail cartItem, $cartPanel
    else
      @model.updateVirtualCartDetail cartItem, $cartPanel

  updateCartBits: (bits, amount) ->
    if mediator.flags.loggedIn
      @model.updateCartBits(bits)
    else
      @updatePaymentMethods amount
      @model.set 'bitsTotal', bits

  updatePaymentMethods: (amount) ->
    that = @
    vCart = util.retrieveKey(config.vcartTokenName)
    util.ajaxRequest config.apiUrl + "/orders/virtual-cart-items/paymentMethods.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify({"virtualCartData": vCart, "amount": amount})
      headers:
        "Accept-Language": "es"

      success: (data) ->
        that.model.set {paymentMethods: data.response.paymentMethods}

      error: (xhr) ->
        util.showAjaxError(xhr.responseText)

  closeCart: (e) ->
    e.preventDefault()
    Winbits.$(e.currentTarget).closest('.dropMenu').slideUp()

  updateBalanceValues: (that, $slider, bits)->
    maxBits = $slider.slider('option', 'max')
    if maxBits > 0
      cartTotal = util.updateCartInfoView(that.model, bits, $slider)
      that.updateCartBits bits, cartTotal
