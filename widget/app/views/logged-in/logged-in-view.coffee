View = require 'views/base/view'

module.exports = class LoggedInView extends View
  container: '#wbi-header-wrapper'
  className: 'miCuenta'
  autoRender: true
  template: require './templates/logged-in'

  initialize: ->
    #todo add regiones
    $('.mainHeader .wrapper .login').hide()


  showDropMenu:(e) ->
    e.preventDefault
    $('.dropMenu.miCuentaDiv').slideDown()

  hideDropMenu:(e) ->
    e.preventDefault
    $('.dropMenu.miCuentaDiv').slideUp()
