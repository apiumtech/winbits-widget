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

  verifyingVerticalData = new $.Deferred().done ->
    console.log 'Vertical data verified :)'
  .fail -> console.log ['ERROR', 'Unable to verify vertical data :(']
  verifyVerticalData = ((deferred) ->
    ->
      Winbits.ajaxRequest Winbits.env.get('api-url') + '/users/verticals.json',
        data: hostname: location.hostname
      .done deferred.resolve
      .fail deferred.reject
  )(verifyingVerticalData)

  verifyingLoginData = new $.Deferred().done (data = {}) ->
    console.log 'Login data verified :)'
    Winbits.env.set 'login-data', data.response or  apiToken: 'XXX' #, profile:{name: 'Jorge', lastName:"Moreno", birthdate:'1988-12-11', zipCode:'11111', phone:'431256789'}, email:'a@aa.aa'
  .fail -> console.log ['WARN', 'Unable to verify login data :(']
  verifyLoginData = ((deferred) ->
    (apiToken) ->
      if apiToken
        Winbits.ajaxRequest Winbits.env.get('api-url') + '/users/express-login.json',
          type: 'POST',
          data: apiToken: apiToken
        .done deferred.resolve
        .fail deferred.reject
      else
        deferred.resolve(apiToken)
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

  Winbits.promises =
    loadingAppScript: loadingAppScript
    verifyingLoginData: verifyingLoginData.promise()
    verifyingVerticalData: verifyingVerticalData.promise()

  console.log 'Set up promises :)'
)()
