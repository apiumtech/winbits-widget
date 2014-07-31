'use strict'

OrderTempBitsView = require 'views/checkout-temp/checkout-temp-bits-sub-view'
Order = require 'models/checkout-temp/checkout-temp'
testUtils = require 'test/lib/test-utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'CheckoutTempBitsViewSpec', ->

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 100
    mediator.data.set 'login-data', @loginData
    @clock = sinon.useFakeTimers()
    @model = new Order itemsTotal: 60
    @view = new OrderTempBitsView model: @model
    @model = @view.model
    @view.render()

  afterEach ->
    @clock.restore()
    @view.dispose()
    @model.set.restore?()
    @model.dispose()

  it 'should be rendered', ->
    expect(@view.$ 'input#wbi-order-bits-slider').to.exist

  it 'should render defaults', ->
    expect(@view.$ 'input#wbi-order-bits-slider').to.has.$val('0')

  it 'should render checkout temp bits slider', ->
    @model.set(itemsTotal: 100, shippingTotal: 50, bitsTotal: 20, total:150)

    @view.render()

    $bitsSlider = @view.$ 'input#wbi-order-bits-slider'
    expect($bitsSlider).to.existExact(1)
        .and.to.has.$val('20')
        .and.to.has.data('step', 1)
    expect($bitsSlider).to.has.data('max', 150)

  it 'should apply custom slider plugin for order bits slider', ->
    customSliderStub = sinon.spy($.fn, 'customSlider')
    @view.render()

    expect(customSliderStub).to.has.been.calledOnce
    bitsSlider = @view.$('input#wbi-order-bits-slider').get(0)
    expect(customSliderStub.firstCall.returnValue.get(0))
      .to.be.equal(bitsSlider)
    $.fn.customSlider.restore()

  it "should work slide event in bits's bar ", ->
    sinon.stub @model, 'set'
    @view.$('.ui-slider').trigger 'slide'
    expect(@model.set).to.has.been.calledOnce
