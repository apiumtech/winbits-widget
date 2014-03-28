##
# Inicialización de configuración de widget por parte de la vertical.
# User: jluis
# Date: 25/03/14
#
(->
  $winbitsScript = $("script[src$='winbits.js']")
  widgetContainerKey = 'widget-container'
  Winbits.env.set(widgetContainerKey, $winbitsScript.data(widgetContainerKey) or 'header')
  footerContainerKey = 'footer-container'
  Winbits.env.set(footerContainerKey, $winbitsScript.data(footerContainerKey) or 'footer')
  vertical = id: $winbitsScript.data('vertical')
  Winbits.env.set('vertical', vertical)
)()