module.exports = (app) ->

  app.saveApiToken = (apiToken) ->
    app.setCookie app.apiTokenName, apiToken, 7
    console.log ["About to save API Token on app", apiToken]
    app.proxy.post
      action: "saveApiToken"
      params: [apiToken]

  app.requestTokens = ($) ->
    console.log "Requesting tokens"
    app.proxy.post action: "getTokens"

  app.segregateTokens = ($, tokensDef) ->
    console.log ["tokensDef", tokensDef]
    vcartTokenDef = tokensDef.vcartToken
    app.setCookie vcartTokenDef.cookieName, vcartTokenDef.value, vcartTokenDef.expireDays
    apiTokenDef = tokensDef.apiToken
    if apiTokenDef
      app.setCookie apiTokenDef.cookieName, apiTokenDef.value, apiTokenDef.expireDays
    else
      app.deleteCookie app.apiTokenName
