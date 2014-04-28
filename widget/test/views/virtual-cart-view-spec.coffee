CartView = require 'views/cart/cart-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
$ = Winbits.$

describe 'VirtualCartViewSpec', ->

  before ->
    sinon.stub(utils, 'getApiToken').returns(undefined)
    sinon.stub(utils, 'isLoggedIn').returns(no)

  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()

  beforeEach ->
    @el = $('<li>', id: 'wbi-cart-holder').get(0)
    @model = new Cart
    sinon.stub(@model, 'fetch')
    @view = new CartView container: @el, model: @model

  afterEach ->
    @view.render.restore?()
    @model.fetch.restore()
    @view.dispose()
    @model.dispose()

  it 'should fetch virtual cart when initialized', ->
    expect(@model.fetch).to.has.been.calledOnce

  it 'shold render when model changes', ->
    sinon.stub(@view, 'render')

    @model.set(itemsCount: 10, itemsTotal: 100)

    expect(@view.render).to.have.been.calledOnce
