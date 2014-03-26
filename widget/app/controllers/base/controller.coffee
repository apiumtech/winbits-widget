HeaderView = require 'views/header/header-view'
FooterView = require 'views/footer/footer-view'

module.exports = class Controller extends Chaplin.Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    @reuse 'header', HeaderView
    @reuse 'footer', FooterView
