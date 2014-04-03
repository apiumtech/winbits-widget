##
# Inicialización de configuración de widget por parte de la vertical.
# User: jluis
# Date: 25/03/14
#
(->
  $winbitsScript = $("script[src$='winbits.js']")
  widgetContainerKey = 'widget-container'
  Winbits.env[widgetContainerKey] = $winbitsScript.data(widgetContainerKey) or 'header'
  footerContainerKey = 'footer-container'
  Winbits.env[footerContainerKey] = $winbitsScript.data(footerContainerKey) or 'footer'
  Winbits.env.vertical = id: $winbitsScript.data('vertical')

  Winbits.env = ((env)->
    get: (name) ->
      env[name]
    ,
    set: (name, value)->
      env[name]=value
      return
  )(Winbits.env)
)()
