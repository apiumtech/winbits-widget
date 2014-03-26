HeaderPageView = require 'views/header/header-page-view'
FooterPageView = require 'views/footer/footer-page-view'
LoginView = require 'views/login/login-view'

module.exports = class Controller extends Chaplin.Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    @reuse Winbits.config.widgetContainer, HeaderPageView
    @reuse 'footer', FooterPageView
    @reuse 'login', LoginView
