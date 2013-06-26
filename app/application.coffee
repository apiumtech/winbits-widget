Winbits = Winbits or {}
Winbits.extraScriptLoaded = false
Winbits.facebookLoaded = false
console.log Winbits.config

Winbits.apiTokenName = "_wb_api_token"
Winbits.vcartTokenName = "_wb_vcart_token"
Winbits.Flags =
  loggedIn: false
  fbConnect: false

Winbits.jQuery
require('./config')(Winbits)
require('./initProxy')(Winbits)
main = ->
  Winbits.jQuery.extend Winbits.config, Winbits.userConfig or {}
  #$head = Winbits.jQuery("head")
  #styles = [Winbits.config.baseUrl + "/include/css/style.css"]

  Winbits._readyInterval = window.setInterval(->

      #      Winbits._readyRetries = Winbits._readyRetries + 1;
      winbitsReady()
    , 50)


winbitsReady = ->
  $widgetContainer = Winbits.jQuery("#" + Winbits.config.winbitsDivId)
  if $widgetContainer.length > 0
    window.clearInterval Winbits._readyInterval
    $ = Winbits.jQuery
    Winbits.$widgetContainer = $widgetContainer.first()
    Winbits.$widgetContainer.load Winbits.config.baseUrl + "/widget.html", ->
      Winbits.initProxy $

Application = initialize: ->
  #Object.freeze this  if typeof Object.freeze is "function"
  console.log "initialize yeah"
  Winbits.jQuery = window.jQuery
  main()



module.exports = Application
