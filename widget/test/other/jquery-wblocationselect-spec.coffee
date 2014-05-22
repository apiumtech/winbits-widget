testUtils = require 'test/lib/test-utils'
$ = Winbits.$

describe 'jQueryWbLocationSelectSpec', ->

  DISPLAY_NONE_REGEXP = /display:\s*none;/
  PROMISE_RESOLVED_WITHOUT_DATA = new $.Deferred()
    .resolve(response: []).promise()

  beforeEach ->
    @$form = $('<form></form>')
      .append('<input type="text" name="zipCode"><select></select>')
    @$form.validate
      ignore: []
      rules:
        zipCode: zipCodeDoesNotExist: true
    @$locationSelect = @$form.find('select')
    @$zipCodeInput = @$form.find('input')

  afterEach ->
    $.fn.customSelect.restore?()
    $.ajax.restore?()

  it 'should be a jQuery plugin', ->
    expect($().wblocationselect).to.be.a('function')

  it 'should call customSelect plugin to create each select', ->
    $('<select>', id: "select-2").appendTo(@$form)
    customSelectSpy = sinon.spy $.fn, 'customSelect'

    $(@$form.find 'select').wblocationselect()

    expect(customSelectSpy).to.have.been.calledTwice

  it 'should add default option by default', ->
    @$locationSelect.wblocationselect()

    $options = @$locationSelect.find 'option'
    $listOptions = @$locationSelect.parent().find 'li'
    expectDefaultOptionExist.call(@)

    expect($options).to.have.property('length', 1)
    expect($listOptions).to.have.property('length', 1)

  it 'should default options have not zip code info in data', ->
    @$locationSelect.wblocationselect()

    $options = @$locationSelect.find 'option'
    expect($options.first().data('_zip-code-info')).to.not.be.ok

  it 'should create a hidden text field to enter location by default', ->
    @$locationSelect.wblocationselect()

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.exist
      .and.to.has.attr('type', 'text')
    expect($otherField).to.has.attr('name', 'location')
    expect($otherField).to.has.attr('style').that.match(DISPLAY_NONE_REGEXP)
    expect($otherField.length).to.be.equal(1)

    expect($otherField.get(0).tagName).to.match(/input/i)

  it 'should allow customize other option & field', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    options =
      otherOption: 'Otra Localidad...'
      otherFieldAttrs: { name: 'locationName' }
    @$locationSelect.wblocationselect(options)

    @$locationSelect.wblocationselect('loadZipCode', '12345')
    @$locationSelect.parent().find('li[rel=-1]').click()

    $otherOption = @$locationSelect.find('option').last()
    expect($otherOption).to.has.text('Otra Localidad...')

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.has.attr('name', 'locationName')

  it 'should allow customize default option', ->
    @$locationSelect.wblocationselect(defaultOption: 'Colonia')

    $otherOption = @$locationSelect.find('option').first()
    expect($otherOption).to.has.text('Colonia')

  it 'should not override type & style attributes throug "otherFieldAttrs" option', ->
    attrs = name: 'locationName', type: 'hidden', style: 'color:red;'
    @$locationSelect.wblocationselect(otherFieldAttrs: attrs)

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.has.attr('type', 'text')
    expect($otherField).to.has.attr('style').that.match(DISPLAY_NONE_REGEXP)

  it 'should show other field when other option is selected', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')
    @$locationSelect.parent().find('li[rel=-1]').click()

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.be.displayed

  it 'should hide other field when other option is deselected', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')
    $otherField = @$locationSelect.parent().next()
    $otherField.show()
    @$locationSelect.parent().find('li').first().click()

    expect($otherField).to.has.attr('style').that.match(DISPLAY_NONE_REGEXP)

  it 'should connect with zipCode input if available', ->
    zipCodeInput = @$zipCodeInput.get(0)
    @$locationSelect.wblocationselect()

    expect($._data(zipCodeInput, 'events')).to.be.ok

  it 'should not connect with zipCode input if not available', ->
    zipCodeInput = @$zipCodeInput.get(0)
    @$locationSelect.wblocationselect(zipCodeInput: '.zipCode')

    zipCodeInput = @$locationSelect.closest('form')
      .find('[name=zipCode]').get(0)
    expect($._data(zipCodeInput, 'events')).to.not.be.ok

  it 'should load zipCode if zipCode input has valid value', ->
    @$zipCodeInput.val('11000')
    ajaxStub = sinon.stub($, 'ajax').returns(done: () -> always: $.noop)
    @$locationSelect.wblocationselect()

    expect(ajaxStub).to.have.been.calledOnce

  it 'should not load zipCode if zipCode input has invalid value', ->
    @$zipCodeInput.val('1100')
    ajaxStub = sinon.stub($, 'ajax')
    @$locationSelect.wblocationselect()

    expect(ajaxStub).to.not.have.been.called

  it 'should load zipCode when valid zipCode is written', ->
    $zipCodeInput = @$zipCodeInput
    ajaxStub = sinon.stub($, 'ajax').returns(done: () -> always: $.noop)
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('11000').trigger('textchange')

    expect(ajaxStub).to.have.been.calledOnce

  it 'should not load zipCode when invalid zipCode is written', ->
    ajaxStub = sinon.stub($, 'ajax')
    @$locationSelect.wblocationselect()

    @$zipCodeInput.val('1100').trigger('textchange')

    expect(ajaxStub).to.not.have.been.called

  it 'should load zipCode when zip code is loaded using API', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')

    expect(ajaxStub).to.have.been.calledOnce

  it 'should not load zipCode when invalid zip code is loaded using API', ->
    ajaxStub = sinon.stub($, 'ajax')
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '1234')

    expect(ajaxStub).to.not.have.been.called

  it 'should load zip code if the current loaded zip code is not the same as the new one', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$zipCodeInput.val('54321').trigger('textchange')
    @$locationSelect.wblocationselect('loadZipCode', '22222')

    expect(ajaxStub).to.have.been.calledTwice

  it 'should load zip code when a valid zip code is entered after an invalid one', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$zipCodeInput.val('12345').trigger('textchange')
    @$zipCodeInput.val('1234').trigger('textchange')
    @$zipCodeInput.val('12346').trigger('textchange')

    expect(ajaxStub).to.have.been.calledTwice

  it 'should select first non-default option when loaded', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')

    expect(@$locationSelect).to.has.value('1')

  it 'should add other option when zipCode is loaded', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')

    expectOtherOptionExist.call(@)

  it 'should load new options when zipCode is loaded', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')

    $options = @$locationSelect.children()
    $listOptions = @$locationSelect.parent().find('li')
    expectDefaultOptionExist.call(@)
    expect($options.length).to.be.equal(4)
    expect($listOptions.length).to.be.equal(4)

    expectSelectOption($options.eq(1), '1', 'Lomas Chapultepec')
    expectSelectOption($options.eq(2), '2', 'Lomas Virreyes')

    expectListOption($listOptions.eq(1), '1', 'Lomas Chapultepec')
    expectListOption($listOptions.eq(2), '2', 'Lomas Virreyes')

  it 'should reset value to "" if zip code does not exist', ->
    ajaxStub = sinon.stub($, 'ajax').returns(PROMISE_RESOLVED_WITHOUT_DATA)
    @$locationSelect.wblocationselect()

    @$zipCodeInput.val('11000').trigger('textchange')

    expect(@$locationSelect).to.has.value('')

  it 'should show error on zipCode input if zip code does not exist', ->
    ajaxStub = sinon.stub($, 'ajax').returns(PROMISE_RESOLVED_WITHOUT_DATA)
    @$locationSelect.wblocationselect()

    @$zipCodeInput.val('11000').trigger('textchange')

    $error = @$form.find('label.error')
    expect($error).to.exist
        .and.to.has.text('El código postal no existe.')
        .and.to.has.property('length', 1)
    expect(@$zipCodeInput).to.has.class('error')

  it 'should reset to default option if zipCode does not exist', ->
    ajaxStub = sinon.stub($, 'ajax').returns(PROMISE_RESOLVED_WITHOUT_DATA)
    $('<option>', value: '5').text('XXX').appendTo(@$locationSelect)
    @$locationSelect.wblocationselect()

    @$zipCodeInput.val('11000').trigger('textchange')

    expectOptionsAreResetToDefault.call(@)

  it 'should reset select value if an invalid zip code is written after a successful load', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$zipCodeInput.val('11000').trigger('textchange')
    @$zipCodeInput.val('1100').trigger('textchange')

    expect(@$locationSelect).to.has.value('')

  it 'should reset to default option when an invalid zip code is written after a successful load', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$zipCodeInput.val('11000').trigger('textchange')
    @$zipCodeInput.val('1100').trigger('textchange')

    expectOptionsAreResetToDefault.call(@)

  it 'should disable zipCode input while loading zip code', ->
    $zipCodeInput = @$zipCodeInput.val('12345')
    ajaxStub = sinon.stub($, 'ajax', ->
      new $.Deferred().done(->
        expect($zipCodeInput).to.be.disabled
      ).resolve(response: []).promise()
    )
    @$locationSelect.wblocationselect()

    expect(@$zipCodeInput).to.be.enabled

  it 'should set current zip code info by id using value', ->
    currentZipCodeInfo = testUtils
      .generateZipCodeInfo(id: 3, locationName: 'Polanco')
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData(currentZipCodeInfo))
    @$locationSelect.wblocationselect()
    @$locationSelect.wblocationselect('loadZipCode', '12345')

    @$locationSelect.wblocationselect('value', currentZipCodeInfo.id)

    expect(@$locationSelect).to.have.value(currentZipCodeInfo.id.toString())
    expect(@$locationSelect.data('_zip-code-info'))
      .to.be.eql(currentZipCodeInfo)

  it 'should get current zip code info by id using value', ->
    currentZipCodeInfo = testUtils
      .generateZipCodeInfo(id: 5, locationName: 'Condesa')
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData(currentZipCodeInfo))
    @$locationSelect.wblocationselect()
    @$locationSelect.wblocationselect('loadZipCode', '12345')

    @$locationSelect.wblocationselect('value', currentZipCodeInfo.id)

    expect(@$locationSelect.wblocationselect('value'))
      .to.be.eql(currentZipCodeInfo)

  it 'should value return empty object after being resetted', ->
    ajaxStub = sinon.stub($, 'ajax')
        .onFirstCall().returns(testUtils.promiseResolvedWithData())
        .onSecondCall().returns(PROMISE_RESOLVED_WITHOUT_DATA)
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')
    @$locationSelect.wblocationselect('loadZipCode', '1234')

    expect(@$locationSelect.wblocationselect('value')).to.be.eql({})

  it 'should value return empty object if default option selected', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')
    @$form.find('li').last().click()

    expect(@$locationSelect.wblocationselect('value')).to.be.eql({})

  it 'should not reset options if other option selected', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')
    @$form.find('li').last().click()

    expectOptionsAreNotReset.call(@)

  it 'should not reset options if blank option selected', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')
    @$form.find('li').first().click()

    expectOptionsAreNotReset.call(@)

  it 'should clean zip code not found error before load another code', ->
    ajaxStub = sinon.stub($, 'ajax').returns(PROMISE_RESOLVED_WITHOUT_DATA)
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', '12345')
    @$locationSelect.wblocationselect('loadZipCode', '67890')

    $error = @$form.find('label.error')
    expect($error).to.exist
    expect($error.length).to.be.equal(1)
    expect(@$zipCodeInput).to.has.class('error')

  it 'should not make request if not well formed zipCode is loaded', ->
    ajaxStub = sinon.stub($, 'ajax')
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', 'ABCDE')

    expect(ajaxStub).to.not.have.been.called

  it 'should select attr value on first zip code load', ->
    zipCodeInfo = testUtils.generateZipCodeInfo(id: 3, locationName: 'Polanco')
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData(zipCodeInfo))
    @$locationSelect.attr('value', zipCodeInfo.id)

    @$locationSelect.wblocationselect()
    @$locationSelect.wblocationselect('loadZipCode', '12345')

    expect(@$locationSelect).to.have.value(zipCodeInfo.id.toString())
    expect(@$locationSelect.data('_zip-code-info')).to.be.eql(zipCodeInfo)

  it 'should load data location if provided', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())
    @$locationSelect.attr('value', '')
    @$locationSelect.attr('data-location', 'Condesa')

    @$locationSelect.wblocationselect()
    @$locationSelect.wblocationselect('loadZipCode', '12345')

    expect(@$locationSelect).to.have.value('-1')

    $locationField = @$locationSelect.parent().next()
    expect($locationField).to.has.value('Condesa')
    expect($locationField).to.be.displayed

  it 'should expose a function to get first value', ->
    ajaxStub = sinon.stub($, 'ajax')
      .returns(testUtils.promiseResolvedWithData())

    @$locationSelect.wblocationselect()
    @$locationSelect.wblocationselect('loadZipCode', '12345')

    firstValue = @$locationSelect.wblocationselect('firstValue')
    expect(firstValue).to.be.ok
    expect(firstValue.id).to.be.equal(1)

  expectDefaultOptionExist = () ->
    value = ''
    text = 'Colonia/Asentamiento'
    $defaultOption = @$locationSelect.children("option[value='#{value}']")
    $defaultListOption = @$locationSelect.parent().find("li[rel='#{value}']")
    expect($defaultOption, 'Expect just 1 default option to exist!')
      .to.has.property('length', 1)
    expectSelectOption($defaultOption, value, text)
    expect($defaultListOption, 'Expect just 1 default list option to exist!')
      .to.has.property('length', 1)
    expectListOption($defaultListOption, value, text)

  expectOtherOptionExist = () ->
    value = '-1'
    text = 'Otra...'
    $otherOption = @$locationSelect.children("option[value='#{value}']")
    $otherListOption = @$locationSelect.parent().find("li[rel='#{value}']")
    expect($otherOption, 'Expect just 1 other option exist!')
      .to.has.property('length', 1)
    expectSelectOption($otherOption, value, text)
    expect($otherListOption, 'Expect just 1 other list option exist!')
      .to.has.property('length', 1)
    expectListOption($otherListOption, value, text)

  expectSelectOption = ($option, value, text) ->
    expect($option, 'Unexpected select option!').to.has.text(text)
      .and.to.has.attr('value', value)

  expectListOption = ($listOption, rel, text) ->
    expect($listOption, 'Unexpected list option!').to.has.text(text)
      .and.to.has.attr('rel', rel)

  expectOptionsAreResetToDefault = ->
    $options = @$locationSelect.children()
    $listOptions = @$locationSelect.parent().find('li')
    expect($options, 'Expected just 1 option!')
      .to.has.property('length', 1)
    expect($listOptions, 'Expected just 1 list option!')
      .to.has.property('length', 1)
    expectDefaultOptionExist.call(@)

  expectOptionsAreNotReset = ->
    $options = @$locationSelect.children()
    $listOptions = @$form.find('li')
    expectDefaultOptionExist.call(@)
    expectOtherOptionExist.call(@)
    expect($options.length, 'Unexpected number of select options!')
      .to.be.equal(4)
    expect($listOptions.length, 'Unexpected number of list options!')
      .to.be.equal(4)
