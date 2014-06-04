'use strict'
View = require 'views/base/view'
CartItemsView = require 'views/cart/cart-items-view'
CartTotalsView = require 'views/cart/cart-totals-view'
CartBitsView = require 'views/cart/cart-bits-view'
CartPaymentMethodsView = require 'views/cart/cart-payment-methods-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

module.exports = class CartView extends View
  container: '#wbi-cart-holder'
  template: require './templates/cart'
  noWrap: yes
  model: new Cart

  initialize: ->
    super
    @subscribeEvent 'cart-changed', -> @onCartChanged.apply(@, arguments)
    @restoreCart()

  render: ->
    super
    cartLeftPanel = @$el.find('#wbi-cart-left-panel').get(0)
    cartItemsView = new CartItemsView container: cartLeftPanel, model: @model
    @subview 'cart-items', cartItemsView
    cartRightPanel = @$el.find('#wbi-cart-right-panel').get(0)
    rightPanelOptions = container: cartRightPanel, model: @model
    @subview 'cart-totals', new CartTotalsView rightPanelOptions
    @subview 'cart-bits', new CartBitsView rightPanelOptions
    cartPaymentMethodsView = new CartPaymentMethodsView rightPanelOptions
    @subview 'cart-payment-methods', cartPaymentMethodsView

  attach: ->
    super
    @$('#wbi-cart-info').dropMainMenu(beforeOpen: $.proxy(@shouldOpenCart, @))

  onCartChanged: (cartData) ->
    @updateCartModel(cartData)
    @openCart()

  updateCartModel: (data) ->
    @model.setData(data)
    @render()

  openCart: ->
    if @$('#wbi-cart-drop').is(':hidden')
      @$('#wbi-cart-info').trigger('click')

  successFetch: (data)->
    @updateCartModel data
    mediator.data.set 'bits-to-cart', @model.get 'bitsTotal'
    @publishEvent 'change-bits-data'

  restoreCart: ->
    virtualCart = utils.getVirtualCart()
    if(utils.isLoggedIn())
      unless virtualCart is "[]"
        formData = virtualCartData : JSON.parse(virtualCart)
        @model.transferVirtualCart(formData, context:@)
        .done(@successTransferVirtualCart)
      else
        @model.fetch(success: $.proxy(@successFetch, @))
    else
      @model.fetch(success: $.proxy(@successFetch, @))

  successTransferVirtualCart: (data) ->
    utils.saveVirtualCartInStorage()
    @successFetch(data)
    if(mediator.data.get 'virtual-checkout')
      @publishEvent 'checkout-requested'
    mediator.data.set 'virtual-checkout', no

  shouldOpenCart: ->
    not @model.isCartEmpty()
