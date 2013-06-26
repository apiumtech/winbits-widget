module.exports = (app) ->

  console.log app
  #require('./initProxy')(app)
  app.initProxy = ($) ->
    require('./handlers')(app)
    require('./util')(app)
    iframeSrc = app.config.baseUrl + "/winbits.html?origin=" + app.config.proxyUrl
    iframeStyle = "width:100%;border: 0px;overflow: hidden;"
    $iframe = $("<iframe id=\"winbits-iframe\" name=\"winbits-iframe\" height=\"30\" style=\"" + iframeStyle + "\" src=\"" + iframeSrc + "\"></iframe>").on("load", ->
      unless app.initialized
        app.initialized = true
        app.init()
    )
    app.$widgetContainer.find("#winbits-iframe-holder").append $iframe

    # Create a proxy window to send to and receive
    # messages from the iFrame
    app.proxy = new Porthole.WindowProxy(app.config.baseUrl + "/proxy.html", "winbits-iframe")

    # Register an event handler to receive messages;
    app.proxy.addEventListener (messageEvent) ->
      console.log ":)"
      #console.log ["Message from Winibits", messageEvent]
      data = messageEvent.data
      handlerFn = app.Handlers[data.action + "Handler"]
      if handlerFn
        handlerFn.apply this, data.params
      else
        console.log "Invalid action from app"

  app.init = ->
    console.log "was here"
    require('./widget')(app)
    require('./messages')(app)
    $ = app.jQuery
    $(".wb-vertical-" + app.config.verticalId).addClass "current"
    app.requestTokens $
    app.initWidgets $
    app.alertErrors $
