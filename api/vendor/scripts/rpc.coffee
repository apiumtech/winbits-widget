'use strict'

API_TOKEN_KEY = '_wb_api_token'
CART_TOKEN_KEY = '_wb_cart_token'
UTM_PARAMS_KEY = '_wb_utm_params'
DEFAULT_VIRTUAL_CART = '{"cartItems":[], "bits":0}'
MILLIS_90_MINUTES = 1000 * 60 * 90

new easyXDM.Rpc({},
  local:
    request: (url, options, success, error) ->
      if options and options.context
        console.log "In RPC mode is not secure to use callbackas with context!"
        delete options.context
      config = type: "GET"
      $.extend config, options
      console.log "Ajax Request -> " + url
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

    getTokens: ->
      tokens = {}
      apiToken = localStorage.getItem API_TOKEN_KEY
      tokens.apiToken = apiToken  if apiToken
      vcartToken = localStorage.getItem CART_TOKEN_KEY
      console.log ['THE VCART', vcartToken, window.location.href]
      vcartToken = DEFAULT_VIRTUAL_CART unless vcartToken
      localStorage.setItem CART_TOKEN_KEY, vcartToken
      tokens.vcartToken = vcartToken
      console.log [
        "W: The tokens >>>"
        tokens
      ]
      tokens

    saveApiToken: (apiToken) ->
      console.log [
        "API Token from vertical"
        apiToken
      ]
      localStorage.setItem API_TOKEN_KEY, apiToken
      return

    deleteApiToken: ->
      localStorage.removeItem API_TOKEN_KEY
      return

    storeVirtualCart: (vCart) ->
      localStorage.setItem CART_TOKEN_KEY, vCart
      return

    logout: (facebookLogout) ->
      console.log "Winbits: Logging out..."
      localStorage.removeItem API_TOKEN_KEY
      localStorage.setItem CART_TOKEN_KEY, DEFAULT_VIRTUAL_CART
      console.log "Wee do not log out facebook anymore!"
      return

    facebookStatus: (success) ->
      console.log "About to call FB.getLoginStatus."
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
        console.log [
          "Facebook me response"
          response
        ]
        success response
        return

      return

    saveUtms: (utms, successFn) ->
      console.log [
        "UTMS provider"
        utms
      ]
      utms.expires = new Date().getTime() + MILLIS_90_MINUTES
      localStorage.setItem UTM_PARAMS_KEY, JSON.stringify(utmParams)
      return

    getUtms: (successFn, errorFn) ->
      console.log ["get UTMS"]
      utmsEntry = localStorage.getItem UTM_PARAMS_KEY
      if utmsEntry
        utms = JSON.parse(utmsEntry)
        expires = utms.expires ? 0
        delete utms.expires
        now = new Date().getTime()
        if expires < now
          localStorage.removeItem UTM_PARAMS_KEY
          utms = undefined
      utms

  remote:
    request: {}
    getTokens: {}
    saveApiToken: {}
    storeVirtualCart: {}
    logout: {}
    facebookStatus: {}
    facebookMe: {}
    saveUtms: {}
    getUtms: {}
)
