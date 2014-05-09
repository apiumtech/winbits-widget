'use strict'

NewCardView = require 'views/cards/new-card-view'
$ = Winbits.$

describe 'NewCardViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @view = new NewCardView

  afterEach ->
    @view.dispose()
    $.fn.customSelect.restore?()
    $.fn.customCheckbox.restore?()
    $.fn.mask.restore?()

  it 'should render wrapper', ->
    expect(@view.$el).to.has.id('wbi-new-card-view')
    expect(@view.$el).to.has.$class('creditcardNew')

  it 'should be rendered', ->
    expect(@view.$('form#wbi-new-card-form')).to.existExact(1)
    expect(@view.$('#wbi-save-card-btn')).to.existExact(1)
    expect(@view.$('.wbc-cancel-btn')).to.existExact(2)
    expect(@view.$('#wbi-new-card-status-layer')).to.existExact(1)

  it 'should apply customSelect plugin when rendered', ->
    sinon.spy($.fn, 'customSelect')

    @view.render()
    expect($.fn.customSelect).to.has.been.calledOnce
    $countrySelect = $.fn.customSelect.firstCall.returnValue
    expect($countrySelect).to.has.$class('wbc-country-field')
    expect($countrySelect).to.has.$val('1')

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
