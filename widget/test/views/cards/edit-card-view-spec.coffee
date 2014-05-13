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
    @model = new Card getCardModelAttributes()
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

  it 'should render form input fields with values', ->
    data =
      "expirationMonth": "05"
      "expirationYear": "15"
      "phoneNumber": "5553259000"
      "country": "MX"
      "postalCode": "11000"
      "state": "Distrito Federal"
      "street1": "Reforma"
      "number": "1"
      "city": "Mexico"
    for own fieldName, fieldValue of data
      $field = @view.$ "[name=#{fieldName}]"
      expect($field).to.has.$attr('value', fieldValue)
      expect($field).to.has.$val(fieldValue)

  it 'should render card data with class', ->
    fieldNames = ['firstName', 'lastName', 'accountNumber']
    for fieldName in fieldNames
      $field = @view.$(".wbc-field-#{fieldName}")
      expect($field).to.existExact(1)

  it 'should render card data fields values', ->
    fieldsData =
      "firstName": "STEVE"
      "lastName": "JOBS"
      "accountNumber": "XXXXXXXXXXXX1111"
    for own fieldName, fieldValue of fieldsData
      $field = @view.$(".wbc-field-#{fieldName}")
      expect($field).to.has.$attr('value', fieldValue)
      expect($field).to.has.$val(fieldValue)

  it 'should render card data fields without name', ->
    fieldNames = ['firstName', 'lastName', 'accountNumber']
    for fieldName in fieldNames
      $field = @view.$(".wbc-field-#{fieldName}")
      expect($field).to.not.has.$attr('name')

  it 'should render card data form fields non-editable', ->
    fieldNames = ['firstName', 'lastName', 'accountNumber']
    for fieldName in fieldNames
      $field = @view.$(".wbc-field-#{fieldName}")
      expect($field).to.has.$attr('readonly')

  it 'should render checkbox as checked if card is principal', ->
    $field = @view.$("[name=cardPrincipal]")
    expect($field).to.has.$attr('checked')
    expect($field.prop('checked')).to.be.true

  it 'should render checkbox as unchecked if card is not principal', ->
    @model.set('cardPrincipal', no)

    @view.render()

    $field = @view.$("[name=cardPrincipal]")
    expect($field).to.not.has.$attr('checked')
    expect($field.prop('checked')).to.be.false

  it 'should render checkbox as unchecked if card is not principal', ->
    @model.set('cardPrincipal', no)

    @view.render()

    $field = @view.$("[name=cardPrincipal]")
    expect($field).to.not.has.$attr('checked')
    expect($field.prop('checked')).to.be.false

  it 'should render card logo', ->
    expect(@.view.$('.wbc-card-logo')).to.has.$class('iconFont-visa')

  it.skip 'should not show loading indicator if data invalid', ->
    sinon.stub(utils, 'showAjaxLoading')
    @view.$('#wbc-save-card-btn').click()

    expect(utils.showAjaxLoading).to.not.has.been.called

  it.skip 'should request to save new card if data valid', ->
    cardData = loadValidData.call(@)

    @view.$('#wbc-save-card-btn').click()

    expect(@model.requestSaveNewCard).to.has.been.calledWithMatch(cardData, @view)
        .and.to.be.calledOnce

  it.skip 'should show loading indicator if data is valid', ->
    sinon.stub(utils, 'showAjaxLoading')
    cardData = loadValidData.call(@)

    @view.$('#wbc-save-card-btn').click()
    expect(utils.showAjaxLoading).to.has.been.calledOnce

  it.skip 'should publish "cards-changed" event if card saving succeds', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('cards-changed', stub)
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbc-save-card-btn').click()
    expect(stub).to.has.been.calledOnce

  it.skip 'should show message to inform card was saved if card saving succeds', ->
    sinon.stub(utils, 'showMessageModal')
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbc-save-card-btn').click()
    expect(utils.showMessageModal).to.has.been.calledWith('Tus datos fueron guardados correctamente.', acceptAction: @view.hideNewCardView, context: @view)
        .and.to.has.been.calledOnce

  it.skip 'should hide ajax loading if card saving succeds', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestSaveNewCard.returns(new $.Deferred().resolveWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbc-save-card-btn').click()
    expect(utils.hideAjaxLoading).to.has.been.calledOnce

  it.skip 'should hide ajax loading if card saving fails', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestSaveNewCard.returns(new $.Deferred().rejectWith(@view).promise())
    cardData = loadValidData.call(@)

    @view.$('#wbc-save-card-btn').click()
    expect(utils.hideAjaxLoading).to.has.been.calledOnce

  getCardModelAttributes = ->
    "cardData":
        "accountNumber": "XXXXXXXXXXXX1111"
        "expirationMonth": "05"
        "expirationYear": "2015"
        "cardType": "Visa"
        "currency": "MXN"
        "firstName": "STEVE"
        "lastName": "JOBS"
        "phoneNumber": "5553259000"
    "cardAddress":
        "country": "MX"
        "postalCode": "11000"
        "state": "Distrito Federal"
        "street1": "Reforma"
        "number": "1"
        "city": "Mexico"
    "subscriptionId": "9997000101139083"
    "cardPrincipal": yes
