'use strict'
utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class ShippingOrderHistory extends Model
  url: env.get('api-url') + "/users/orders.json"
  needsAuth: true

  parse: (data) ->
    orders = @getHistoryData(super)
    orders: orders

  getHistoryData:(orders)->
    ordersToView = []
    for order in orders
      refundDetails = []
      orderDetails = []
      for od in order.details
        if(od.refundedDetail)
          refundDetails.push od
        else
          orderDetails.push od
      order.details = @refundOrders(orderDetails, refundDetails)
      ordersToView.push order
    ordersToView

  refundOrders:(orderDetails, refundDetails)->
    allDetailsToView = []
    if(refundDetails)
      refundMap ={}
      for refundDetail in refundDetails
        refundList = []
        if refundMap[refundDetail.refundedDetail.orderDetailId]
          rf = refundMap[refundDetail.refundedDetail.orderDetailId]
          refundList = rf.refundDetails
          refundList.push refundDetail
          refundMap[refundDetail.refundedDetail.orderDetailId] = {quantity : rf.quantity+refundDetail.quantity, refundDetails: refundList}
        else
          refundList.push refundDetail
          refundMap[refundDetail.refundedDetail.orderDetailId] = {quantity: refundDetail.quantity, refundDetails:refundList}
      for orderDetail in orderDetails
        if refundMap[orderDetail.orderDetailId]
          quantity = if refundMap[orderDetail.orderDetailId].quantity then refundMap[orderDetail.orderDetailId].quantity else 0
          if(quantity < orderDetail.quantity)
            orderDetail.quantity -= quantity
            allDetailsToView.push orderDetail
          refDet = refundMap[orderDetail.orderDetailId].refundDetails[0]
          refDet.quantity = quantity
          allDetailsToView.push refDet

        else
          allDetailsToView.push orderDetail


    else
      for orderDetail in orderDetails
        allDetailsToView.push orderDetails
    allDetailsToView




  getTotal: ->
    if (@meta)
      @meta.totalCount
    else
      0

  requestCouponsService:(orderDetailId, options)->
    defaults =
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(
      env.get('api-url') + "/users/coupons/#{orderDetailId}.json",
      $.extend(defaults, options)
    )

  requestClickoneroOrders:(clickoneroId)->
    console.log ["clickonero id ", clickoneroId]
    utils.ajaxRequest(env.get('clickonero-url')+'accountApi.js?id='+clickoneroId)