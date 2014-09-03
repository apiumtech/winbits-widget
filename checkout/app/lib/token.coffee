util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
EventBroker = require 'chaplin/lib/event_broker'
token = {}

token.saveApiToken = (apiToken) ->
  util.storeKey config.apiTokenName, apiToken, 7
  console.log ["About to save API Token on app", apiToken]
  Winbits.rpc.saveApiToken(apiToken)

token.requestTokens = ($) ->
  console.log "Requesting tokens"
  Winbits.rpc.getTokens (response) ->
    EventBroker.publishEvent 'getTokensHandler', response

  utms = {}
  params = util.getUrlParams()
  utms[key] = value for key,value of params when "utm_" is key.substr 0, "utm_".length 
  util.storeKey "_wb_utm_params", JSON.stringify(utms)

  Winbits.rpc.saveUtms(utms)

token.segregateTokens = (tokensDef) ->
  console.log ["tokensDef", tokensDef]
  #console.log _.keys(tokensDef)
  vcartTokenDef = tokensDef.vcartToken
  util.storeKey vcartTokenDef.entryName, vcartTokenDef.value
  apiTokenDef = tokensDef.apiToken
  if apiTokenDef
    util.storeKey apiTokenDef.entryName, apiTokenDef.value
  else
    util.deleteKey config.apiTokenName
module.exports = token
