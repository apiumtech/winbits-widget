'use strict'

NewCardView = require 'views/cards/new-card-view'
Card = require 'models/cards/card'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'NewCardViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []
    @xhr = sinon.useFakeXMLHttpRequest()

  after ->
    $.validator.setDefaults ignore: ':hidden'
    @xhr.restore()

  beforeEach ->
    @model = new Card
    @view = new NewCardView model: @model
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
    expect(@view.$el).to.has.id('wbi-new-card-view')
    expect(@view.$el).to.has.$class('creditcardNew')

  it 'should be rendered', ->
    expect(@view.$('form#wbi-new-card-form')).to.existExact(1)
    expect(@view.$('#wbi-save-card-btn')).to.existExact(1)
    expect(@view.$('.wbc-cancel-btn')).to.existExact(1)
    expect(@view.$('#wbi-new-card-status-layer')).to.existExact(1)
    $cardLogo = @view.$('.wbc-card-logo')
    expect($cardLogo).to.existExact(1)
    expect($cardLogo).to.has.$attr('class').that.not.match(/iconFont-+/)

  it 'should apply customSelect plugin when rendered', ->
    sinon.spy($.fn, 'customSelect')

    @view.render()
    expect($.fn.customSelect).to.has.been.calledOnce
    $countrySelect = $.fn.customSelect.firstCall.returnValue
    expect($countrySelect).to.has.$class('wbc-country-field')
    expect($countrySelect).to.has.$val('MX')

  it 'should render form fields', ->
    fieldNames = [
        'firstName', 'lastName', 'accountNumber', 'expirationMonth', 'expirationYear',
        # 'cvNumber',
        'street1', 'number', 'phoneNumber', 'postalCode', 'colony', 'city', 'state', 'cardPrincipal']
    for fieldName in fieldNames
      $field = @view.$("[name=#{fieldName}]")
      expect($field).to.exist

  it 'should apply customCheckbox plugin when rendered', ->
    sinon.spy($.fn, 'customCheckbox')

    @view.render()
    expect($.fn.customCheckbox).to.has.been.calledOnce
    $checkWrapper = $.fn.customCheckbox.firstCall.returnValue
    expect($checkWrapper.find('[name=cardPrincipal]')).to.exist

  it 'should apply customCheckbox plugin when rendered', ->
    sinon.spy($.fn, 'customCheckbox')

    @view.render()
    expect($.fn.customCheckbox).to.has.been.calledOnce
    $checkWrapper = $.fn.customCheckbox.firstCall.returnValue
    expect($checkWrapper.find('[name=cardPrincipal]')).to.exist

  it 'should show validate expiration month', ->
    $expirationMonth = @view.$('[name=expirationMonth]')
    $form = $expirationMonth.closest('form')
    validator = $form.validate()
    invalidValues = ['00', '13']
    for value in invalidValues
      $expirationMonth.val(value)
      validator.element($expirationMonth)

      expect($form.find('span.error')).to.exist
            .and.to.has.$text('Escribe una fecha válida.')
      validator.resetForm()

  it 'should no request to save new card if data invalid', ->
    @view.$('#wbi-save-card-btn').click()

    expect(@model.requestSaveNewCard).to.not.has.been.called

  it 'should not show loading indicator if data invalid', ->
    sinon.stub(utils, 'showAjaxLoading')
    @view.$('#wbi-save-card-btn').click()

    expect(utils.showAjaxLoading).to.not.has.been.called

  it 'should request to save new card if data valid', ->
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()

    expect(@model.requestSaveNewCard).to.has.been.calledWithMatch(cardData, @view)
        .and.to.be.calledOnce

  it 'should show loading indicator if data is valid', ->
    sinon.stub(utils, 'showAjaxLoading')
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(utils.showAjaxLoading).to.has.been.calledOnce

  it 'should publish "cards-changed" event if card saving succeds', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('cards-changed', stub)
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(stub).to.has.been.calledOnce

  it 'should show message to inform card was saved if card saving succeds', ->
    sinon.stub(utils, 'showMessageModal')
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(utils.showMessageModal).to.has.been.calledWith('Tus datos fueron guardados correctamente.', acceptAction: @view.hideNewCardView, context: @view)
        .and.to.has.been.calledOnce

  it 'should hide ajax loading if card saving succeds', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(utils.hideAjaxLoading).to.has.been.calledOnce

  it 'should hide ajax loading if card saving fails', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestSaveNewCard.returns(new $.Deferred().rejectWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()
    expect(utils.hideAjaxLoading).to.has.been.calledOnce

  it 'should hide view on cancel btn click', ->
    sinon.spy($.fn, 'slideUp')

    @view.$('.wbc-cancel-btn').click()
    expect($.fn.slideUp).to.has.been.calledOnce
    expect($.fn.slideUp.firstCall.returnValue).to.be.equal(@view.$el)

  it 'should publish "card-subview-hidden" event on cancel btn click', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('card-subview-hidden', stub)

    @view.$('.wbc-cancel-btn').click()
    expect(stub).to.has.been.calledOnce

  it 'should show card logo when card number text changes', ->
    cardNumber = '4111'
    cardType = 'visa'
    sinon.stub(utils, 'getCreditCardType').returns(cardType)

    $cardNumberField = @view.$('[name=accountNumber]')
    $cardNumberField.val(cardNumber).trigger('textchange')
    expect(utils.getCreditCardType).to.has.been.calledWith(cardNumber)
        .and.to.has.been.calledOnce
    expect(@view.$('.wbc-card-logo')).to.has.$class("iconFont-#{cardType}")
    expect($cardNumberField.data('card-type')).to.be.equal(cardType)

  it 'should fix max length when card number text changes', ->
    cardType = 'visa'
    sinon.stub(utils, 'getCreditCardType').returns(cardType)
    sinon.stub(@view, 'fixCardNumberMaxLengthByCardType')
    $cardNumberField = @view.$('[name=accountNumber]')

    $cardNumberField.val('4111').trigger('textchange')
    expect(@view.fixCardNumberMaxLengthByCardType).to.has.been.calledWith(cardType)
        .and.to.has.been.calledOnce
    expect(@view.fixCardNumberMaxLengthByCardType.firstCall.args[1]).to.has.attr('name', 'accountNumber')

  it 'should fix max length to 16 when card type is not "amex"', ->
    $cardNumberField = @view.$('[name=accountNumber]')

    for cardType in ['visa', 'mastercard', 'unknown']
      $cardNumberField.attr('maxlength', '20')
      @view.fixCardNumberMaxLengthByCardType(cardType, $cardNumberField)

      expect($cardNumberField).to.has.$attr('maxlength', '16')

  it 'should fix max length to 15 when card type is "amex"', ->
    $cardNumberField = @view.$('[name=accountNumber]')

    $cardNumberField.attr('maxlength', '20')
    @view.fixCardNumberMaxLengthByCardType('amex', $cardNumberField)

    expect($cardNumberField).to.has.$attr('maxlength', '15')

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
