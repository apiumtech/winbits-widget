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


  hasLocalStorage: hasLocalStorage = ()->
    try
      localStorage.setItem 'test', 'test'
      localStorage.removeItem('test')
      return true
    catch e
      return false;
  
  setCookie : setCookie = (c_name, value, exdays) ->
    exdays = exdays or 7
    exdate = new Date()
    exdate.setDate exdate.getDate() + exdays
    c_value = escape(value) + ((if (exdays is null) then "" else "; path=/; expires=" + exdate.toUTCString()))
    document.cookie = c_name + "=" + c_value

  getCookieByName : getCookieByName = (c_name) ->
    c_value = document.cookie
    c_start = c_value.indexOf(" " + c_name + "=")
    c_start = c_value.indexOf(c_name + "=")  if c_start is -1
    if c_start is -1
      c_value = null
    else
      c_start = c_value.indexOf("=", c_start) + 1
      c_end = c_value.indexOf(";", c_start)
      c_end = c_value.length  if c_end is -1
      c_value = unescape(c_value.substring(c_start, c_end))
    c_value

  deleteCookie : (name) ->
    document.cookie = name + "=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT"


  saveLoginData: (loginData) -> 
    try
      localStorage.setItem Winbits.env.get('api-token-name'), loginData.apiToken
    catch e  
      console.log 'No se soporta local storage, se utilizara cookies'
      Winbits.utils.setCookie( Winbits.env.get('api-token-name'), loginData.apiToken, 7 )

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
