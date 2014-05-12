'use strict'

NewCardView = require 'views/cards/new-card-view'
Card = require 'models/cards/card'
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

  it 'should render wrapper', ->
    expect(@view.$el).to.has.id('wbi-new-card-view')
    expect(@view.$el).to.has.$class('creditcardNew')

  it 'should be rendered', ->
    expect(@view.$('form#wbi-new-card-form')).to.existExact(1)
    expect(@view.$('#wbi-save-card-btn')).to.existExact(1)
    expect(@view.$('.wbc-cancel-btn')).to.existExact(1)
    expect(@view.$('#wbi-new-card-status-layer')).to.existExact(1)

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
        'street1', 'number', 'phoneNumber', 'postalCode', 'colony', 'city', 'cardPrincipal']
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

  it 'should request to save new card if data valid', ->
    cardData = loadValidData.call(@)

    @view.$('#wbi-save-card-btn').click()

    expect(@model.requestSaveNewCard).to.has.been.calledWithMatch(cardData, @view)
        .and.to.be.calledOnce

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
    postalCode: '11000'
    phoneNumber: '5553259000'

  loadValidData = ->
    cardData = getValidCartData()
    $fields = @view.$(':input')
    for own key, value of cardData
      $fields.filter("[name=#{key}]").val(value)
    cardData
