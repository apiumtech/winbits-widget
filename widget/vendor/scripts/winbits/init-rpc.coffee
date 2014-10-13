'use strict'

##
 # Inicialización del proxy para RPC usando easyXDM
 # User: jluis
 # Date: 25/03/14
 ##

$ = jQuery
promises = []

# Utilities functions
timeoutDeferred = (deferred, timeout = 60000) ->
  setTimeout ->
    deferred.reject() if deferred.state() isnt 'resolved'
  ,timeout
  deferred

#checkLocalStorage
hasLocalStorage= ()->
  try
    localStorage.setItem 'test', 'test'
    return true
  catch e
    return false;


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
  getData: {}
  saveApiToken: {}
  deleteApiToken: {}
  storeVirtualCart: {}
  storeVirtualCampaigns:{}
  logout: {}
  facebookStatus: {}
  facebookMe: {}
  storeUTMs: {}
  getUTMs: {}
  removeUTMs: {}

if window.wbSkipRPC
  for own key of rpcApi
    rpcApi[key] = $.noop
  Winbits.env.set('rpc', rpcApi)
else
  console.log ["Has localStorage", hasLocalStorage()]
  if(hasLocalStorage())
    localStorage.removeItem('test')
    verifyingVerticalData = new $.Deferred().done (data) ->
      console.log 'Vertical data verified :)'
      env = Winbits.env
      currentVerticalId = data.meta.currentVerticalId
      env.set 'current-vertical-id', currentVerticalId
      verticalsData = data.response
      env.set 'verticals-data', verticalsData
      result = (v for v in verticalsData when v.id is currentVerticalId)
      currentVertical = result.pop()
      env.set 'current-vertical', currentVertical
    .fail -> console.log ['ERROR', 'Unable to verify vertical data :(']
    promises.push verifyingVerticalData.promise()

    verifyVerticalData = ((deferred) ->
      ->
        apiUrl = Winbits.env.get('api-url')
        Winbits.utils.ajaxRequest "#{apiUrl}/users/verticals.json",
          data: hostname: location.hostname
        .done deferred.resolve
        .fail deferred.reject
    )(verifyingVerticalData)

    verifyingLoginData = new $.Deferred().done (data) ->
      console.log 'Login data verified :)'
      if $.isEmptyObject data.response
        localStorage.removeItem Winbits.env.get 'api-token-name'
        Winbits.env.get('rpc').deleteApiToken()
      else
        Winbits.env.set 'login-data', data.response
        Winbits.utils.saveLoginData data.response
        Winbits.trigger 'loggedin', [data.response]
    .fail -> console.log ['ERROR', 'Unable to verify login data :(']
    promises.push verifyingLoginData.promise()

    verifyLoginData = ((deferred) ->
      (apiToken) ->
        if apiToken
          apiUrl = Winbits.env.get('api-url')
          utms = Winbits.trackingUtils.getUTMParams()
          Winbits.utils.ajaxRequest  "#{apiUrl}/users/express-login.json",
            type: 'POST',
            data: JSON.stringify(apiToken: apiToken, utms: utms)
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

    getData = (->
      console.log ['has Winbits get data', Winbits]
      deferred = new $.Deferred()
      promise: deferred.promise()
      fn: ->
        Winbits.env.get('rpc').getData deferred.resolve, deferred.reject
    )()

    loadRpc().done ->
      console.log 'RPC loaded :)'
      console.log ['has Winbits variable before verifyVerticalData', Winbits]
      verifyVerticalData()
      console.log ['has Winbits variable after verifyVerticalData', Winbits]
#      getData()
    .fail ->
      console.log ['ERROR', 'Unable to load RPC engine :(']
      # This really need to happen!
      verifyingVerticalData.reject()
      verifyingLoginData.reject()

    getData.promise.done (data) ->
      console.log 'RPC data got :)'
      Winbits.env.set('virtual-cart', data.vcartToken)
      Winbits.env.set('virtual-campaigns', data.vcampaignsToken)
      Winbits.trackingUtils.cacheUTMs(data.utms)
      verifyLoginData(data.apiToken)
    .fail ->
      console.log ['ERROR', 'Unable to get RPC data :(']
      verifyingLoginData.reject() # This really need to happen!

Winbits.promises = promises
console.log 'Set up promises :)'
