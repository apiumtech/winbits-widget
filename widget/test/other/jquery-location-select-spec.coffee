$ = Winbits.$

describe 'jQueryLocationSelectSpec', ->

  beforeEach ->
    @$form = $ '<form><select id="select-1"></select></form>'
    @$locationSelect = @$form.find('select')

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

  it 'should add default options', ->
    @$locationSelect.wblocationselect()

    $options = @$locationSelect.find 'option'
    $listOptions = @$locationSelect.parent().find 'li'
    expectDefaultOptionsExists($options, $listOptions)

  it 'should create a hidden text field to enter location by default', ->
    @$locationSelect.wblocationselect()

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.exist
      .and.to.has.attr('type', 'text')
    expect($otherField).to.has.attr('name', 'location')
    expect($otherField).to.has.attr('style').that.match(/display:\s*none;/)
    expect($otherField.length).to.be.equal(1)

    expect($otherField.get(0).tagName).to.match(/input/i)

  it 'should allow customization by overriding default options', ->
    @$locationSelect.wblocationselect(otherOption: 'Otra Localidad...', otherFieldAttrs: { name: 'locationName' })

    $otherOption = @$locationSelect.find 'option'
    expect($otherOption).to.has.text('Otra Localidad...')

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.has.attr('name', 'locationName')

  it 'should not override type & style attributes throug "otherFieldAttrs" option', ->
    @$locationSelect.wblocationselect(otherFieldAttrs: { name: 'locationName', type: 'hidden', style: 'color:red;' })

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.has.attr('type', 'text')
    expect($otherField).to.has.attr('style').that.match(/display:\s*none;/)

  it 'should show other field when other option is selected', ->
    @$locationSelect.wblocationselect()

    @$locationSelect.parent().find('li').click()

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.has.attr('style').that.match(/display:.*?block;/)

  it 'should hide other field when other option is deselected', ->
    $('<option>', value: '5').appendTo(@$locationSelect)
    @$locationSelect.wblocationselect()
    $otherField = @$locationSelect.parent().next()
    $otherField.show()

    @$locationSelect.parent().find('li').first().click()

    expect($otherField).to.has.attr('style').that.match(/display:\s*none;/)

  it 'should connect with zipCode input if available', ->
    zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form).get(0)
    @$locationSelect.wblocationselect()

    expect($._data(zipCodeInput, 'events')).to.be.ok

  it 'should not connect with zipCode input if not available', ->
    zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form).get(0)
    @$locationSelect.wblocationselect(zipCodeInput: '.zipCode')

    zipCodeInput = @$locationSelect.closest('form').find('[name=zipCode]').get(0)
    expect($._data(zipCodeInput, 'events')).to.not.be.ok

  it 'should load zipCode if zipCode input has valid value', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode", value: '11000').appendTo(@$form)
    ajaxStub = sinon.stub($, 'ajax').returns(done: () -> always: $.noop)
    @$locationSelect.wblocationselect()

    expect(ajaxStub).to.have.been.calledOnce

  it 'should not load zipCode if zipCode input has invalid value', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode", value: '1100').appendTo(@$form)
    ajaxStub = sinon.stub($, 'ajax')
    @$locationSelect.wblocationselect()

    expect(ajaxStub).to.not.have.been.called

  it 'should load zipCode when valid zipCode is written', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    ajaxStub = sinon.stub($, 'ajax').returns(done: () -> always: $.noop)
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('11000').trigger('textchange')

    expect(ajaxStub).to.have.been.calledOnce

  it 'should not load zipCode when invalid zipCode is written', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    ajaxStub = sinon.stub($, 'ajax')
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('1100').trigger('textchange')

    expect(ajaxStub).to.not.have.been.called

  it 'should load zipCode when zip code is loaded using API', ->
    zipCodeData = [generateZipCodeInfo(), generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')]
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve(zipCodeData).promise())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', 55555)

    expect(ajaxStub).to.have.been.calledOnce

  it 'should not load zipCode when invalid zip code is loaded using API', ->
    ajaxStub = sinon.stub($, 'ajax')
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', 5555)

    expect(ajaxStub).to.not.have.been.called

  it 'should load zip code if the current loaded zip code is not the same as the new one', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    zipCodeData = [generateZipCodeInfo(), generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')]
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve(zipCodeData).promise())
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('11111').trigger('textchange')
    @$locationSelect.wblocationselect('loadZipCode', '22222')

    expect(ajaxStub).to.have.been.calledTwice

  it 'should load zip code when a valid zip code is entered after an invalid one', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    zipCodeData = [generateZipCodeInfo(), generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')]
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve(zipCodeData).promise())
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('12345').trigger('textchange')
    $zipCodeInput.val('1234').trigger('textchange')
    $zipCodeInput.val('12346').trigger('textchange')

    expect(ajaxStub).to.have.been.calledTwice

  it 'should not load zip code if the current loaded zip code is the same', ->
    zipCode = '55555'
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    zipCodeData = [generateZipCodeInfo(), generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')]
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve(zipCodeData).promise())
    @$locationSelect.wblocationselect()

    $zipCodeInput.val(zipCode).trigger('textchange')
    @$locationSelect.wblocationselect('loadZipCode', zipCode)

    expect(ajaxStub).to.have.been.calledOnce

  it 'should select first non-default option when loaded', ->
    zipCodeData = [generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes'), generateZipCodeInfo()]
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve(zipCodeData).promise())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', 55555)

    expect(@$locationSelect).to.has.value('2')

  it 'should load new options when zipCode is loaded', ->
    zipCodeData = [generateZipCodeInfo(), generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')]
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve(zipCodeData).promise())
    @$locationSelect.wblocationselect()

    @$locationSelect.wblocationselect('loadZipCode', 55555)

    $options = @$locationSelect.children()
    $listOptions = @$locationSelect.parent().find('li')
    expectDefaultOptionsExists($options, $listOptions)
    expect($options.length).to.be.equal(4)
    expect($listOptions.length).to.be.equal(4)

    expectSelectOption($options.eq(1), '1', 'Lomas Chapultepec')
    expectSelectOption($options.eq(2), '2', 'Lomas Virreyes')

    expectListOption($listOptions.eq(1), '1', 'Lomas Chapultepec')
    expectListOption($listOptions.eq(2), '2', 'Lomas Virreyes')

  it 'should reset value to "" if zip code does not exist', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve([]).promise())
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('11000').trigger('textchange')

    expect(@$locationSelect).to.has.value('')

  it 'should show error on zipCode input if zip code does not exist', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve([]).promise())
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('11000').trigger('textchange')

    $errorLabel = $zipCodeInput.next('label.error')
    expect($errorLabel).to.exist
      .and.to.has.text('El código postal no existe.')

  it 'should reset to default options if zipCode does not exist', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve([]).promise())
    $('<option>', value: '5').text('XXX').appendTo(@$locationSelect)
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('11000').trigger('textchange')

    $options = @$locationSelect.children()
    $listOptions = @$locationSelect.parent().find('li')
    expectDefaultOptionsExists($options, $listOptions)
    expect($options.length, 'More options than expected!').to.be.equal(2)
    expect($listOptions.length, 'More list options than expected!').to.be.equal(2)

  it 'should reset select value if an invalid zip code is written after a successful load', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    zipCodeData = [generateZipCodeInfo(), generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')]
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('11000').trigger('textchange')
    $zipCodeInput.val('1100').trigger('textchange')

    expect(@$locationSelect).to.has.value('')

  it 'should reset to default options when an invalid zip code is written after a successful load', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$form)
    zipCodeData = [generateZipCodeInfo(), generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')]
    @$locationSelect.wblocationselect()

    $zipCodeInput.val('11000').trigger('textchange')
    $zipCodeInput.val('1100').trigger('textchange')

    $options = @$locationSelect.children()
    $listOptions = @$locationSelect.parent().find('li')
    expectDefaultOptionsExists($options, $listOptions)
    expect($options.length, 'More options than expected!').to.be.equal(2)
    expect($listOptions.length, 'More list options than expected!').to.be.equal(2)

  it 'should disable zipCode input while loading zip code', ->
    $zipCodeInput = $('<input>', type:"text", name:"zipCode", value: '12345').appendTo(@$form)
    ajaxStub = sinon.stub($, 'ajax', ->
      new $.Deferred().done(->
        expect($zipCodeInput).to.be.disabled
      ).resolve([]).promise()
    )
    @$locationSelect.wblocationselect()

    expect($zipCodeInput).to.be.enabled

  # it 'should get current zip code info by id using value', ->
  #   currentZipCodeInfo = generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')
  #   zipCodeData = [generateZipCodeInfo(), currentZipCodeInfo]
  #   @$locationSelect.wblocationselect()

  #   @$locationSelect.wblocationselect('value', 2)

  #   expect(@$locationSelect).to.have.value('2')
  #     .and.to.have.data('_zip-code-info', currentZipCodeInfo)

  it 'should set current zip code info by id using value', ->
    currentZipCodeInfo = generateZipCodeInfo(id: 2, locationName: 'Lomas Virreyes')
    zipCodeData = [generateZipCodeInfo(), currentZipCodeInfo]
    ajaxStub = sinon.stub($, 'ajax').returns(new $.Deferred().resolve(zipCodeData).promise())
    @$locationSelect.wblocationselect()
    @$locationSelect.wblocationselect('loadZipCode', '12345')

    @$locationSelect.wblocationselect('value', 2)

    expect(@$locationSelect).to.have.value('2')
    expect(@$locationSelect.data('_zip-code-info')).to.be.equal(currentZipCodeInfo)

  expectDefaultOptionsExists = ($options, $listOptions) ->
    expectSelectOption($options.first(), '', '')
    expectSelectOption($options.last(), '-1', 'Otra...')

    expectListOption($listOptions.first(), '', '')
    expectListOption($listOptions.last(), '-1', 'Otra...')

  expectSelectOption = ($option, value, text) ->
    expect($option, 'Unexpected select option!').to.has.text(text)
      .and.to.has.attr('value', value)

  expectListOption = ($listOption, rel, text) ->
    expect($listOption, 'Unexpected list option!').to.has.text(text)
      .and.to.has.attr('rel', rel)

  generateZipCodeInfo = (data) ->
    $.extend(
      id: 1,
      locationName: 'Lomas Chapultepec',
      locationCode: '00',
      locationType: 'Colonia',
      county: 'Miguel Hidalgo',
      city: 'Miguel Hidalgo',
      state: 'DF',
      zipCode: '11000'
    , data)
