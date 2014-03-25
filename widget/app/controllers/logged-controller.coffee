HomeController = require 'controllers/home-controller'
LoggedView = require 'views/logged/logged-view'

module.exports = class LoggedController extends HomeController
  
  showLogged: ->
   @view = new LoggedView()
