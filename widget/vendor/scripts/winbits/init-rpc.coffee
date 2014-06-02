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

  Winbits.isCrapBrowser =
    Winbits.$.browser.msie and Winbits.$.browser.versionNumber < 10

  Winbits.ajaxRequest = (url, options) ->
    $ = Winbits.$
    if $.isPlainObject(url)
      options = url
      url = options.url
    defaultOptions =
      dataType: 'json'
      context: @
    defaultHeaders =
      'Accept-Language': 'es'
      'Content-Type': 'application/json'
    options = $.extend(defaultOptions, options)
    options.headers = $.extend(defaultHeaders, options.headers)
    if Winbits.isCrapBrowser
      context = options.context
      deferred = new $.Deferred()
        .done(options.success)
        .fail(options.error)
        .always(options.complete)
      unsupportedOptions = ['context', 'success', 'error', 'complete']
      delete options[property] for property in unsupportedOptions
      Winbits.env.get('rpc').request(url, options, (response) ->
        args = [response.data, response.textStatus, response.jqXHR]
        deferred.resolveWith(context, args)
      , (response) ->
        message = response.message
        args = [message.jqXHR, message.textStatus, message.errorThrown]
        deferred.rejectWith(context, args)
      )
      deferred.promise()
    else
      $.ajax(url,options)

  Winbits.saveLoginData = (loginData) ->
    localStorage.setItem Winbits.env.get('api-token-name'), loginData.apiToken
    Winbits.env.get('rpc').saveApiToken loginData.apiToken

  # Winbits promises
  loadAppScript = () ->
    deferred = new $.Deferred()
    baseUrl = Winbits.env.get('base-url')
    yepnope.injectJs  "#{baseUrl}/javascripts/app.js", deferred.resolve
    timeoutDeferred(deferred).promise()

  loadingAppScript = loadAppScript().done ->
    console.log 'App script loaded :)'
  .fail -> console.log ['ERROR', 'Unable to load App script :(']
  promises.push loadingAppScript

  rpcApi =
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

  if window.wbSkipRPC
    for own key of rpcApi
      rpcApi[key] = Winbits.$.noop
    Winbits.env.set('rpc', rpcApi)
  else
    verifyingVerticalData = new $.Deferred().done (data) ->
      console.log 'Vertical data verified :)'
      currentVerticalId = data.meta.currentVerticalId
      Winbits.env.set 'current-vertical-id', currentVerticalId
      verticalsData = data.response
      Winbits.env.set 'verticals-data', verticalsData
      result = (v for v in verticalsData when v.id is currentVerticalId)
      currentVertical = result.pop()
      Winbits.env.set 'current-vertical', currentVertical
    .fail -> console.log ['ERROR', 'Unable to verify vertical data :(']
    promises.push verifyingVerticalData.promise()

    verifyVerticalData = ((deferred) ->
      ->
        apiUrl = Winbits.env.get('api-url')
        Winbits.ajaxRequest "#{apiUrl}/users/verticals.json",
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
        Winbits.env.set 'login-data', data.response
        Winbits.saveLoginData data.response
        Winbits.trigger 'loggedin', [data.response]
    .fail -> console.log ['ERROR', 'Unable to verify login data :(']
    promises.push verifyingLoginData.promise()

    verifyLoginData = ((deferred) ->
      (apiToken) ->
        if apiToken
          apiUrl = Winbits.env.get('api-url')
          Winbits.ajaxRequest  "#{apiUrl}/users/express-login.json",
            type: 'POST',
            data: JSON.stringify(apiToken: apiToken)
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
      remote: rpcApi

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
      Winbits.env.set('virtual-cart', tokens.vcartToken)
      verifyLoginData(tokens.apiToken)
    .fail ->
      console.log ['ERROR', 'Unable to get tokens :(']
      verifyingLoginData.reject() # This really need to happen!

  Winbits.promises = promises
  console.log 'Set up promises :)'
)()
