'use strict'

View = require 'views/base/view'
CartItemsView = require 'views/cart/cart-items-view'
CartTotalsView = require 'views/cart/cart-totals-view'
CartBitsView = require 'views/cart/cart-bits-view'
CartPaymentMethodsView = require 'views/cart/cart-payment-methods-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
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
    @subscribeEvent 'checkout-completed', @onCheckoutCompleted
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
    @$('#wbi-cart-info').dropMainMenu()#beforeOpen: $.proxy(@shouldOpenCart, @))

  onCartChanged: (cartData) ->
    if cartData
      @updateCartModel(cartData)
    @openCart()

  updateCartModel: (data) ->
    @model.setData(data)
    @render()

  onCheckoutCompleted: ->
    @model.clear()
    @model.set itemsCount:0, {silent:yes}
    @render()

  openCart: ->
    if @$('#wbi-cart-drop').is(':hidden')
      @$('#wbi-cart-info').trigger('click')

  closeCart: ->
    if @$('#wbi-cart-drop').is(':visible')
      @$('#wbi-cart-info').trigger('click')

  successVirtualFetch: (data)->
    @successFetch(utils.updateReferencesVirtualCart(data))

  successFetch: (data)->
    @updateCartModel data
    mediator.data.set 'bits-to-cart', @model.get 'bitsTotal'
    @publishEvent 'change-bits-data'

  restoreCart: ->
    virtualCart = JSON.parse(utils.getVirtualCart())
    if(utils.isLoggedIn())
      unless $.isEmptyObject virtualCart.cartItems
        $forms = @getFormsToTransferVirtualCart()
        @saveVirtualReferences($forms)

      else
        @model.fetch(success: $.proxy(@successFetch, @))
    else
      @model.fetch(success: $.proxy(@successVirtualFetch, @))

  successTransferVirtualCart: (data) ->
    @successFetch(data)
    utils.saveVirtualCartInStorage()
    if data.response.itemsCount is 0
      @showModalNoItemsToTransfer()
      mediator.data.set 'virtual-checkout', no
    else
      if(@model.validateTransferErrors(data.response))
        if(mediator.data.get 'virtual-checkout')
          @publishEvent 'checkout-requested'
          mediator.data.set 'virtual-checkout', no
      else
        mediator.data.set 'transfer-error', data.response
        utils.redirectTo(controller:'transfer-cart-errors', action:'index')
    @model.doTransferVirtualCampaigns(data.response.cartDetails)

  showModalNoItemsToTransfer: ->
    options =
      title: 'Items agotados'
      value: 'Regresar a la tienda'
#      context: @
      icon: 'iconFont-info'
      onClosed: -> utils.redirectToLoggedInHome()
    utils.showMessageModal('¡Lo sentimos! El producto se encuentra agotado o llegaste al límite de compra permitido para ese producto.Te invitamos a no perderte las ofertas que tenemos publicada para ti', options)

  shouldOpenCart: ->
    not @model.isCartEmpty()

  getFormsToTransferVirtualCart:()->
    virtualCart = JSON.parse(utils.getVirtualCart())
    referencesStorage = utils.getReferencesVirtualCart()
    cartItems = virtualCart.cartItems
    cartItemsReferences=[]
    cartItemsNotReferences=[]
    referencesKeys = _.keys(referencesStorage.references)
    for cartItem in cartItems
      if $.isEmptyObject referencesKeys
        cartItemsNotReferences.push cartItem
      else
        _.find(referencesKeys, (referenceKey)->
          if cartItem[referenceKey]
            cartItemsReferences.push {quantity: cartItem[referenceKey], references:referencesStorage.references[referenceKey], skuProfileId: parseInt(referenceKey)}
          else
            cartItemsNotReferences.push cartItem
        )
    virtualCart.cartItems = cartItemsNotReferences
    {virtualCart:virtualCart, cartReferences:cartItemsReferences}

  saveVirtualReferences:($formData)->
    formData = $formData.virtualCart
    unless $.isEmptyObject formData.cartItems
      @model.transferVirtualCart(formData, context:@).done((data)->
        unless $.isEmptyObject $formData.cartReferences
          @model.requestToTransferVirtualCartReference($formData.cartReferences[0], context:@).done((dataReference)->
              $.extend dataReference.response.cartDetails, data.response.cartDetails
              dataReference.response.failedCartDetails= data.response.failedCartDetails
              @successTransferVirtualCart(dataReference)
          ).fail(()->
            @successTransferVirtualCart(data)
          )
        else
          @successTransferVirtualCart(data))
    else unless $.isEmptyObject $formData.cartReferences
      @model.requestToTransferVirtualCartReference($formData.cartReferences[0], context:@).done(@successTransferVirtualCart).fail(()=> @model.fetch(success: $.proxy(@successFetch, @)))
