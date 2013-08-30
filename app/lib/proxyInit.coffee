config = require 'config'
mediator = require 'chaplin/mediator'
token = require 'lib/token'
EventBroker = require 'chaplin/lib/event_broker'

module.exports = class ProxyInit
  # Mixin an EventBroker
  _(@prototype).extend EventBroker


  constructor: () ->
    #@.initialize.apply this, arguments
    console.log "ProxyInit#constructor"
    $widgetContainer = Backbone.$('#' + config.winbitsDivId)

    iframeSrc = config.baseUrl + "/winbits.html?origin=" + config.proxyUrl
    iframeStyle = "width:100%;border: 0px;overflow: hidden;"
    that = this
    $iframe = Backbone.$("<iframe id=\"winbits-iframe\" name=\"winbits-iframe\" height=\"30\" style=\"" + iframeStyle + "\" src=\"" + iframeSrc + "\"></iframe>").on("load", ->
      console.log "iframeLoaded"
      mediator.proxy = new Porthole.WindowProxy(config.baseUrl + "/proxy.html", "winbits-iframe")
      mediator.proxy.addEventListener (messageEvent) ->
        console.log ["Message from Winibits", messageEvent]
        data = messageEvent.data
        console.log "publicando evento " + data.action + "Handler"
        that.publishEvent data.action + "Handler", data.params

        #handlerFn = app.Handlers[data.action + "Handler"]
        #if handlerFn
          #handlerFn.apply this, data.params
        #else
          #console.log "Invalid action from app"

      token.requestTokens($)
    )
    $widgetContainer.find("#winbits-iframe-holder").append $iframe

    # Create a proxy window to send to and receive
    # messages from the iFrame

    # Register an event handler to receive messages;
