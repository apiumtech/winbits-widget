config = require 'config'
util = require 'lib/util'
module.exports = ($)->
  find : (cp, element, callback) ->
    that = @
    unless cp.length is 5
      #@showDefault element
      return
    $.ajax
      url: config.apiUrl + "/affiliation/locations/" + cp + ".json"
      dataType: "json"
      success: (data) ->
        that.renderData element, data
        callback()  if typeof callback is "function"

  renderData : (element, data) ->
    console.log element.parent()
    element.unwrap()
    element.parent().find(".selectContent").remove()
    element.parent().find(".selectTrigger").remove()
    element.parent().find(".selectOptions").remove()

    values = new Array()
    if data.response.length > 0
      console.log "Render data"
      for response in data.response
        values.push "<option value='#{response.id}'>#{response.locationName}</value>"
    else
        values.push "<option value=\"\">Lo sentimos no encontramos tu codigo posta, por favor ingresa tu colonia en el campo de localidad</option>"

    ($ '#zipCodeInfo').html(values)

    util.customSelect(element)

