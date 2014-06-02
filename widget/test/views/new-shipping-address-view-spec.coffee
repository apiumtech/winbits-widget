'use strict'
AddNewShippingAddresView = require 'views/shipping-addresses/add-new-shipping-address-view'
ShippingAddressesModel = require 'models/shipping-addresses/shipping-addresses'
testUtils = require 'test/lib/test-utils'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

#setup to test
firstName = "firstName"
lastName = "lastName"
street = "street to test"
phone = "5557871374"
indications = "indications to test"
externalNumber = "10"
state = "state"
city = "city"
zipCode = "12345"
zipCodeInfo = "Colonia"
location = "location"

describe 'AddShippingAddressViewSpec', ->

  before ->
    $.validator.setDefaults({ ignore: [] })
    sinon.stub($, 'ajax').returns(testUtils.promiseResolvedWithData())

  after ->
    $.validator.setDefaults({ ignore: ':hidden' })
    $.ajax.restore()

  beforeEach ->
    @model = new ShippingAddressesModel
    container = $('<div id="wbi-shipping-new-address-container"></div>')
    @view = new AddNewShippingAddresView container: container, model: @model

    @view.$('[name=zipCode]').val zipCode
    @view.$('[name=firstName]').val firstName
    @view.$('[name=lastName]').val lastName
    @view.$('[name=lastName2]').val lastName
    @view.$('[name=street]').val street
    @view.$('[name=phone]').val phone
    @view.$('[name=indications]').val indications
    @view.$('[name=externalNumber]').val externalNumber
    @view.$('[name=state]').val state
    @view.$('[name=city]').val city
    @view.$('[name=zipCodeInfo]').wblocationselect('loadZipCode', '12345')
    @view.$('[name=location]').val location

  afterEach ->
    @view.dispose()
    @model.dispose()

  it 'add shipping addreses view should be rendered', ->
    expect(@view.$('#wbi-add-shipping-address-submit-btn')).to.exist
    expect(@view.$('#wbi-add-shipping-address-cancel')).to.exist
    expect(@view.$('#wbi-add-shipping-address-error')).to.exist


  it 'should call request Success Save New Shipping Address', ->
    sinon.stub(@model, 'requestSaveNewShippingAddress').returns TestUtils.promises.resolved
    resquestSuccess = sinon.stub(@view, 'successSaveNewShippingAddress')
    @view.$('#wbi-add-shipping-address-submit-btn').click()
    expect(@view.$('.error')).to.not.exist
    expect(resquestSuccess).to.calledOnce

  it 'should call request Error Save New Shipping Address', ->
    sinon.stub(@model, 'requestSaveNewShippingAddress').returns TestUtils.promises.rejected
    resquestSuccess = sinon.stub(@view, 'successSaveNewShippingAddress')
    resquestError = sinon.stub(@view, 'errorSaveNewShippingAddress')
    @view.$('#wbi-add-shipping-address-submit-btn').click()
    expect(@view.$('.error')).to.not.exist
    expect(resquestSuccess).to.not.called
    expect(resquestError).to.calledOnce

  it 'should not call request Save New Shipping for fail in validation', ->
    @view.$('[name=firstName]').val('')
    resquestSuccess = sinon.stub(@view, 'successSaveNewShippingAddress')
    @view.$('#wbi-add-shipping-address-submit-btn').click()
    expect(@view.$('.error')).to.exist
    expect(resquestSuccess).to.not.called