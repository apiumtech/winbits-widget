'use strict'

View = require 'views/base/view'
CartItemsView = require 'views/cart/cart-items-view'
CartTotalsView = require 'views/cart/cart-totals-view'
CartBitsView = require 'views/cart/cart-bits-view'
CartPaymentMethodsView = require 'views/cart/cart-payment-methods-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
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
    @successFetch(data)
    utils.saveVirtualCartInStorage()
    if data.response.itemsCount is 0
      @showModalNoItemsToTransfer()
      mediator.data.set 'virtual-checkout', no
    else
      if(@validateTransferErrors(data.response))
        if(mediator.data.get 'virtual-checkout')
          @publishEvent 'checkout-requested'
          mediator.data.set 'virtual-checkout', no
      else
        utils.redirectTo(controller:'transfer-cart-errors', action:'index', params:data.response)


  validateTransferErrors: (response)->
    console.log[response]
    warnings = response.cartDetails.map (cartDetail) -> cartDetail.warnings
    warnings = _.flatten(warnings)
    isValid =  if (response.failedCartDetails or !$.isEmptyObject(warnings) ) then no else yes
    isValid

  showModalNoItemsToTransfer: ->
    options =
      title: 'Items agotados'
      value: 'Regresar a la tienda'
#      context: @
      icon: 'iconFont-info'
      onClosed: -> utils.redirectToLoggedInHome()
    utils.showMessageModal('Los Items seleccionados se encuentran agotados. Te invitamos a no perderte de nuestras ofertas que tenemos publicadas para ti', options)

  shouldOpenCart: ->
    not @model.isCartEmpty()
