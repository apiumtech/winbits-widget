ShippingAddresesView = require 'views/shipping-addresses/shipping-addresses-view'
ShippingAddressesModel = require 'models/shipping-addresses/shipping-addresses'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$


describe 'ShippingAddressesViewSpec', ->
  'use strict'

  SHIPPING_ADDRESSES_URL = utils.getResourceURL("users/shipping-addresses.json")
  SHIPPING_ADDRESSES_RESPONSE = '{"meta":{"status":200},"response":[{"id":84,"firstName":"firstName","lastName":"lastName","betweenStreets":"betweenStreets","indications":"indications","main":true,"zipCodeInfo":null,"zipCode":null,"location":null,"county":null,"state":null,"street":"Calle 7","internalNumber":null,"externalNumber":"456","phone":null}]}'

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @data = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @data.onCreate = (data) -> requests.push(data)

    @model = new ShippingAddressesModel
    @view = new ShippingAddresesView model: @model

  afterEach ->
    @data.restore()
    @view.dispose?()
    @model.dispose?()

  it 'shipping addreses view renderized with no addresses', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, "")
    expect(@view.$('.shipCarrusel')).to.exist
    expect(@view.$('#wbi-no-shipping-addreseses')).to.exist


  it 'shipping addreses view renderized with 1 address', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ADDRESSES_RESPONSE)
    expect(@view.$('.shipCarrusel')).to.exist
    expect(@view.$('div#wbi-shipping-addreseses-container')).to.exist
    .and.has.a.child

  it "should request get shipping addresses", ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ADDRESSES_RESPONSE)
    expect(request.method).to.be.equal('GET')
    expect(request.url).to.be.equal(SHIPPING_ADDRESSES_URL)

