module.exports = (app) ->
  app.initMyAccountWidget = ($) ->
    app.$widgetContainer.find("#update-profile-form").submit (e) ->
      e.preventDefault()
      $form = $(this)
      $form.validate rules:
        birthdate:
          dateISO: true

      day = $form.find(".day-input").val()
      month = $form.find(".month-input").val()
      year = $form.find(".year-input").val()
      if day and month and year
        year = ((if year > 13 then "19" else "20")) + year
        $form.find("[name=birthdate]").val year + "-" + month + "-" + day
      formData = verticalId: app.config.verticalId
      formData = app.Forms.serializeForm($, $form, formData)
      delete formData.location  if formData.location is $form.find("[name=location]").attr("placeholder")
      formData.gender = (if formData.gender is "H" then "male" else "female")  if formData.gender
      $.ajax app.config.apiUrl + "/affiliation/profile.json",
        type: "PUT"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        context: $form
        beforeSend: ->
          app.validateForm this

        headers:
          "Accept-Language": "es"
          "WB-Api-Token": app.getCookie(Winbits.apiTokenName)

        success: (data) ->
          console.log ["Profile updated", data.response]
          $myAccountPanel = @closest(".myProfile")
          app.loadUserProfile $, data.response
          $myAccountPanel.find(".editMiPerfil").hide()
          $myAccountPanel.find(".miPerfil").show()

        error: (xhr, textStatus, errorThrown) ->
          error = JSON.parse(xhr.responseText)
          alert "Error while updating profile"

        complete: ->
          console.log "Request Completed!"


    app.$widgetContainer.find("#wb-change-password-form").submit((e) ->
      e.preventDefault()
      $form = $(this)
      formData = verticalId: app.config.verticalId
      formData = app.Forms.serializeForm($, $form, formData)
      $.ajax app.config.apiUrl + "/affiliation/change-password.json",
        type: "PUT"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(formData)
        context: $form
        beforeSend: ->
          app.validateForm this

        headers:
          "Accept-Language": "es"
          "WB-Api-Token": app.getCookie(Winbits.apiTokenName)

        success: (data) ->
          console.log ["Password change", data.response]
          @find(".editBtn").click()
          @validate().resetForm()
          @get(0).reset()

        error: (xhr, textStatus, errorThrown) ->
          error = JSON.parse(xhr.responseText)
          @find(".errors").append "<p>El password ingresado no es el actual</p>"

        complete: ->
          console.log "Request Completed!"

    ).validate()
