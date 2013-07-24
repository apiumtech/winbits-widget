config = require 'config'
util = require 'lib/util'
module.exports = ($)->
  find : (cp, element, itemSelected, callback) ->
    that = @
    unless cp.length is 5
      #@showDefault element
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

    values = new Array()
    if data.response.length > 0
      for response in data.response
        if itemSelected and parseInt(itemSelected) is response.id
          values.push "<option selected value='#{response.id}'>#{response.locationName}</value>"
        else
          values.push "<option value='#{response.id}'>#{response.locationName}</value>"
    else
        values.push "<option value=\"\">Lo sentimos no encontramos tu codigo posta, por favor ingresa tu colonia en el campo de localidad</option>"

    $element.html(values)
    util.customSelect($element)
