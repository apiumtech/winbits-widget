'use strict'

(($) ->
  $.widget 'winbits.wblocationselect',
    options:
      zipCodeInput: '[name=zipCode]'
      otherOption: 'Otra...'
      otherFieldAttrs:
        name: 'location'
        placeholder: 'Colonia/Asentamiento'
      defaultOption: 'Colonia/Asentamiento'
      showInfoFields: yes

    _zipCodeInfoKey: '_zip-code-info'

    _zipCodeRegExp: /\d{5}/

    _create: ->
      @_createDefaultOption()
      @_enhanceSelect()
      @_createOtherInput()
      @_connectZipCodeInput()
      zipCode = @$zipCodeInput.val()
      @loadZipCode(zipCode) if zipCode

    _createDefaultOption: ->
      $('<option>', value: '').text(@options.defaultOption).prependTo(@element)

    _createOtherInput: ->
      otherFieldAttrs = $.extend({}, @options.otherFieldAttrs, { type: 'text', style: 'display:none;' })
      $otherField = $('<input>', otherFieldAttrs)
      $otherField.insertAfter(@_wrapper)
      $otherField.attr('placeholder', otherFieldAttrs.placeholder).placeholder()

    _enhanceSelect: ->
      @element.customSelect()
      @_wrapper = @element.parent()
      @element.change($.proxy(@_onLocationSelectChangeHandler, @))

    _onLocationSelectChangeHandler: ->
      selectedValue = @element.val()
      @_saveZipCodeInfo(@_getZipCodeInfo(selectedValue))
      method = if selectedValue is '-1' then 'show' else 'hide'
      @_wrapper.next()[method]()

    _saveZipCodeInfo: (zipCodeInfo) ->
      @element.data(@_zipCodeInfoKey, zipCodeInfo)

    _getCurrentZipCodeInfo: ->
      @element.data(@_zipCodeInfoKey)

    _getZipCodeInfo: (id) ->
      @element.children("[value=#{id}]").data(@_zipCodeInfoKey) or {}

    _connectZipCodeInput: ->
      @$zipCodeInput = @element.closest('form').find(@options.zipCodeInput)
      if @$zipCodeInput.length
        @$zipCodeInput.on('textchange', $.proxy(@_onZipCodeInputTextChange, @))

    _onZipCodeInputTextChange: ->
      zipCode = @$zipCodeInput.val()
      @loadZipCode(zipCode)

    _isValidZipCode: (zipCode) ->
      @_zipCodeRegExp.test(zipCode)

    loadZipCode: (zipCode = '') ->
      zipCode = zipCode.toString()
      if @_isValidZipCode(zipCode)
        @$zipCodeInput.prop('disabled', yes)
        apiUrl = Winbits.env.get('api-url')
        $.ajax("#{apiUrl}/users/locations/#{zipCode}.json",
          dataType: 'json'
        ).done($.proxy(@_loadZipCodeDone, @))
        .always($.proxy(@_loadZipCodeAlways, @))
      else
        @_reset()

    _loadZipCodeDone: (data) ->
      @_loadZipCodeData(data.response)

    _loadZipCodeData: (data) ->
      if data.length
        @_loadSelectOptions(data)
        @_loadListOptions(data)
      else
        @_reset()
        @_showZipCodeNotFoundError()

    _loadSelectOptions: (data) ->
      $options = @element.children()
      $options.slice(1).remove()
      options = []
      for optionData in data
        options.push $('<option>', value: optionData.id).data(@_zipCodeInfoKey, optionData).text(optionData.locationName)
      options.push(@_createrOtherOption())
      $options.first().after(options)

    _loadListOptions: (data) ->
      $list = @_wrapper.find('ul')
      $listOptions = $list.children()
      $listOptions.slice(1).remove()
      options = []
      for optionData in data
        options.push($('<li>', rel: optionData.id).text(optionData.locationName))
      options.push(@_createrOtherListOption())
      $listOptions.first().after(options)
      @_selectListOption($list)

    _selectListOption: ($list) ->
      selectValue = @_determineSelectValue()
      if selectValue
        $list.children("li[rel=#{selectValue}]").click()
      else
        $list.children().eq(1).click()

    _determineSelectValue: () ->
      if not @element.data('_zip-code-loaded')
        @element.data('_zip-code-loaded', yes)
        @element.attr('value')

    _createrOtherOption: ->
      $('<option>', value: '-1').text(@options.otherOption)

    _createrOtherListOption: ->
      $('<li>', rel: '-1').text(@options.otherOption)

    _reset: ->
      @_cleanErrors()
      @_resetSelectOptions()
      @_resetListOptions()

    _resetSelectOptions: ->
      @element.children().slice(1).remove()

    _resetListOptions: ->
      $listOptions = @_wrapper.find('li')
      $listOptions.slice(1).remove()
      $listOptions.first().click()

    _loadZipCodeAlways: ->
      @$zipCodeInput.prop('disabled', no)

    _showZipCodeNotFoundError: ->
      name = @$zipCodeInput.attr('name')
      if @$zipCodeInput.length and name
        @$zipCodeInput.data('_zip-code-not-found-error', yes)
        @$zipCodeInput.closest('form').validate().element(@$zipCodeInput)

    value: (id) ->
      return @_getCurrentZipCodeInfo() unless id
      @_wrapper.find("li[rel=#{id}]").click()
      @element

    _cleanErrors: ->
      @$zipCodeInput.data('_zip-code-not-found-error', no)
      @$zipCodeInput.closest('form').validate().element(@$zipCodeInput)
)(jQuery)
