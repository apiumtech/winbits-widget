'use strict'
EditShippingAddresView = require 'views/shipping-addresses/edit-shipping-address-view'
EditShippingAddressesModel = require 'models/shipping-addresses/edit-shipping-address'
testUtils = require 'test/lib/test-utils'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$


describe 'EditShippingAddressViewSpec', ->

  before ->
    $.validator.setDefaults({ ignore: [] })
    sinon.stub($, 'ajax').returns(testUtils.promiseResolvedWithData())

  after ->
    $.validator.setDefaults({ ignore: ':hidden' })
    $.ajax.restore()

  beforeEach ->
    address = {"id":131,"firstName":"Test","lastName":"Test","betweenStreets":null,"indications":"Escuela Calmecac","main":true,"zipCodeInfo":{"id":2,"locationName":"San Carlos","locationCode":"88","locationType":"1","county":"Ecatepec","city":"Ecatepec","state":"Mexico","zipCode":"11111"},"zipCode":"11111","location":"San Carlos","county":"Ecatepec","state":"Mexico","lastName2":"Test2","street":"Robles","internalNumber":"","externalNumber":"13","phone":"111111111111111"}
    @model = new EditShippingAddressesModel (address)
    container = $('<div id="wbi-edit-shipping-address-container"></div>')
    @view = new EditShippingAddresView container: container, model: @model

  afterEach ->
    @view.dispose()
    @model.dispose()

  it 'edit shipping addreses view should be rendered with arguments', ->
    expect(@view.$('#wbi-edit-shipping-address-submit-btn')).to.exist
    expect(@view.$('#wbi-edit-shipping-address-cancel')).to.exist
    expect(@view.$('#wbi-edit-shipping-address-error')).to.exist
    expect( @view.$('[name=firstName]')).to.has.value "Test"
    expect( @view.$('[name=lastName]')).to.has.value "Test"
    expect( @view.$('[name=lastName2]')).to.has.value "Test2"


  it 'should call request Success Save Edit Shipping Address', ->
    sinon.stub(@model, 'requestSaveEditShippingAddress').returns TestUtils.promises.resolved
    resquestSuccess = sinon.stub(@view, 'successSaveEditShippingAddress')
    @view.$('#wbi-edit-shipping-address-submit-btn').click()
    expect(@view.$('.error')).to.not.exist
    expect(resquestSuccess).to.calledOnce

  it 'should call request Error Save Edit Shipping Address', ->
    sinon.stub(@model, 'requestSaveEditShippingAddress').returns TestUtils.promises.rejected
    resquestSuccess = sinon.stub(@view, 'successSaveEditShippingAddress')
    resquestError = sinon.stub(@view, 'errorSaveEditShippingAddress')
    @view.$('#wbi-edit-shipping-address-submit-btn').click()
    expect(@view.$('.error')).to.not.exist
    expect(resquestSuccess).to.not.called
    expect(resquestError).to.calledOnce
