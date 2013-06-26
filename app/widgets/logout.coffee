module.exports = (app) ->
  app.initLogout = ($) ->
    $("#winbits-logout-link").click (e) ->
      e.preventDefault()
      $.ajax app.config.apiUrl + "/affiliation/logout.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"

        success: (data) ->
          console.log "logout.json Success!"
          app.applyLogout $, data.response

        error: (xhr, textStatus, errorThrown) ->
          console.log "logout.json Error!"
          error = JSON.parse(xhr.responseText)
          alert error.meta.message

        complete: ->
          console.log "logout.json Completed!"

