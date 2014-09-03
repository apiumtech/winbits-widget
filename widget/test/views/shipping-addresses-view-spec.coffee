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
    @view.dispose()
    @model.dispose()
    utils.showConfirmationModal.restore?()

  it 'shipping addreses view renderized with no addresses', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, "")

    expect(@view.$('.shipCarrusel')).to.exist
    expect(@view.$('#wbi-add-new-shipping-address')).to.exist
    expect(@view.$('#wbi-shipping-new-address-container')).to.exist
    expect(@view.$('#wbi-no-shipping-addreseses')).to.exist


  it 'shipping addreses view renderized with 1 address', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ADDRESSES_RESPONSE)

    expect(@view.$('.shipCarrusel')).to.exist
    expect(@view.$('#wbi-add-new-shipping-address')).to.exist
    expect(@view.$('#wbi-shipping-new-address-container')).to.exist
    expect(@view.$('div#wbi-shipping-addreseses-container')).to.exist
    .and.has.a.child

  it "should request get shipping addresses", ->
    request = @requests[0]

    expect(request.method).to.be.equal('GET')
    expect(request.url).to.be.equal(SHIPPING_ADDRESSES_URL)

  it "With shipping address exist icon to delete it", ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ADDRESSES_RESPONSE)
    deleteButton =@view.$('span.wbc-delete-shipping-link')

    expect(deleteButton).to.exist

  it "With NO shipping address doesn't exist icon to delete it", ->
    deleteButton =@view.$('span.wbc-delete-shipping-link')

    expect(deleteButton).to.not.exist

  it "Should be called modal render", ->
    sinon.stub(@view,'doDeleteShipping')
    confirmationStub = sinon.stub(utils, 'showConfirmationModal')
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ADDRESSES_RESPONSE)
    @view.$('span.wbc-delete-shipping-link').click()

    expect(confirmationStub).to.be.calledOnce

  it "Should delete shipping address ", ->
    sinon.stub(@model, 'requestDeleteShippingAddress').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doSuccessDeleteShippingAddress')
    errorStub = sinon.stub(@view, 'doErrorDeleteShippingAddress')
    @view.doRequestDeleteShippingAddress('1')
    expect(successStub).to.be.calledOnce
    expect(errorStub).to.not.be.calledOnce

  it "Should NO delete shipping address with error in api", ->
    sinon.stub(@model, 'requestDeleteShippingAddress').returns TestUtils.promises.rejected
    successStub = sinon.stub(@view, 'doSuccessDeleteShippingAddress')
    errorStub = sinon.stub(@view, 'doErrorDeleteShippingAddress')
    @view.doRequestDeleteShippingAddress('1')
    expect(successStub).to.not.be.calledOnce
    expect(errorStub).to.be.calledOnce

  it "With shipping address exist link to edit it", ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ADDRESSES_RESPONSE)
    editButton =@view.$('a.wbc-edit-shipping-link')

    expect(editButton).to.exist

  it "With NO shipping address doesn't exist link to edit it", ->
    editButton =@view.$('a.wbc-edit-shipping-link')
    expect(editButton).to.not.exist


  it "Should be called subView to edit", ->
    sinon.stub(@view,'doEditShippingAddress')
    getShippingAddressStub = sinon.stub(@model, 'getShippingAddress')
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ADDRESSES_RESPONSE)
    @view.$('a.wbc-edit-shipping-link').click()

    expect(getShippingAddressStub).to.be.calledOnce

  it "Should be called request Set Main Shipping", ->
    sinon.stub(@view,'doEditShippingAddress')
    onShippingClickStub = sinon.stub(@view, 'onShippingClick')
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, SHIPPING_ADDRESSES_RESPONSE)
    @view.$('.wbc-shipping').click()

    expect(@view.$('.wbc-shipping')).to.exist
    expect(onShippingClickStub).to.be.calledOnce

  it "Should NO be called request Set Main Shipping with no addresses", ->
    sinon.stub(@view,'doEditShippingAddress')
    onShippingClickStub = sinon.stub(@view, 'onShippingClick')

    expect(@view.$('.wbc-shipping')).to.not.exist
    expect(onShippingClickStub).to.not.be.calledOnce
