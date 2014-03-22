View = require 'views/base/view'

module.exports = class LoggedView extends View
  container: '.mainHeader .wrapper'
  className: 'miCuenta'
  autoRender: true
  template: require './templates/logged'
  events:
    'click .spanDropMenu.link': 'showDropMenu'
    'click .icon.trigger.triggerMiCuenta': 'showDropMenu'
    'click .miCuenta-close': 'hideDropMenu'

   initialize: ->
     #todo add regiones  
     $('.mainHeader .wrapper .login').hide()


   showDropMenu:(e) ->
    e.preventDefault
    $('.dropMenu.miCuentaDiv').slideDown()

  hideDropMenu:(e) ->
    e.preventDefault
    $('.dropMenu.miCuentaDiv').slideUp()








