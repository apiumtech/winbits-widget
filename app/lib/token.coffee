util = require 'lib/util'
config = require 'config'
mediator = require 'chaplin/mediator'
token = {}

token.saveApiToken = (apiToken) ->
  util.setCookie config.apiTokenName, apiToken, 7
  console.log ["About to save API Token on app", apiToken]
  mediator.proxy.post
    action: "saveApiToken"
    params: [apiToken]

token.requestTokens = ($) ->
  console.log "Requesting tokens"
  mediator.proxy.post action: "getTokens"

token.segregateTokens = (tokensDef) ->
  console.log ["tokensDef", tokensDef]
  #console.log _.keys(tokensDef)
  vcartTokenDef = tokensDef['0'].vcartToken
  console.log vcartTokenDef
  util.setCookie vcartTokenDef.cookieName, vcartTokenDef.value, vcartTokenDef.expireDays
  apiTokenDef = tokensDef["0"].apiToken
  if apiTokenDef
    util.setCookie apiTokenDef.cookieName, apiTokenDef.value, apiTokenDef.expireDays
  else
    util.deleteCookie config.apiTokenName
module.exports = token