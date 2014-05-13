'use strict'

EditCardView = require 'views/cards/edit-card-view'
Card = require 'models/cards/card'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'EditCardViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []
    @xhr = sinon.useFakeXMLHttpRequest()

  after ->
    $.validator.setDefaults ignore: ':hidden'
    @xhr.restore()

  beforeEach ->
    @model = new Card
    @view = new EditCardView model: @model
    sinon.stub(@model, 'requestSaveNewCard').returns(TestUtils.promises.idle)

  afterEach ->
    @view.dispose()
    @model.requestSaveNewCard.restore()
    @model.dispose()
    $.fn.customSelect.restore?()
    $.fn.customCheckbox.restore?()
    $.fn.slideUp.restore?()
    utils.showAjaxLoading.restore?()
    utils.showMessageModal.restore?()
    utils.hideAjaxLoading.restore?()
    utils.getCreditCardType.restore?()
    @view.fixCardNumberMaxLengthByCardType.restore?()

  it 'should render wrapper', ->
    expect(@view.$el).to.has.id('wbi-edit-card-view')
    expect(@view.$el).to.has.$class('creditcardNew')

  it.skip 'should render form input fields without value attribute', ->
    for input in @view.$('input[type=text]')
      expect($(input)).to.not.has.$attr('value')

  it.skip 'should no request to save new card if data invalid', ->
    @view.$('#wbi-save-card-btn').click()

    expect(@model.requestSaveNewCard).to.not.has.been.called

  it.skip 'should not show loading indicator if data invalid', ->
    sinon.stub(utils, 'showAjaxLoading')
    @view.$('#wbi-save-card-btn').click()

    expect(utils.showAjaxLoading).to.not.has.been.called

  it.skip 'should request to save new card if data valid', ->
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()

    expect(@model.requestSaveNewCard).to.has.been.calledWithMatch(cardData, @view)
        .and.to.be.calledOnce

  it.skip 'should show loading indicator if data is valid', ->
    sinon.stub(utils, 'showAjaxLoading')
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(utils.showAjaxLoading).to.has.been.calledOnce

  it.skip 'should publish "cards-changed" event if card saving succeds', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('cards-changed', stub)
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(stub).to.has.been.calledOnce

  it.skip 'should show message to inform card was saved if card saving succeds', ->
    sinon.stub(utils, 'showMessageModal')
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(utils.showMessageModal).to.has.been.calledWith('Tus datos fueron guardados correctamente.', acceptAction: @view.hideNewCardView, context: @view)
        .and.to.has.been.calledOnce

  it.skip 'should hide ajax loading if card saving succeds', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(utils.hideAjaxLoading).to.has.been.calledOnce

  it.skip 'should hide ajax loading if card saving fails', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestSaveNewCard.returns(new $.Deferred().rejectWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
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
    colony: 'Virreyes'
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
