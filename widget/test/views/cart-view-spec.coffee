CartView = require 'views/cart/cart-view'
# Cart = require 'models/cart/cart'
$ = Winbits.$

describe 'CartViewSpec', ->

  beforeEach ->
    # @model = new Cart
    @el = $('<li>', id: 'wbi-cart-holder').get(0)
    @view = new CartView container: @el# model: @model

  afterEach ->
    @view.dispose()
    # @model.dispose()

  it 'should be rendered', ->
    expect(@view.el).to.be.equal(@el)
    expect(@view.noWrap, 'expected to not be wrapped').to.be.true
    expect(@view.$ '#wbi-cart-info').to.exist
    expect(@view.$ '#wbi-cart-counter').to.exist
        .and.to.has.text('')
    expect(@view.$ '#wbi-cart-icon').to.exist
    expect(@view.$ '#wbi-cart-drop').to.exist
    expect(@view.$ '#wbi-cart-left-panel').to.exist
    expect(@view.$ '#wbi-cart-right-panel').to.exist

  it 'should apply dropMainMenu plugin on cart info', ->
    dropMainMenuStub = sinon.stub()
    viewStub = sinon.stub(@view, '$').returns(dropMainMenu: dropMainMenuStub)

    @view.render()

    expect(viewStub).to.have.been.calledWith('#wbi-cart-info')
    expect(dropMainMenuStub).to.have.been.calledOnce

  it 'should render cart items view as subview', ->
    expect(@view.$ '#wbi-cart-items').to.exist
