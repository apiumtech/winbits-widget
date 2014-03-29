View = require 'views/base/view'

module.exports = class LoggedInView extends View
  container: '.widgetWinbitsHeader #wbi-header-wrapper'
  className: 'miCuenta'
  autoRender: true
  template: require './templates/logged-in'

  initialize: ->
    #todo add regiones
    console.log ['SELECTOR IN LOGGED IN ->', Winbits.$('.widgetWinbitsHeader #wbi-header-wrapper')]
#    $('.mainHeader .wrapper .login').hide()

