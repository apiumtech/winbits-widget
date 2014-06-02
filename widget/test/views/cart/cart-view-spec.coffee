CartView = require 'views/cart/cart-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'CartViewSpec', ->

  before ->
    sinon.stub(utils, 'getApiToken').returns('XXX')
    sinon.stub(utils, 'isLoggedIn').returns(yes)

  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()

  beforeEach ->
    @el = $('<li>', id: 'wbi-cart-holder').get(0)
    @model = new Cart
    sinon.stub(@model, 'fetch')
    sinon.stub(@model, 'isCartEmpty').returns(no)
    @view = new CartView container: @el, model: @model

  afterEach ->
    @view.dispose()
    @model.fetch.restore()
    @model.isCartEmpty.restore()
    @model.dispose()

  it 'should be rendered', ->
    expect(@view.el).to.be.equal(@el)
    expect(@view.noWrap, 'expected to not be wrapped').to.be.true
    expect(@view.$ '#wbi-cart-info').to.exist
    expect(@view.$ '#wbi-cart-counter').to.exist
    expect(@view.$ '#wbi-cart-icon').to.exist
    expect(@view.$ '#wbi-cart-drop').to.exist
    expect(@view.$ '#wbi-cart-left-panel').to.exist
    expect(@view.$ '#wbi-cart-right-panel').to.exist

  it 'should apply dropMainMenu plugin on cart info', ->
    sinon.spy($.fn, 'dropMainMenu')

    @view.render()

    expect($.fn.dropMainMenu).to.have.been.calledOnce
    expect($.fn.dropMainMenu.firstCall.returnValue, 'ID inválido')
      .to.has.id('wbi-cart-info')

  it 'should render cart items view as subview', ->
    expectCartSubview.call(@, '#wbi-cart-items', 'wbi-cart-left-panel', 'cart-items')

  it 'should render cart totals view as subview', ->
    expectCartSubview.call(@, '#wbi-cart-totals', 'wbi-cart-right-panel', 'cart-totals')

  it 'should render cart bits view as subview', ->
    expectCartSubview.call(@, '#wbi-cart-bits', 'wbi-cart-right-panel', 'cart-bits')

  it 'should render cart payment methods view as subview', ->
    expectCartSubview.call(@, '#wbi-cart-payment-methods', 'wbi-cart-right-panel', 'cart-payment-methods')

  it 'should render subviews into right panel in the correct order', ->
    $rightPanelChildren = @view.$('#wbi-cart-right-panel').children()
    expect($rightPanelChildren.eq(0)).to.has.id('wbi-cart-totals')
    expect($rightPanelChildren.eq(1)).to.has.id('wbi-cart-bits')
    expect($rightPanelChildren.eq(2)).to.has.id('wbi-cart-payment-methods')

  it 'should share its model with its subviews', ->
    expect(@view.model).to.be.equal(@model)
    expect(@view.subview('cart-items').model).to.be.equal(@model)
    expect(@view.subview('cart-totals').model).to.be.equal(@model)
    expect(@view.subview('cart-bits').model).to.be.equal(@model)
    expect(@view.subview('cart-payment-methods').model).to.be.equal(@model)

  it 'should not show cart counter by default', ->
    expect(@view.$ '#wbi-cart-counter').to.has.$text('')

  it 'should render cart counter', ->
    @model.set itemsCount: 5
    @view.render()
    expect(@view.$ '#wbi-cart-counter').to.has.$text('5')

  it.skip 'should render all subviews along with it', ->
    cartItemsStub = stubSubviewRender.call(@, 'cart-items')
    cartTotalsStub = stubSubviewRender.call(@, 'cart-totals')
    cartBitsStub = stubSubviewRender.call(@, 'cart-bits')
    cartPaymentMethodsStub = stubSubviewRender.call(@, 'cart-payment-methods')

    @view.render()

    expect(cartItemsStub, 'cart items view not rendered')
      .to.have.been.calledOnce
    expect(cartTotalsStub, 'cart totals view not rendered')
      .to.have.been.calledOnce
    expect(cartBitsStub, 'cart bits view not rendered')
      .to.have.been.calledOnce
    expect(cartPaymentMethodsStub, 'cart payment methods view not rendered')
      .to.have.been.calledOnce

  it 'should subscribe to "cart-changed" event', ->
    sinon.stub(@view, 'onCartChanged')

    EventBroker.publishEvent('cart-changed')

    expect(@view.onCartChanged).to.has.been.calledOnce

    @view.onCartChanged.restore()

  it 'should allow to open cart if not empty', ->
    @model.isCartEmpty.returns(no)
    $cartDrop = @view.$('#wbi-cart-drop').hide()

    @view.$('#wbi-cart-info').click()
    expect($cartDrop).to.be.displayed

  it 'should not open cart if empty', ->
    @model.isCartEmpty.returns(yes)
    $cartDrop = @view.$('#wbi-cart-drop').hide()

    @view.$('#wbi-cart-info').click()
    expect($cartDrop).to.not.be.displayed

  expectCartSubview = (viewSelector, parentId, subviewName) ->
    $subview = @view.$(viewSelector)
    expect($subview).to.exist
    expect($subview.parent()).to.has.id(parentId)
    expect(@view.subview(subviewName)).to.be.ok

  stubSubviewRender = (subview) ->
    sinon.stub(@view.subview(subview), 'render')
