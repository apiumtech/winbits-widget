'use strict'

View = require 'views/base/view'
ShippingOrderSubview = require 'views/shipping-order/shipping-order-history-table-subview'
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
    @model.fetch data:@params, success: $.proxy(@render, @)
    @delegate 'click', '#wbi-shipping-order-history-btn-back', @backToVertical
    @delegate 'click', '.wbc-icon-coupon', @requestCouponsService
    $('#wbi-my-account-div').slideUp()
    utils.replaceVerticalContent('.widgetWinbitsMain')
    @subscribeEvent 'shipping-order-history-params-changed', @paramsChanged

  attach: ->
    super
    @$('.select').customSelect()
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

  requestCouponsService:(e)->
    currentTarget = @$(e.currentTarget)
    dataOrderDetailNumber = currentTarget.closest('.wbc-order-detail').data('id')
    @dataOrderDetailName = currentTarget.closest('.wbc-order-detail').data('name')
    @dataShortDescription = currentTarget.closest('.wbc-order-detail').data('description')
    @model.requestCouponsService(dataOrderDetailNumber, context:@)
      .done(@doRecuestCouponsServiceSuccess)
      .fail( @doRecuestCouponsServiceError)

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
      onClosed: utils.redirectTo url: '/#wb-shipping-order-history'
    utils.showMessageModal(message, options)

  backToVertical:()->
    utils.restoreVerticalContent('.widgetWinbitsMain')
    utils.redirectToLoggedInHome()

  render: ()->
    super
    @subview 'shipping-order-history-table', new ShippingOrderSubview model:@model