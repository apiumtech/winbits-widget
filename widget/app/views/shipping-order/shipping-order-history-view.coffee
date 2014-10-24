'use strict'

View = require 'views/base/view'
ShippingOrderSubview = require 'views/shipping-order/shipping-order-history-table-subview'
HistoryHeaderView = require 'views/account-history/history-header-view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class ShippingOrderHistoryView extends View
  container: env.get('vertical-container')
  className: 'widgetWinbitsMain wbc-vertical-content'
  template: require './templates/shipping-order-history'
  params:
    max:10

  initialize:()->
    super
    $loginData = mediator.data.get 'login-data'
    @model.fetch data:@params, success: $.proxy(@render, @)
    @model.set 'clickoneroId', mediator.data.get('login-data').profile.clickoneroId
    @model.set 'bitsTotal', $loginData.bitsBalance
    @model.set 'pendingOrderCount', $loginData.profile.pendingOrdersCount
    @delegate 'click', '#wbi-shipping-order-history-btn-back', @backToVertical
    @delegate 'click', '.wbc-icon-coupon', @requestCouponsService
    @delegate 'click', '#wbi-old-orders-history', @requestClickoneroService
    $('#wbi-my-account-div').slideUp()
    utils.replaceVerticalContent('.widgetWinbitsMain')
    @subscribeEvent 'shipping-order-history-params-changed', @paramsChanged

  attach: ->
    super
    @$('#wbi-account-order-history-link').hide()
    @$('.select').customSelect()
    @$('span.iconFont-question').toolTip()
    @$('#wbi-shipping-order-history-paginator')
     .wbpaginator(total: @model.getTotal(), max: @params.max, change: $.proxy(@pageChanged, @))

  paramsChanged: (params)->
    $.extend @params, params
    @updateHistory()

  pageChanged: (e, ui) ->
    params = max: ui.max, offset: ui.offset
    @paramsChanged params

  updateHistory: ->
    @model.fetch {data:@params}

  requestClickoneroService:(e)->
    e.preventDefault()
    utils.showLoaderToCheckout()
    $('#wbi-loader-text').text('Cargando ordenes...')
    @model.requestClickoneroOrders($(e.currentTarget).data('clickoneroid'))
      .done(@requestClickoneroServiceSuccess)
      .fail(@requestClickoneroServiceError)
      .always(@doHideLoaderAndRevertText)

  requestClickoneroServiceSuccess:(data)->
    mediator.data.set 'old-orders', data.orders
    utils.redirectTo controller: 'old-orders-history', action:'index'

  requestClickoneroServiceError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error al conseguir tus ordenes,#{textStatus}"
    message = if error then error.meta.message + ',por favor intentalo mas tarde.' else messageText
    options =
      icon: 'iconFont-info'
      value: "Cerrar"
      title:'Lo sentimos!'
      onClosed: utils.redirectTo controller: 'shipping-order-history',action:'index'
    utils.showMessageModal(message, options)


  requestCouponsService:(e)->
    e.preventDefault()
    e.stopPropagation()
    utils.showLoaderToCheckout()
    $('#wbi-loader-text').text('Procesando cupones')
    currentTarget = @$(e.currentTarget).closest('.wbc-order-detail')
    dataOrderDetailNumber = currentTarget.data('id')
    @dataOrderDetailName = currentTarget.data('name')
    @dataShortDescription = currentTarget.data('description')
    @model.requestCouponsService(dataOrderDetailNumber, context:@)
      .done(@doRecuestCouponsServiceSuccess)
      .fail( @doRecuestCouponsServiceError)
      .always(@doHideLoaderAndRevertText)

  doHideLoaderAndRevertText: ->
    $('#wbi-loader-text').text('Iniciando Checkout')
    utils.hideLoaderToCheckout()

  doRecuestCouponsServiceSuccess:(data) ->
    toModelCoupon =
      coupons: data.response
      title: @dataOrderDetailName
      description: @dataShortDescription
    mediator.data.set('coupon-data', toModelCoupon)
    utils.redirectTo controller:'coupon', action:'index'

  doRecuestCouponsServiceError: (xhr, textStatus)->
    error = utils.safeParse(xhr.responseText)
    messageText = "Error al conseguir tus cupones,#{textStatus}"
    message = if error then error.meta.message + ', por favor intentalo mas tarde.' else messageText
    options =
      icon: 'iconFont-info'
      value: "Cerrar"
      title:'Lo sentimos!'
      onClosed: utils.redirectTo controller: 'shipping-order-history',action:'index'
    utils.showMessageModal(message, options)

  backToVertical:()->
    utils.restoreVerticalContent('.widgetWinbitsMain')
    utils.redirectToLoggedInHome()

  render: ()->
    super
    @subview 'shipping-order-history-table', new ShippingOrderSubview model:@model
    @subview('history-header-view', new HistoryHeaderView model: @model)
