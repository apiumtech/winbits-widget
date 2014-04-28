ShippingAddresesView = require 'views/shipping-addresses/shipping-addresses-view'
ShippingAddressesModel = require 'models/shipping-addresses/shipping-addresses'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$


describe 'ShippingAddressesViewSpec', ->
  'use strict'

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    data= '{
            "meta":{"status":200},
            "response":
              [{"id":84,"firstName":"firstName","lastName":"lastName","betweenStreets":"betweenStreets",
               "indications":"indications","main":true,"zipCodeInfo":null,"zipCode":null,"location":null,"county":null,
               "state":null,"street":"Calle 7","internalNumber":null,"externalNumber":"456","phone":null}]
           }'
    sinon.stub(@model, 'fetch').yieldsTo('success', @model, data)
    @model = new ShippingAddressesModel
    @view = new ShippingAddresesView model: @model

  afterEach ->
    @view.dispose?()
    @model.dispose?()

  it 'shipping addreses view renderized with no addresses', ->
    expect(@view.$('.shipCarrusel')).to.exist
    expect(@view.$('#wbi-no-shipping-addreseses')).to.exist


  it 'shipping addreses view renderized with 1 address', ->
    expect(@view.$('.shipCarrusel')).to.exist
    expect(@view.$('#wbi-shipping-addreseses-container')).to.exist
