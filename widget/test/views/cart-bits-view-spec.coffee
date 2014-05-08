'use strict'
CartBitsView = require 'views/cart/cart-bits-view'
Cart = require 'models/cart/cart'
$ = Winbits.$
_ = Winbits._

describe 'CartBitsViewSpec', ->

  beforeEach ->
    @clock = sinon.useFakeTimers()
    @model = new Cart
    @view = new CartBitsView model: @model
    @model = @view.model
    @view.render()

  afterEach ->
    @clock.restore()
    @view.dispose()
    @model.set.restore?()
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

  it.skip 'should render cart percentage saved', ->
    @model.set(itemsTotal: 100, shippingTotal: 250, bitsTotal: 20)

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
    expect($bitsSlider).to.has.data('max', 150)

  it 'should apply custom slider plugin for car bits slider', ->
    customSliderStub = sinon.spy($.fn, 'customSlider')
    @view.render()

    expect(customSliderStub).to.has.been.calledOnce
    bitsSlider = @view.$('input#wbi-cart-bits-slider').get(0)
    expect(customSliderStub.firstCall.returnValue.get(0)).to.be.equal(bitsSlider)

  it "should work slide event in bits's bar ", ->
    sinon.stub @model, 'set'
    @view.$('.ui-slider').trigger 'slide'
    expect(@model.set).to.has.been.calledOnce

  it "should work slidechange event in bits's bar ", ->
    sinon.stub(@view, 'updateBalanceValues')
    $winbitsSlider = @view.$('.ui-slider')
    $winbitsSlider.find('.slider-amount em').text()
    $winbitsSlider.trigger('slidechange')
    @clock.tick(123100000)
    expect(@view.updateBalanceValues).to.has.been.calledOnce

  it "should work slidechange event in bits's bar ", ->
    @model.set 'itemsTotal', 60
    @view.render()
    sinon.stub(@view, 'updateCartBits')
    $winbitsSlider = @view.$('.ui-slider')
    $winbitsSlider.find('.slider-amount em').text()
    $winbitsSlider.trigger('slidechange')
    @clock.tick(133100000)
    expect(@view.updateCartBits).to.has.been.calledOnce