View = require 'views/base/view'
Model = require 'models/logged-in/logged-in'

module.exports = class LoggedInView extends View
  container: '.widgetWinbitsHeader #wbi-header-wrapper'
  className: 'miCuenta'
  autoRender: true
  template: require './templates/logged-in'
#  model: Model

  initialize:(params) ->
    #todo add regiones
    console.log ['PARAMS RECEIVED ->', params]

