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
  Winbits.env['optimized'] = $winbitsScript.data('optimized') is 'yes'

  Winbits.env = ((env)->
    get: (name) ->
      env[name]
    ,
    set: (name, value)->
      env[name]=value
      return
  )(Winbits.env)

  Winbits.log = console.log

  console.log = ->
    if Winbits.debug
      args = arguments
      args = (arg for arg in args)
      args = if args.length > 0 then args.join() else args[0]
      Winbits.log(args)
)()
