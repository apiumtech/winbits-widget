module.exports = (app) ->

  app.loadCompleteRegisterForm = ($, profile) ->
    console.log ["Loading profile", profile]
    if profile
      $profileForm = app.$widgetContainer.find("form#complete-register-form")
      $profileForm.find("input[name=name]").val profile.name
      $profileForm.find("input[name=lastName]").val profile.lastName
      if profile.birthdate
        birthday = profile.birthdate.split("-")
        year = birthday[0]
        year = (if year.length > 2 then year.substr(2) else year)
        $profileForm.find("input.day-input").val birthday[2]
        $profileForm.find("input.month-input").val birthday[1]
        $profileForm.find("input.year-input").val year
        $profileForm.find("input[name=birthdate]").val profile.birthdate
      $profileForm.find("input[name=gender]." + profile.gender).attr("checked", "checked").next().addClass "spanSelected"  if profile.gender

  app.checkRegisterConfirmation = ($) ->
    params = app.getUrlParams()
    apiToken = params._wb_api_token
    if apiToken
      console.log ["API token found as parameter, saving...", apiToken]
      app.saveApiToken apiToken
