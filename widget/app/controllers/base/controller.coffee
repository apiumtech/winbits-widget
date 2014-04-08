HeaderView = require 'views/header/header-view'
FooterView = require 'views/footer/footer-view'
Header = require 'models/header/header'
env = Winbits.env

module.exports = class Controller extends Chaplin.Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    currentVerticalId = env.get 'current-vertical-id'
    verticalsData = env.get 'verticals-data'
    @reuse 'header', HeaderView,
    @reuse 'footer', FooterView
