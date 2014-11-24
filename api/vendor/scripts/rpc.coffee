'use strict'

API_TOKEN_KEY = '_wb_api_token'
CART_TOKEN_KEY = '_wb_cart_token'
CAMPAIGN_TOKEN_KEY = '_wb_campaign_token'
UTM_PARAMS_KEY = '_wb_utm_params'
FIRST_ENTRY_KEY = '_wb_firts_entry'
DEFAULT_VIRTUAL_CART = '{"cartItems":[], "bits":0}'
MILLIS_90_MINUTES = 1000 * 60 * 90

getUTMsExpirationAware = ->
  utmsParams = undefined
  try
    utmsParams = localStorage.getItem UTM_PARAMS_KEY
  catch e
    utmsParams = getCookieByName(UTM_PARAMS_KEY)

  if utmsParams
    utms = JSON.parse(utmsParams)
    expires = utms.expires ? 0
    delete utms.expires
    now = new Date().getTime()
    if expires < now
      try
        localStorage.removeItem UTM_PARAMS_KEY
      catch e
        deleteCookie( UTM_PARAMS_KEY )
      utms = undefined
  utms

getCookie = () ->
  name = "local="
  ca = document.cookie.split(";")
  i = 0
  while i < ca.length
    c = ca[i]
    c = c.substring(1)  while c.charAt(0) is " "
    return c.substring(name.length, c.length)  unless c.indexOf(name) is -1
    i++
  ""

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

isLocalStorageAvailable = () ->
  Modernizr.localStorage

#checkLocalStorage
hasLocalStorage= ()->
  try
    localStorage.setItem 'test', 'test'
    localStorage.removeItem('test')
    return true
  catch e
    return false;

new easyXDM.Rpc({},
  local:
    request: (url, options, success, error) ->
      if options and options.context
        delete options.context
      config = type: "GET"
      $.extend config, options
      $.ajax(url, config).done((data, textStatus, jqXHR) ->
        if $.isFunction(success)
          response =
            data: arguments[0]
            textStatus: arguments[1]
            jqXHR: arguments[2]

          success response
        return
      ).fail ->
        if $.isFunction(error)
          response =
            jqXHR: arguments[0]
            textStatus: arguments[1]
            errorThrown: arguments[2]

          error response
        return

      return

    getData: ->
      data = {}

      if( hasLocalStorage() )
        apiToken = localStorage.getItem API_TOKEN_KEY
        data.apiToken = apiToken  if apiToken
        vcartToken = localStorage.getItem CART_TOKEN_KEY
        vcampaignsToken = localStorage.getItem CAMPAIGN_TOKEN_KEY
        vcartToken = DEFAULT_VIRTUAL_CART unless vcartToken
        localStorage.setItem CART_TOKEN_KEY, vcartToken
        data.vcartToken = vcartToken
        data.vcampaignsToken = vcampaignsToken
        data.utms = getUTMsExpirationAware()
        data.firstEntry = localStorage.getItem FIRST_ENTRY_KEY
      else
        apiToken = getCookieByName(API_TOKEN_KEY)
        data.apiToken = apiToken if apiToken
        vcartToken = getCookieByName(CART_TOKEN_KEY)
        vcampaignsToken = getCookieByName(CAMPAIGN_TOKEN_KEY)
        vcartToken = DEFAULT_VIRTUAL_CART unless vcartToken
        setCookie( CART_TOKEN_KEY, vcartToken )
        data.vcartToken = vcartToken
        data.vcampaignsToken = vcampaignsToken
        data.firstEntry = getCookieByName(FIRST_ENTRY_KEY)
        data.utms = getUTMsExpirationAware()

      data

    saveApiToken: (apiToken) ->
      if( hasLocalStorage() )
        localStorage.setItem API_TOKEN_KEY, apiToken
      else
        setCookie(API_TOKEN_KEY, apiToken, 7)
      return

    firstEntry: ->
      if( hasLocalStorage() )
        if not localStorage.getItem(FIRST_ENTRY_KEY)
          localStorage.setItem(FIRST_ENTRY_KEY, yes)
      else
        if not getCookieByName(FIRST_ENTRY_KEY)
          setCookie(FIRST_ENTRY_KEY, yes, 2)

    deleteApiToken: ->
      if( hasLocalStorage() )
        localStorage.removeItem API_TOKEN_KEY
      else
        deleteCookie(API_TOKEN_KEY)
	
      return

    storeVirtualCart: (vCart) ->
      if( hasLocalStorage() )
        localStorage.setItem CART_TOKEN_KEY, vCart
      else
        setCookie(CART_TOKEN_KEY, vCart, 7)
      return

    storeVirtualCampaigns: (vCampaigns)->
      if( hasLocalStorage() )
        localStorage.setItem CAMPAIGN_TOKEN_KEY, vCampaigns
      else
        setCookie(CAMPAIGN_TOKEN_KEY, vCampaigns, 7)
      return

    logout: (facebookLogout) ->
      if( hasLocalStorage() )
        localStorage.removeItem(API_TOKEN_KEY)
        localStorage.setItem(CART_TOKEN_KEY, DEFAULT_VIRTUAL_CART)
      else
        deleteCookie(API_TOKEN_KEY)
	setCookie(CART_TOKEN_KEY, DEFAULT_VIRTUAL_CART, 7)
      console.log "Wee do not log out facebook anymore!"

    facebookStatus: (success) ->
      FB.getLoginStatus ((response) ->
        console.log [
          "FB.getLoginStatus"
          response
        ]
        success response
        return
      ), true
      return

    facebookMe: (success) ->
      console.log "Winbits: Requesting me profile..."
      FB.api "/me", (response) ->
        success response
        return

      return

    storeUTMs: (utms, successFn) ->
      utms.expires = new Date().getTime() + MILLIS_90_MINUTES
      if( hasLocalStorage() )
        localStorage.setItem UTM_PARAMS_KEY, JSON.stringify(utms)
      else
        setCookie(UTM_PARAMS_KEY, JSON.stringify(utms), 7)
      successFn()
      return

    getUTMs: (successFn, errorFn) ->
      getUTMsExpirationAware()

    removeUTMs: (successFn, errorFn) ->
      if( hasLocalStorage() )
        localStorage.removeItem UTM_PARAMS_KEY
      else
        deleteCookie(UTM_PARAMS_KEY)

  remote:
    request: {}
    getData: {}
    saveApiToken: {}
    storeVirtualCart: {}
    storeVirtualCampaigns:{}
    logout: {}
    facebookStatus: {}
    facebookMe: {}
    storeUTMs: {}
    getUTMs: {}
    removeUTMs: {}
    firstEntry:{}
)
