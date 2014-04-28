CartBitsView = require 'views/cart/cart-bits-view'
Cart = require 'models/cart/cart'
$ = Winbits.$

describe 'CartBitsViewSpec', ->

  beforeEach ->
    @model = new Cart
    sinon.stub(@model, 'fetch')
    @view = new CartBitsView model: @model

  afterEach ->
    @view.dispose()
    @model.fetch.restore()
    @model.dispose()

  it 'should be rendered', ->
    expect(@view.$el).to.has.id('wbi-cart-bits')
        .and.to.has.$class('winSave')
    expect(@view.$ '#wbi-cart-cashback').to.exist
    expect(@view.$ '#wbi-cart-percentage-saved').to.exist
    expect(@view.$ 'input#wbi-cart-bits-slider').to.exist

  it 'should render defaults', ->
    expect(@view.$ '#wbi-cart-cashback').to.has.$text('0')
    expect(@view.$ '#wbi-cart-percentage-saved').to.has.$text('0%')
    expect(@view.$ 'input#wbi-cart-bits-slider').to.has.$val('0')

  it 'should render cart cashback', ->
    @model.set cashback: 100

    @view.render()

    expect(@view.$ '#wbi-cart-cashback').to.existExact(1)
        .and.to.has.$text('100')

  it 'should render cart percentage saved', ->
    @model.set(itemsTotal: 100, shippingTotal: 50, bitsTotal: 20)

    @view.render()

    expect(@view.$ '#wbi-cart-percentage-saved').to.existExact(1)
        .and.to.has.$text('70%')

  it 'should render cart bits slider', ->
    @model.set(itemsTotal: 100, shippingTotal: 50, bitsTotal: 20)

    @view.render()

    $bitsSlider = @view.$ 'input#wbi-cart-bits-slider'
    expect($bitsSlider).to.existExact(1)
        .and.to.has.$val('20')
        .and.to.has.data('step', 1)
    expect($bitsSlider).to.has.data('max', 30)

  it 'should apply custom slider plugin for car bits slider', ->
    customSliderStub = sinon.spy($.fn, 'customSlider')
    @view.render()

    expect(customSliderStub).to.has.been.calledOnce
    bitsSlider = @view.$('input#wbi-cart-bits-slider').get(0)
    expect(customSliderStub.firstCall.returnValue.get(0)).to.be.equal(bitsSlider)
