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
    script = document.createElement 'script'
    script.type = 'text/javascript'
    script.src = Winbits.env.get('base-url') + '/javascripts/app.js'
    $('head').first().append(script).load deferred.resolve
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
      Winbits.ajaxRequest Winbits.env.get('api-url') + '/affiliation/verticals.json!',
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
        Winbits.ajaxRequest Winbits.env.get('api-url') + '/affiliation/express-login.json',
          type: 'POST',
          data: apiToken: apiToken
          success: deferred.resolve
          error: deferred.reject
      else
        deferred.reject(apiToken)
  )()

  loadRpc().done -> getTokens.fn()
  .fail -> console.log ['ERROR', 'Unable to load RPC engine!', arguments]

  getTokens.done (tokens)->
    apiToken = tokens['_wb_api_token']
    verifyVerticalData.fn()
    verifyLoginData.fn(apiToken)
  .fail -> console.log ['ERROR', 'Unable to get tokens!', arguments]

  loadingAppScript = loadAppScript().fail console.log ['ERROR', 'Unable to get load App script!', arguments]

  Winbits.promises =
    loadingAppScript: loadingAppScript
    verifyingLoginData: verifyingLoginData.promise
    verifyingVerticalData: verifyVerticalData.promise
)()
