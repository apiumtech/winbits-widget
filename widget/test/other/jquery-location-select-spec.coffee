$ = Winbits.$

describe 'jQueryLocationSelectSpec', ->

  beforeEach ->
    @$form = $ '<form><select id="select-1"></select><select id="select-2"></select></form>'
    @$locationSelect = @$form.find('select').first()

  afterEach ->
    $.fn.customSelect.restore?()

  it 'should be a jQuery plugin', ->
    expect($().wblocationselect).to.be.a('function')

  it 'should call customSelect plugin to create each select', ->
    customSelectSpy = sinon.spy $.fn, 'customSelect'

    $(@$form.find 'select').wblocationselect()

    expect(customSelectSpy).to.have.been.calledTwice

  it 'should add "Other" option', ->
    @$locationSelect.wblocationselect()

    $otherOption = @$locationSelect.find 'option'
    expect($otherOption).to.exist
      .and.to.has.value('-1')
      .and.to.has.text('Otra...')

    expect($otherOption.length).to.be.equal(1)

  it 'should create a hidden text field to enter location when selecting Other option', ->
    @$locationSelect.wblocationselect()

    $otherField = @$locationSelect.parent().next()
    expect($otherField).to.exist
      .and.to.has.attr('type', 'text')
    expect($otherField).to.has.attr('name', 'location')
    expect($otherField).to.has.attr('style', 'display:none;')
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
    expect($otherField).to.has.attr('style', 'display:none;')

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
    zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$locationSelect).get(0)
    @$locationSelect.wblocationselect()

    expect($._data(zipCodeInput, 'events')).to.be.ok

  it 'should not connect with zipCode input if not available', ->
    zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$locationSelect).get(0)
    @$locationSelect.wblocationselect(zipCodeInput: '.zipCode')

    zipCodeInput = @$locationSelect.closest('form').find('[name=zipCode]').get(0)
    expect($._data(zipCodeInput, 'events')).to.not.be.ok

  it 'should load zipCode when valid zipCode is written', ->
    zipCodeInput = $('<input>', type:"text", name:"zipCode").appendTo(@$locationSelect).get(0)
    ajaxStub = sinon.stub($, 'ajax')
    @$locationSelect.wblocationselect()

    @$locationSelect.closest('form').find('[name=zipCode]').val('11000').trigger('textchange')

    expect(ajaxStub).to.have.been.calledOnce
