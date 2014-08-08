'use strict'

EditCardView = require 'views/cards/edit-card-view'
Card = require 'models/cards/card'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'EditCardViewSpec', ->

  before ->
    @xhr = sinon.useFakeXMLHttpRequest()

  after ->
    @xhr.restore()

  beforeEach ->
    @model = new Card getCardModelAttributes()
    @view = new EditCardView model: @model
    sinon.stub(@model, 'requestUpdateCard').returns(TestUtils.promises.idle)
    sinon.stub(utils, 'showAjaxLoading')
    sinon.stub(utils, 'showMessageModal')

  afterEach ->
    @view.dispose()
    @model.requestUpdateCard.restore()
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

  it 'should render card data form fields disabled', ->
    fieldNames = ['firstName', 'lastName', 'accountNumber']
    for fieldName in fieldNames
      $field = @view.$(".wbc-field-#{fieldName}")
      expect($field).to.has.$attr('disabled')

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
    expect(@.view.$('.wbc-field-accountNumber').data('card-type')).to.be.equal('visa')

  it 'should not show loading indicator if data invalid', ->
    @view.$('[name=state]').val('')
    @view.$('.wbc-save-card-btn').click()

    expect(utils.showAjaxLoading).to.not.has.been.called

  it 'should request to update card if data valid', ->
    cardData = editCardData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(@model.requestUpdateCard).to.has.been.calledWithMatch(cardData, @view)
        .and.to.be.calledOnce

  it 'should show loading indicator if data is valid', ->
    editCardData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(utils.showAjaxLoading).to.has.been.calledOnce

  it 'should publish "cards-changed" event if card update succeds', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('cards-changed', stub)
    @model.requestUpdateCard.returns(new $.Deferred().resolveWith(@view).promise())
    editCardData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(stub).to.has.been.calledOnce

  it 'should show message to inform card was update if card update succeds', ->
    @model.requestUpdateCard.returns(new $.Deferred().resolveWith(@view).promise())
    editCardData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expectedOptions = onClosed: @view.hideCardView, context: @view, icon: 'iconFont-ok'
    expect(utils.showMessageModal).to.has.been.calledWith('Tus datos se han guardado correctamente.', expectedOptions)
        .and.to.has.been.calledOnce

  it 'should hide ajax loading if card saving succeds', ->
    sinon.stub(utils, 'hideAjaxLoading')
    @model.requestUpdateCard.returns(new $.Deferred().resolveWith(@view).promise())
    editCardData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(utils.hideAjaxLoading).to.has.been.calledOnce

  it 'should hide ajax loading if card saving fails', ->
    sinon.stub(@view, 'requestUpdateCardError')
    @model.requestUpdateCard.returns(new $.Deferred().rejectWith(@view).promise())
    editCardData.call(@)

    @view.$('.wbc-save-card-btn').click()
    expect(@view.requestUpdateCardError).to.has.been.calledOnce

  getCardModelAttributes = ->
    cardData:
        accountNumber: "XXXXXXXXXXXX1111"
        expirationMonth: "05"
        expirationYear: "2015"
        cardType: "Visa"
        currency: "MXN"
        firstName: "STEVE"
        lastName: "JOBS"
        phoneNumber: "5553259000"
    cardAddress:
        country: "MX"
        postalCode: "11000"
        state: "Distrito Federal"
        street1: "Reforma"
        number: "1"
        city: "Mexico"
    subscriptionId: "9997000101139083"
    cardPrincipal: yes

  editCardData = ->
    editData =
        number: '666'
        city: 'Monterrey'
    for own fieldName, fieldValue of editData
      @view.$("[name=#{fieldName}]").val(fieldValue)
    updateData =
        cardId: "9997000101139083"
        expirationMonth: "05"
        expirationYear: "15"
        country: "MX"
        street1: "Reforma"
        state: "Distrito Federal"
        postalCode: "11000"
        phoneNumber: "5553259000"
        cardPrincipal: "true"
    $.extend(updateData, editData)
