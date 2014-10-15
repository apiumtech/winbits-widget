'use strict'
YourBitsHistoryView = require 'views/bits-history/bits-history-view'
YourBitsHistory = require 'models/bits-history/bits-history'
utils = require 'lib/utils'

describe 'BitsHistoryViewSpec', ->

  YOUR_BITS_URL = utils.getResourceURL("users/bits/transactions.json?max=20")
  YOUR_BITS_RESPONSE = '{"meta":{"status":200,"totalTransactions":5},"response":{"transactions":[{"amount":-300,"balance":200,"concept":"pago 2","dateCreated":"2014-05-16T13:39:06-05:00"},{"amount":-100,"balance":500,"concept":"pago 1","dateCreated":"2014-05-16T13:38:47-05:00"},{"amount":200,"balance":600,"concept":"test","expirationDate":{"class":"wslite.json.JSONObject$Null"},"dateCreated":"2014-05-16T13:37:35-05:00","activationDate":"2014-05-16T13:37:35-05:00"},{"amount":200,"balance":400,"concept":"test","expirationDate":{"class":"wslite.json.JSONObject$Null"},"dateCreated":"2014-05-16T13:37:28-05:00","activationDate":"2014-05-16T13:37:28-05:00"},{"amount":100,"balance":200,"concept":"Registro Completo","expirationDate":"2014-05-24T00:00:00-05:00","dateCreated":"2014-05-14T17:36:50-05:00","activationDate":"2014-05-14T00:00:00-05:00"}],"balance":200}}'

  beforeEach ->
    @data= sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @data.onCreate = (data) -> requests.push(data)

    @model = new YourBitsHistory
    @view = new YourBitsHistoryView model: @model

  afterEach ->
    @data.restore()
    @view.dispose()
    @model.dispose()

  it 'your bits history view renderized with no order history', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, "")
    expect(@view.$('.historical')).to.exist
    expect(@view.$('.addInfo').text()).to.equal 'No tienes movimientos de bits.'

  it "should request get bits history", ->
    request = @requests[0]
    expect(request.method).to.be.equal('GET')
    expect(request.url).to.be.equal(YOUR_BITS_URL)


  it 'your bits history view renderized with transactions', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, YOUR_BITS_RESPONSE)
    @view.render()
    expect(@model.attributes.transactions).not.equal(undefined)
    expect(@view.$('.addInfo span')).to.not.exist