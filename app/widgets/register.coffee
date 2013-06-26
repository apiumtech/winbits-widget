module.exports = (app) ->
  app.initRegisterWidget = ($) ->
    $("#winbits-register-form").submit (e) ->
      e.preventDefault()
      $form = $(this)
      formData = verticalId: app.config.verticalId
      formData = app.Forms.serializeForm($, $form, formData)
      $.ajax app.config.apiUrl + "/affiliation/register.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        context: $form
        beforeSend: ->
          app.validateForm this

        headers:
          "Accept-Language": "es"

        success: (data) ->
          console.log "Request Success!"
          console.log ["data", data]
          $.fancybox.close()
          app.showRegisterConfirmation $  unless data.response.active

        error: (xhr, textStatus, errorThrown) ->
          error = JSON.parse(xhr.responseText)
          app.renderRegisterFormErrors this, error

        complete: ->
          console.log "Request Completed!"
