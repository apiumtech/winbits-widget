config = require 'config'
module.exports = ($)->
  find : (cp, element, idCp, callback) ->
    unless cp.length is 5
      zipCode.showDefault element
      return
    $.ajax
      url: config.urlPostalCode + cp
      dataType: "json"
      success: (data) ->
        zipCode.renderData element, data, idCp
        callback()  if typeof callback is "function"


  showDefault : showDefault = (element) ->
    element.html "<option value=\"\">Ingresa un código postal</option>"
    element.selectmenu
      width: 250
      menuWidth: 300
      format: addressShippingFormatting

    $("#codigo_fail").html "<label for=\"zipCodeInfoSearch\" class=\"error\">Codigo postal no existe.</label>"

  renderData : (element, data, idCp) ->
    if data.length > 0
      $("#error_cp").html ""
      if data.length > 1
        detail = ""
        detail = detail + "<option value=\"\">Selecciona tu localidad</option>"
        $.each data, (index, item) ->
          detail = detail + "<option value=\"" + item.id + "\">" + item.locationType + " " + item.locationName + " |" + item.city + " C.P. " + item.zipcode + " |" + item.county + ", " + item.state + "</option>"

      else
        detail = ""
        detail = detail + "<option value=\"\">Selecciona tu localidad</option>"
        detail = detail + "<option value=\"" + data[0].id + "\">" + data[0].locationType + " " + data[0].locationName + " |" + data[0].city + " C.P. " + data[0].zipcode + " |" + data[0].county + ", " + data[0].state + "</option>"
      element.html detail
      unless idCp is `undefined`
        element.find("option").each ->
          se = $(this)
          se.attr "selected", "selected"  if se.val() is idCp

      element.selectmenu
        width: 250
        menuWidth: 300
        format: addressShippingFormatting

    else
      zipCode.showDefault element

  addressShippingFormatting : (text) ->
    data = text.split("|")
    fmt = ""
    if data.length is 3
      fmt = "<span class=\"ui-selectmenu-item-header\">" + data[0] + "</span>"
      fmt = fmt + "<span class=\"ui-selectmenu-item-content\">" + data[1] + "</span>"
      fmt = fmt + "<span class=\"ui-selectmenu-item-footer\">" + data[2] + "</span>"
    else
      fmt = "<span class=\"ui-selectmenu-item-header\">" + text + "</span>"
    fmt
