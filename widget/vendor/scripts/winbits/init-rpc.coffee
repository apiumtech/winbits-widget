##
 # Inicialización del proxy para RPC usando easyXDM
 # User: jluis
 # Date: 25/03/14
 # Winbits.loadScript(baseUrl + "/javascripts/app.js", function() {
 #      delete Winbits.env.set;
 #      require('initialize');
 #      Winbits.trigger('initialized');
 #    });
 ##

(->
  Winbits.$ = $

  loadAppScript = ->
    deferred = new $.Deferred()
    script = document.createElement("script")
    loaded = undefined
    script.setAttribute "type", "text/javascript"
    script.setAttribute "src", Winbits.env.get('base-url') + '/javascripts/app.js'
    if script.readyState
      script.onreadystatechange = -> # For old versions of IE
        deferred.resolve()  if @readyState is "complete" or @readyState is "loaded"
        return
    else # Other browsers
      script.onload = deferred.resolve
    (document.getElementsByTagName("head")[0] or document.documentElement).appendChild script
    deferred.promise()

  loadRpc = ->
    deferred = new $.Deferred()
    Winbits.env.set 'rpc', new easyXDM.Rpc {
      remote: Winbits.env.get 'provider-url'
      onReady: deferred.resolve
    },
    remote:
      request: {}
      getTokens: {}
      saveApiToken: {}
      storeVirtualCart: {}
      logout: {}
      saveUtms: {}
      getUtms: {}
      facebookStatus: {}
      facebookMe: {}

    deferred.promise()

  Winbits.ajaxRequest = (url, options) ->
    $ = Winbits.$
    if $.isPlainObject(url)
      options = url
      url = options.url
    options = options or {}
    if ($.browser.msie and not /10.*/.test($.browser.version))
      context = options.context or @
      deferred = new $.Deferred()
      deferred.then ->
        options.success.apply(context, arguments) if $.isFunction options.success
        options.complete.call(context) if $.isFunction options.complete
      , ->
        options.error.apply(context, arguments) if $.isFunction options.error
        options.complete.call(context) if $.isFunction options.complete
      Winbits.env('rpc').request url, options, deferred.resolve, deferred.reject
      deferred.promise()
    else
      $.ajax(url,options)

  verifyVerticalData = (->
    deferred = new $.Deferred()
    promise: deferred.promise()
    fn: ->
      Winbits.ajaxRequest Winbits.env.get('api-url') + '/users/verticals.json',
        data: hostname: location.hostname
        success: deferred.resolve
        error: deferred.reject
  )()

  getTokens = (->
    deferred = new $.Deferred()
    promise: deferred.promise()
    fn: ->
      Winbits.env.get('rpc').getTokens deferred.resolve, deferred.reject
  )()

  verifyLoginData = (->
    deferred = new $.Deferred()
    promise: deferred.promise()
    fn: (apiToken) ->
      if apiToken
        Winbits.ajaxRequest Winbits.env.get('api-url') + '/users/express-login.json',
          type: 'POST',
          data: apiToken: apiToken
          success: deferred.resolve
          error: deferred.reject
      else
        deferred.resolve(apiToken)
  )()

  loadRpc().done ->
    verifyVerticalData.fn()
    getTokens.fn()
  .fail -> console.log ['ERROR', 'Unable to load RPC engine :(', arguments]

  getTokens.promise.done (tokens)->
    verifyLoginData.fn(tokens.apiToken)
  .fail -> console.log ['ERROR', 'Unable to get tokens :(', arguments]

  verifyingVerticalData = verifyVerticalData.promise.done ->
    console.log 'Vertical data verified :)'
  .fail -> console.log ['ERROR', 'Unable to verify vertical data :(', arguments]

  verifyingLoginData = verifyLoginData.promise.done ->
    console.log 'Login data verified :)'
  .fail -> console.log ['WARN', 'Unable to verify login data :(', arguments]

  loadingAppScript = loadAppScript().done ->
    console.log 'App script loaded :)'
  .fail -> console.log ['ERROR', 'Unable to load App script :(', arguments]

  Winbits.promises =
    loadingAppScript: loadingAppScript
    verifyingLoginData: verifyLoginData.promise
    verifyingVerticalData: verifyVerticalData.promise
)()
