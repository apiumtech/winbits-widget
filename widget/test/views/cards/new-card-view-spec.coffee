'use strict'

NewCardView = require 'views/cards/new-card-view'
Card = require 'models/cards/card'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'NewCardViewSpec', ->

  before ->
    @xhr = sinon.useFakeXMLHttpRequest()

  after ->
    @xhr.restore()

  beforeEach ->
    @model = new Card
    @view = new NewCardView model: @model
    sinon.stub(@model, 'requestSaveNewCard').returns(TestUtils.promises.idle)
    sinon.stub(utils, 'showAjaxLoading')
    sinon.stub(utils, 'showMessageModal')

  afterEach ->
    @view.dispose()
    @model.requestSaveNewCard.restore()
    @model.dispose()
    $.fn.customSelect.restore?()
    $.fn.customCheckbox.restore?()
    $.fn.slideUp.restore?()
    utils.showAjaxLoading.restore()
    utils.showMessageModal.restore()
    utils.hideAjaxLoading.restore?()
    utils.getCreditCardType.restore?()
    @view.fixCardNumberMaxLengthByCardType.restore?()

  it 'should render wrapper', ->
    expect(@view.$el).to.has.id('wbi-new-card-view')
    expect(@view.$el).to.has.$class('creditcardNew')

  it 'should render form input fields without value attribute', ->
    for input in @view.$('input[type=text]')
      expect($(input)).to.not.has.$attr('value')

  it 'should not request to save new card if data invalid', ->
    @view.$('.wbc-save-card-btn').click()

    expect(@model.requestSaveNewCard).to.not.has.been.called

  it 'should not show loading indicator if data invalid', ->
    @view.$('.wbc-save-card-btn').click()

    expect(utils.showAjaxLoading).to.not.has.been.called

  it 'should request to save new card if data valid', ->
    cardData = loadValidData.call(@)

    @view.$('.wbc-save-card-btn').click()

    expect(@model.requestSaveNewCard).to.has.been.calledWithMatch(cardData, @view)
        .and.to.be.calledOnce

  it 'should show loading indicator if data is valid', ->
    cardData = loadValidData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(utils.showAjaxLoading).to.has.been.calledOnce

  it 'should publish "cards-changed" event if card saving succeds', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('cards-changed', stub)
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(stub).to.has.been.calledOnce

  it 'should show message to inform card was saved if card saving succeds', ->
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expectedOptions = onClosed: @view.hideCardView, context: @view, icon: 'iconFont-ok'
    expect(utils.showMessageModal).to.has.been.calledWith('Tus datos se han guardado correctamente.', expectedOptions)
        .and.to.has.been.calledOnce

  it 'should hide ajax loading if card saving succeds', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(utils.hideAjaxLoading).to.has.been.calledOnce

  it 'should hide ajax loading if card saving fails', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestSaveNewCard.returns(new $.Deferred().rejectWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(utils.hideAjaxLoading).to.has.been.calledOnce

  getValidCartData = ->
    firstName: 'Steve'
    lastName: 'Jobs'
    accountNumber: '4111111111111111'
    expirationMonth: '10'
    expirationYear: '18'
    country: 'MX'
    street1: 'Reforma'
    number: '1'
    city: 'Mexico'
    state: 'DF'
    postalCode: '11000'
    phoneNumber: '5553259000'

  loadValidData = ->
    cardData = getValidCartData()
    $fields = @view.$(':input')
    for own key, value of cardData
      $fields.filter("[name=#{key}]").val(value)
    cardData
