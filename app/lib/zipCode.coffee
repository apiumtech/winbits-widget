config = require 'config'
util = require 'lib/util'
vendor = require 'lib/vendor'

module.exports = ($)->
  find : (cp, element, itemSelected, callback) ->
    console.log 'ZIPCODE ENTRY'
    that = @
    unless (cp.length is 5)
      return

    util.ajaxRequest(
      url: config.apiUrl + "/users/locations/" + cp + ".json",
      dataType: "json"
      success: (data) ->
        that.renderData element, data, itemSelected
        callback()  if typeof callback is "function"
    )

  renderData : ($element, data, itemSelected) ->
    $element.unwrap()
    $element.parent().find(".selectContent").remove()
    $element.parent().find(".selectTrigger").remove()
    $element.parent().find(".selectOptions").remove()

    $form = $element.closest('form')
    values = new Array()
    values.push "<option value=\"\">Colonia/Asentamiento:</option>"
    if data.response.length > 0
      for response in data.response
        $option = $("<option value='#{response.id}'>#{response.locationName}</value>")
        if itemSelected and parseInt(itemSelected) is response.id
          $option.attr('selected', '')
        $option.data 'zip-code-info', response
        values.push $option
      values.push "<option value=\"-1\">Otro...</option>"

    else
      $form.find('[name=county], [name=state]').attr('readonly', '')
      $form.find('[name=location]').hide()

#    if not itemSelected and data.response.length > 0
#      response = data.response[0]
#      $form.find('#winbitsShippingCounty').val(response.county)
#      $form.find('#winbitsShippingState').val(response.state)
#      $form.find('.zipCodeInfoExtra').val(response.id)

    $element.html(values)
    $selectedOption = $element.find('option[selected]')
    if $selectedOption.length is 0
      $selectedOption = $element.children().eq(1)
      $selectedOption.attr('selected', '')
    vendor.customSelect($element)
    $element.parent().find('li[rel=' + $selectedOption.attr('value') + ']').click()

    $form.valid()
