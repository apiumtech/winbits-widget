'use strict'

$.widget 'winbits.wblocationselect',
  options:
    zipCodeInput: '[name=zipCode]'
    otherOption: 'Otra...'
    otherFieldAttrs: name: 'location'

  _create: ->
    @_createOtherOption()
    @_enhanceSelect()
    @_createOtherInput()
    @_connectZipCodeInput()
    # @_loadData()

  _createOtherOption: ->
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
    @_loadData(zipCode)

  _isValidZipCode: (zipCode = '') ->
    zipCode.length is 5

  _loadData: (zipCode) ->
    @_loadZipCode(zipCode) if @_isValidZipCode(zipCode)

  _loadZipCode: (zipCode) ->
    apiUrl = Winbits.env.get('api-url')
    $.ajax("#{apiUrl}/users/locations/#{zipCode}.json",
      type: 'json'
    )
