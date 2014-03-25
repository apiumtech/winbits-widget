##
# Inicialización de configuración de widget por parte de la vertical.
# User: jluis
# Date: 25/03/14
#
(->
  $winbitsScript = $("script[src$='winbits.js']")
  Winbits.config =
    widgetContainer: $winbitsScript.data('widget-container') or 'header'
    footerContainer: $winbitsScript.data('footer-container') or 'footer'
    verticalId: $winbitsScript.data('vertical')
)()