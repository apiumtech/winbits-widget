'use strict'
ShippingOrderHistoryView = require 'views/shipping-order/shipping-order-history-view'
ShippingOrderHistory = require 'models/shipping-order/shipping-order-history'
utils = require 'lib/utils'

describe 'ShippingOrderHistoryViewSpec', ->

  SHIPPING_ORDERS_HISTORY_URL = utils.getResourceURL("users/orders.json?max=10")
  SHIPPING_ORDERS_HISTORY_RESPONSE = '{"meta":{"status":200},"response":[{"orderNumber":"1405151329--47","dateOfPurchase":"2014-11-15T13:30:59-06:00","total":10,"status":"PAID","estimatedDeliveryDate":null,"details":[{"name":"nameTo24","brand":"Brand","amount":10,"quantity":1,"status":[{"status":"IN_WAREHOUSE","quantity":1,"sort":0}],"tracingNumber":["---------"],"vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100,"name":"Looq","order":0},"attributeLabel":"atributoLabel","attributeName":"atributoName2","attributeValue":"AtributoLAbel","attributeType":"TEXT","attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"thumbnail":{"url":"http://d17puf58klsok4.cloudfront.net/Thumbnail/Thumbnail_2014392314_LEGO.jpg","type":"THUMB"},"estimatedDeliveryDate":null}],"ticketPayments":[]}]}'

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
    expect(@view.$('.historical .addInfo span').text()).to.equal ' No tienes compras.'

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