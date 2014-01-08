util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
token = {}

token.saveApiToken = (apiToken) ->
  util.setCookie config.apiTokenName, apiToken, 7
  console.log ["About to save API Token on app", apiToken]
  Winbits.rpc.saveApiToken(apiToken)

token.requestTokens = ($) ->
  console.log "Requesting tokens"
  Winbits.rpc.getTokens (response) ->
    @publishEvent 'getTokensHandler', response

token.segregateTokens = (tokensDef) ->
  console.log ["tokensDef", tokensDef]
  #console.log _.keys(tokensDef)
  vcartTokenDef = tokensDef['0'].vcartToken
  util.setCookie vcartTokenDef.cookieName, vcartTokenDef.value, vcartTokenDef.expireDays
  apiTokenDef = tokensDef["0"].apiToken
  if apiTokenDef
    util.setCookie apiTokenDef.cookieName, apiTokenDef.value, apiTokenDef.expireDays
  else
    util.deleteCookie config.apiTokenName
module.exports = token
