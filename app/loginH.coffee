module.exports = (app) ->



  app.applyLogout = ($, logoutData) ->
    app.proxy.post
      action: "logout"
      params: [app.Flags.fbConnect]

    app.deleteCookie app.apiTokenName
    app.resetWidget $
    app.Flags.loggedIn = false
    app.Flags.fbConnect = false

  app.resendConfirmLink = ($, link) ->
    $link = app.$(link)
    url = $link.attr("href")
    $.ajax url,
      dataType: "json"
      headers:
        "Accept-Language": "es"

      success: (data) ->
        console.log "resendConfirm Success!"
        console.log ["data", data]
        app.showRegisterConfirmation $

      error: (xhr, textStatus, errorThrown) ->
        error = JSON.parse(xhr.responseText)
        alert error.response.message

      complete: ->
        console.log "resendConfirm Completed!"



