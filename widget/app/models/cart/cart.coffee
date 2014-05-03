require = Winbits.require
Model = require 'models/base/model'
utils = require 'lib/utils'
cartUtils = require 'lib/cart-utils'
mediator = Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class Cart extends Model
  url: cartUtils.getCartResourceUrl
  needsAuth: yes
  accessors: ['cartTotal', 'cartPercentageSaved', 'cartSaving']
  defaults:
    itemsTotal: 0,
    bitsTotal: 0,
    shippingTotal: 0,
    cashback: 0

  initialize: () ->
    super

  sync: (method, model, options = {}) ->
    options.headers = 'Wb-VCart': utils.getVirtualCart() if not utils.isLoggedIn()
    super(method, model, options)

  cartTotal: ->
    @get('itemsTotal') - @get('shippingTotal') - @get('bitsTotal')

  cartPercentageSaved: ->
    cartTotal = @cartTotal()
    itemsTotal = @get('itemsTotal')
    if itemsTotal then (1 - (cartTotal / itemsTotal)) * 100 else 0

  cartSaving: ->
    # TODO: Implementar algoritmo corecto cuando se defina
    @get 'bitsTotal'

  requestCheckout: (options)->
    if @hasCartItems()
      defaults =
        type: 'POST'
        context: @
        headers:
          'Wb-Api-Token': utils.getApiToken()
        data: JSON.stringify(verticalId: utils.getCurrentVerticalId())
      ajaxOptions = utils.setupAjaxOptions(options, defaults)
      url = utils.getResourceURL('orders/checkout.json')
      utils.ajaxRequest(url, ajaxOptions)
        .done(@requestCheckoutSucceeds)
        .fail(@requestCheckoutFails)
    else
      utils.showMessageModal('Para comprar, debe agregar artículos al carrito.')
      return

  hasCartItems: ->
    itemsCount = @get('itemsCount')
    itemsCount? and itemsCount > 0

  requestCheckoutSucceeds: (data) ->
    id = data.response.id
    checkoutURL = env.get('checkout-url')
    redirectURL = "#{checkoutURL}?orderId=#{id}"
    window.location.assign(redirectURL)

  requestCheckoutFails: (xhr) ->
    data = JSON.parse(xhr.responseText)
    utils.showMessageModal(data.meta.message)
