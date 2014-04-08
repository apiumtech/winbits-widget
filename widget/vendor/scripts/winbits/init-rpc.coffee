##
 # Inicialización del proxy para RPC usando easyXDM
 # User: jluis
 # Date: 25/03/14
 ##

(->
  Winbits.$ = $
  promises = []

  # Utilities functions
  timeoutDeferred = (deferred, timeout = 5000) ->
    setTimeout ->
      deferred.reject() if deferred.state() isnt 'resolved'
    ,timeout
    deferred

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

  Winbits.saveLoginData=(loginData) ->
    Winbits.env.set 'login-data', loginData
    localStorage.setItem Winbits.env.get('api-token-name'), loginData.apiToken
    Winbits.env.get('rpc').saveApiToken loginData.apiToken

  # Winbits promises
  loadAppScript = () ->
    deferred = new $.Deferred()
    yepnope.injectJs Winbits.env.get('base-url') + '/javascripts/app.js', deferred.resolve
    timeoutDeferred(deferred).promise()

  # loadAppScript = () ->
  #   deferred = new $.Deferred()
  #   script = document.createElement("script")
  #   script.setAttribute "type", "text/javascript"
  #   script.setAttribute "src", Winbits.env.get('base-url') + '/javascripts/app.js'
  #   if script.readyState
  #     script.onreadystatechange = -> # For old versions of IE
  #       deferred.resolve()  if @readyState is "complete" or @readyState is "loaded"
  #       return
  #   else # Other browsers
  #     script.onload = deferred.resolve
  #   (document.getElementsByTagName("head")[0] or document.documentElement).appendChild script
  #   timeoutDeferred(deferred).promise()

  loadingAppScript = loadAppScript().done ->
    console.log 'App script loaded :)'
  .fail -> console.log ['ERROR', 'Unable to load App script :(']
  promises.push loadingAppScript

  if not window.wbSkipRPC
    verifyingVerticalData = new $.Deferred().done (data) ->
      console.log 'Vertical data verified :)'
      Winbits.env.set 'current-vertical-id', data.meta.currentVerticalId
      Winbits.env.set 'verticals-data', data.response
    .fail -> console.log ['ERROR', 'Unable to verify vertical data :(']
    promises.push verifyingVerticalData.promise()

    verifyVerticalData = ((deferred) ->
      ->
        Winbits.ajaxRequest Winbits.env.get('api-url') + '/users/verticals.json',
          data: hostname: location.hostname
        .done deferred.resolve
        .fail deferred.reject
    )(verifyingVerticalData)

    verifyingLoginData = new $.Deferred().done (data) ->
      console.log 'Login data verified :)'
      if Winbits.$.isEmptyObject data.response
        localStorage.removeItem Winbits.env.get 'api-token-name'
        Winbits.env.get('rpc').deleteApiToken()
      else
        Winbits.saveLoginData data.response
    .fail -> console.log ['ERROR', 'Unable to verify login data :(']
    promises.push verifyingLoginData.promise()

    verifyLoginData = ((deferred) ->
      (apiToken) ->
        if apiToken
          Winbits.ajaxRequest Winbits.env.get('api-url') + '/users/express-login.json',
            type: 'POST',
            data: apiToken: apiToken
          .done deferred.resolve
          .fail deferred.reject
        else
          deferred.resolve {}
    )(verifyingLoginData)

    # Intermediate promises
    loadRpc = () ->
      deferred = new $.Deferred()
      Winbits.env.set 'rpc', new easyXDM.Rpc {
        remote: Winbits.env.get 'provider-url'
        onReady: deferred.resolve
      },
      remote:
        request: {}
        getTokens: {}
        saveApiToken: {}
        deleteApiToken: {}
        storeVirtualCart: {}
        logout: {}
        saveUtms: {}
        getUtms: {}
        facebookStatus: {}
        facebookMe: {}

      timeoutDeferred(deferred).promise()

    getTokens = (->
      deferred = new $.Deferred()
      promise: deferred.promise()
      fn: ->
        Winbits.env.get('rpc').getTokens deferred.resolve, deferred.reject
    )()

    loadRpc().done ->
      console.log 'RPC loaded :)'
      verifyVerticalData()
      getTokens.fn()
    .fail ->
      console.log ['ERROR', 'Unable to load RPC engine :(']
      # This really need to happen!
      verifyingVerticalData.reject()
      verifyingLoginData.reject()

    getTokens.promise.done (tokens) ->
      console.log 'Tokens got :)'
      verifyLoginData(tokens.apiToken)
    .fail ->
      console.log ['ERROR', 'Unable to get tokens :(']
      verifyingLoginData.reject() # This really need to happen!

  Winbits.promises = promises
  console.log 'Set up promises :)'
)()
