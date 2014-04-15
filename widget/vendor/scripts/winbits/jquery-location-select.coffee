'use strict'

$.widget 'winbits.wblocationselect',
  options:
    zipCodeInput: '[name=zipCode]'
    otherOption: 'Otra...'
    otherFieldAttrs: name: 'location'

  _create: ->
    @_createDefaultOptions()
    @_enhanceSelect()
    @_createOtherInput()
    @_connectZipCodeInput()
    @loadZipCode(@$zipCodeInput.val())

  _createDefaultOptions: ->
    $('<option>', value: '').prependTo(@element)
    $('<option>', value: '-1').text(@options.otherOption).appendTo(@element)

  _createOtherInput: ->
    otherFieldAttrs = $.extend({}, @options.otherFieldAttrs, { type: 'text', style: 'display:none;' })
    $('<input>', otherFieldAttrs).insertAfter(@element.parent())

  _enhanceSelect: ->
    @element.customSelect()
    @element.change(@_onLocationSelectChangeHandler)

  _onLocationSelectChangeHandler: ->
    $select = $(@)
    method = if $select.val() is '-1' then 'show' else 'hide'
    $select.parent().next()[method]()

  _connectZipCodeInput: ->
    @$zipCodeInput = @element.closest('form').find(@options.zipCodeInput)
    if @$zipCodeInput.length
      @$zipCodeInput.on('textchange', $.proxy(@_onZipCodeInputTextChange, @))

  _onZipCodeInputTextChange: ->
    zipCode = @$zipCodeInput.val()
    @loadZipCode(zipCode)

  _isValidZipCode: (zipCode) ->
    zipCode.length is 5

  loadZipCode: (zipCode = '') ->
    zipCode = zipCode.toString()
    if @_isValidZipCode(zipCode)
      apiUrl = Winbits.env.get('api-url')
      $.ajax("#{apiUrl}/users/locations/#{zipCode}.json",
        type: 'json'
      ).done($.proxy(@_loadZipCodeData, @))

  _loadZipCodeData: (data) ->
    if data.length
      @_loadSelectOptions(data)
      @_loadListOptions(data)
    else
      @_resetOptions()
      @_showZipCodeNotFoundError()

  _loadSelectOptions: (data) ->
    @element.children().last().prevAll().remove()
    options = []
    for optionData in data
      options.push $('<option>', value: optionData.id).text(optionData.locationName)
    @element.prepend(options)

  _loadListOptions: (data) ->
    $list = @element.parent().find('ul')
    $list.children().last().prevAll().remove()
    options = []
    for optionData in data
      options.push $('<li>', rel: optionData.id).text(optionData.locationName)
    $list.prepend(options)
    $list.children().first().click()

  _resetOptions: ->
    @_resetSelectOptions()
    @_resetListOptions()

  _resetSelectOptions: ->
    @element.children().slice(1, -1).remove()

  _resetListOptions: ->
    $listOptions = @element.parent().find('li')
    $listOptions.slice(1, -1).remove()
    $listOptions.first().click()

  _showZipCodeNotFoundError: ->
    name = @$zipCodeInput.attr('name')
    if @$zipCodeInput.length and name
      # @$zipCodeInput.closest('form').validate().showErrors
      #   "#{name}": 'El código postal no existe.'
      $('<label>', class: 'error').text('El código postal no existe.').insertAfter(@$zipCodeInput)
