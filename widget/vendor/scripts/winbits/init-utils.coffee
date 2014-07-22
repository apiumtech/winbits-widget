'use strict'

Winbits.$ = jQuery

Winbits.isCrapBrowser =
  Winbits.$.browser.msie and Winbits.$.browser.versionNumber < 10

# To make test pass on IE9
if window.wbTestEnv and Winbits.isCrapBrowser
  Winbits.isCrapBrowser = no
  Winbits.env.set('api-url', '')

Winbits.utils =
  ajaxRequest: (url, options) ->
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

  saveLoginData: (loginData) ->
    localStorage.setItem Winbits.env.get('api-token-name'), loginData.apiToken
    Winbits.env.get('rpc').saveApiToken loginData.apiToken

  getURLParams: (queryString = window.location.search.substring(1)) ->
    parameters = {}
    params = queryString.split('&')
    i = 0

    while i < params.length
      param = params[i]
      if param
        attribute = params[i].split('=')
        name = attribute[0]
        value = attribute[1]
        parameters[name] = value
      i++
    parameters
