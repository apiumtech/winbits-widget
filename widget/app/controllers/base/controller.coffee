HeaderPageView = require 'views/header/header-page-view'
MainPageView = require 'views/main/main-page-view'
FooterPageView = require 'views/footer/footer-page-view'
LoginView = require 'views/login/login-view'

module.exports = class Controller extends Chaplin.Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    @reuse 'header', HeaderPageView
    @reuse 'main', MainPageView
    @reuse 'footer', FooterPageView
    @reuse 'login', LoginView
