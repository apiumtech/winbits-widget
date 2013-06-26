module.exports = (app) ->


  require('./widgets/lightBox')(app)
  require('./widgets/controls')(app)
  require('./widgets/register')(app)
  require('./widgets/register')(app)
  require('./widgets/completeRegister')(app)
  require('./widgets/login')(app)
  require('./widgets/account')(app)
  require('./widgets/logout')(app)

  require('./widgets/cart')(app)
  require('./widgets/profile')(app)


  app.initWidgets = ($) ->
    app.initLightbox $
    app.initControls $
    app.initRegisterWidget $
    app.initCompleteRegisterWidget $
    app.initLoginWidget $
    app.initMyAccountWidget $
    app.initLogout $




  app.resetWidget = ($) ->
    app.$widgetContainer.find("div.miCuentaPanel").hide()
    app.$widgetContainer.find("div.login").show()
    $reseteables = app.$widgetContainer.find(".reseteable").each((i, reseteable) ->
      $reseteable = $(reseteable)
      if $reseteable.is("[data-reset-val]")
        $reseteable.val $reseteable.attr("data-reset-val")
      else if $reseteable.is("[data-reset-text]")
        $reseteable.text $reseteable.attr("data-reset-text")
      else if $reseteable.is("[data-reset-unload]")
        $reseteable.html ""
      else
        $reseteable.val ""
    )
