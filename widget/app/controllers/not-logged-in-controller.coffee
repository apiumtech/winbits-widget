Controller = require "controllers/base/controller"
NotLoggedInView = require 'views/not-logged-in/not-logged-in-view'
CartView = require 'views/cart/cart-view'
Cart = require 'models/cart/cart'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
module.exports = class NotLoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    if not mediator.data.get 'login-data'
      @reuse 'not-logged-in', NotLoggedInView
      @reuse 'virtual-cart-view', CartView, { container: '#wbi-virtual-cart' }
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'not-logged-in#index'
