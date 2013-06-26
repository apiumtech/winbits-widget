module.exports = (app) ->
  require('./token')(app)
  app.Handlers =
    getTokensHandler: (tokensDef) ->
      app.segregateTokens app.jQuery, tokensDef
      app.expressLogin app.jQuery

    facebookStatusHandler: (response) ->
      console.log ["Facebook status", response]
      if response.status is "connected"
        app.Flags.fbConnect = true
        $.ajax app.config.apiUrl + "/affiliation/express-facebook-login.json",
          type: "POST"
          contentType: "application/json"
          dataType: "json"
          data: JSON.stringify(facebookId: response.authResponse.userID)
          headers:
            "Accept-Language": "es"

          xhrFields:
            withCredentials: true

          context: $
          success: (data) ->
            console.log "express-facebook-login.json Success!"
            console.log ["data", data]
            app.applyLogin $, data.response

          error: (xhr, textStatus, errorThrown) ->
            console.log "express-facebook-login.json Error!"

      else
        app.loadVirtualCart app.jQuery

    facebookLoginHandler: (response) ->
      console.log ["Facebook Login", response]
      if response.authResponse
        console.log "Requesting facebook profile..."
        app.proxy.post action: "facebookMe"
      else
        console.log "Facebook login failed!"

    facebookMeHandler: (response) ->
      console.log ["Response from winbits-facebook me", response]
      if response.email
        console.log "Trying to log with facebook"
        app.loginFacebook response

  app.EventHandlers = clickDeleteCartDetailLink: (e) ->
    $cartDetail = app.jQuery(e.target).closest("li")
    if app.Flags.loggedIn
      app.deleteUserCartDetail $cartDetail
    else
      app.deleteVirtualCartDetail $cartDetail

  app.expressLogin = ($) ->
    app.checkRegisterConfirmation $
    apiToken = app.getCookie(app.apiTokenName)
    console.log ["API Token", apiToken]
    if apiToken
      $.ajax app.config.apiUrl + "/affiliation/express-login.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(apiToken: apiToken)
        headers:
          "Accept-Language": "es"

        xhrFields:
          withCredentials: true

        context: $
        success: (data) ->
          console.log "express-login.json Success!"
          console.log ["data", data]
          app.applyLogin $, data.response

        error: (xhr, textStatus, errorThrown) ->
          console.log "express-login.json Error!"
          error = JSON.parse(xhr.responseText)
          alert error.meta.message

    else
      app.expressFacebookLogin $

  app.checkRegisterConfirmation = ($) ->
    params = app.getUrlParams()
    apiToken = params._wb_api_token
    if apiToken
      console.log ["API token found as parameter, saving...", apiToken]
      app.saveApiToken apiToken

  #  app.storeTokens(Winbits.jQuery);
  app.expressFacebookLogin = ($) ->
    console.log "Trying to login with facebook"
    app.proxy.post action: "facebookStatus"
