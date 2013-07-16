config = require 'config'
util = require 'lib/util'
module.exports = ($)->
  find : (cp, element, callback) ->
    that = @
    unless cp.length is 5
      @showDefault element
      return
    $.ajax
      url: config.apiUrl + "/affiliation/locations/" + cp + ".json"
      dataType: "json"
      success: (data) ->
        that.renderData element, data
        callback()  if typeof callback is "function"


  showDefault : showDefault = (element) ->
    element.html "<option value=\"\">Ingresa un código postal</option>"
    that = @


  renderData : (element, data) ->
    if data.length > 0

      console.log "Render data"
    else
      @showDefault element
    console.log element.parent()
    element.unwrap()
    element.parent().find(".selectContent").remove()
    element.parent().find(".selectTrigger").remove()
    util.customSelect(element)

