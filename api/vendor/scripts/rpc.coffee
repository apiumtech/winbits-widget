'use strict'

API_TOKEN_KEY = '_wb_api_token'
CART_TOKEN_KEY = '_wb_cart_token'
CAMPAIGN_TOKEN_KEY = '_wb_campaign_token'
UTM_PARAMS_KEY = '_wb_utm_params'
DEFAULT_VIRTUAL_CART = '{"cartItems":[], "bits":0}'
MILLIS_90_MINUTES = 1000 * 60 * 90

getUTMsExpirationAware = ->
  utmsParams = localStorage.getItem UTM_PARAMS_KEY
  if utmsParams
    utms = JSON.parse(utmsParams)
    expires = utms.expires ? 0
    delete utms.expires
    now = new Date().getTime()
    if expires < now
      localStorage.removeItem UTM_PARAMS_KEY
      utms = undefined
  utms

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

    getData: ->
      data = {}
      apiToken = localStorage.getItem API_TOKEN_KEY
      data.apiToken = apiToken  if apiToken
      vcartToken = localStorage.getItem CART_TOKEN_KEY
      vcampaignsToken = localStorage.getItem CAMPAIGN_TOKEN_KEY
      console.log ['THE VCART', vcartToken, window.location.href]
      vcartToken = DEFAULT_VIRTUAL_CART unless vcartToken
      localStorage.setItem CART_TOKEN_KEY, vcartToken
      data.vcartToken = vcartToken
      data.vcampaignsToken = vcampaignsToken
      data.utms = getUTMsExpirationAware()
      console.log ["W: The tokens >>>",data]
      return data

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

    storeVirtualCampaigns: (vCampaigns)->
      localStorage.setItem CAMPAIGN_TOKEN_KEY, vCampaigns
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

    storeUTMs: (utms, successFn) ->
      utms.expires = new Date().getTime() + MILLIS_90_MINUTES
      console.log [
        "Storing UTMS"
        utms
      ]
      localStorage.setItem UTM_PARAMS_KEY, JSON.stringify(utms)
      successFn()
      return

    getUTMs: (successFn, errorFn) ->
      console.log ["Getting UTMS"]
      getUTMsExpirationAware()

    removeUTMs: (successFn, errorFn) ->
      console.log ["Removing UTMS"]
      localStorage.removeItem UTM_PARAMS_KEY

  remote:
    request: {}
    getData: {}
    saveApiToken: {}
    storeVirtualCart: {}
    logout: {}
    facebookStatus: {}
    facebookMe: {}
    storeUTMs: {}
    getUTMs: {}
    removeUTMs: {}
)
