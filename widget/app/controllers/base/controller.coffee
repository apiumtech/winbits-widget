HeaderView = require 'views/header/header-view'
FooterView = require 'views/footer/footer-view'
EventBroker = Winbits.Chaplin.EventBroker
_ = Winbits._

module.exports = class Controller extends Chaplin.Controller

  initialize: ->
    super
    _.extend @prototype, EventBroker

  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    @reuse 'header', HeaderView
    @reuse 'footer', FooterView
