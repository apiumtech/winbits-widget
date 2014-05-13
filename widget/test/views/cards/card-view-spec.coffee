'use strict'

CardView = require 'views/cards/card-view'
Card = require 'models/cards/card'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'CardViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []
    @xhr = sinon.useFakeXMLHttpRequest()

  after ->
    $.validator.setDefaults ignore: ':hidden'
    @xhr.restore()

  beforeEach ->
    @model = new Card
    @view = new CardView model: @model
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
