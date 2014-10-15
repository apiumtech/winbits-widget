'use strict'
ShippingOrderHistoryView = require 'views/shipping-order/shipping-order-history-view'
ShippingOrderHistory = require 'models/shipping-order/shipping-order-history'
utils = require 'lib/utils'

describe 'ShippingOrderHistoryViewSpec', ->

  SHIPPING_ORDERS_HISTORY_URL = utils.getResourceURL("users/orders.json?max=10")
  SHIPPING_ORDERS_HISTORY_RESPONSE = '{"meta": {"totalCount": 8,"status": 200},"response": [{"orderNumber": "1407171325--15","dateOfPurchase": "2014-07-17T13:25:18-05:00","total": 329,"status": "PAID","estimatedDeliveryDate": null,"details": [{"orderDetailId": 18,"name": "ItemGroupProfile","brand": "Brand","amount": 250,"quantity": 1,"status": [{"status": "Almacen","quantity": 1,"sort": 0}],"tracingNumbers": [],"vertical": {"id": 1,"active": true,"baseUrl": "http://www.winbits-test.com","logo": null,"maxPerVertical": 10000,"name": "_Test_","order": 0 },"attributeLabel": "attributeLabel","attributeName": "attributeName","attributeValue": "attributeValue","attributeType": "TEXT","attributes": [],"thumbnail": null,"estimatedDeliveryDate": null,"itemGroupType": "PRODUCT","withCoupon": true,"shortDescription": "shortDescription"}],"ticketPayments": []}]}'

  before ->
    Winbits.Chaplin.mediator.data.set('login-data', {profile:{clickoneroId:123456}})

  after ->
    Winbits.Chaplin.mediator.data.set('login-data', undefined )

  beforeEach ->
    @data = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @data.onCreate = (data) -> requests.push(data)

    @model = new ShippingOrderHistory
    @view = new ShippingOrderHistoryView model: @model

  afterEach ->
    @data.restore()
    @view.dispose()
    @model.dispose()

  it 'shipping order history view renderized with no order history', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, "")
    expect(@view.$('.historical .addInfo')).to.exist
    expect(@view.$('.historical .addInfo').text()).to.equal 'No tienes compras.'

  it "should request get shipping order history", ->
    request = @requests[0]
    expect(request.method).to.be.equal('GET')
    expect(request.url).to.be.equal(SHIPPING_ORDERS_HISTORY_URL)


  it 'shipping order history view renderized with orders', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ORDERS_HISTORY_RESPONSE)
    @view.render()
    expect(@view.$('.historical')).to.exist
    expect(@view.$('.historical .addInfo')).to.not.exist
    expect(@view.$('.dataTable')).to.exist