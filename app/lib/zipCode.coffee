config = require 'config'
util = require 'lib/util'
vendor = require 'lib/vendor'

module.exports = ($)->
  find : (cp, element, itemSelected, callback) ->
    that = @
    unless cp.length is 5
      return
    $.ajax
      url: config.apiUrl + "/affiliation/locations/" + cp + ".json"
      dataType: "json"
      success: (data) ->
        that.renderData element, data, itemSelected
        callback()  if typeof callback is "function"

  renderData : ($element, data, itemSelected) ->
    $element.unwrap()
    $element.parent().find(".selectContent").remove()
    $element.parent().find(".selectTrigger").remove()
    $element.parent().find(".selectOptions").remove()

    $form = $element.closest('form')
    values = new Array()
    if data.response.length > 0
      for response in data.response
        if itemSelected and parseInt(itemSelected) is response.id
          values.push "<option selected value='#{response.id}'>#{response.locationName}</value>"
        else
          values.push "<option value='#{response.id}'>#{response.locationName}</value>"
    else
      values.push "<option value=\"-1\">Otro...</option>"
      $form.find('[name=location], [name=county], [name=state]').removeAttr('readonly')

    if not itemSelected and data.response.length > 0
      response = data.response[0]
      $form.find('#winbitsShippingCounty').val(response.county)
      $form.find('#winbitsShippingState').val(response.state)
      $form.find('.zipCodeInfoExtra').val(response.id)

    $element.html(values)
    vendor.customSelect($element)
