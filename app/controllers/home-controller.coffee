ChaplinController = require 'chaplin/controller/controller'
LoginView = require 'views/login-view'
AddressView = require 'views/addressView'
ProfileView = require 'views/profile-view'
CartView = require 'views/cart-view'
WidgetSiteView = require 'views/widget-site-view'
SubscriptionView = require 'views/subscription-view'
Subscription = require "models/subscription"
RegisterView = require "views/register-view"
Address = require "models/address"
Profile = require "models/profile"
Cart = require "models/cart"

module.exports = class HomeController extends ChaplinController

  initialize: ->
    super
    @widgetSiteView = new WidgetSiteView()
    @widgetSiteView.render()

  index: ->
    console.log ":-0"
    that=this
    @view = new LoginView region: 'main'
    @address = new Address
    @profile = new Profile
    @cart = new Cart
    @subscription = new Subscription
    @address.on "change", ->
      console.log "addressChanged"
    @addressView = new AddressView(model: @address)
    @profileView = new ProfileView(model: @profile )
    @cartView = new CartView(model:@cart)
    @registerView = new RegisterView()
    @profile.on "change", ->
      console.log "profileChanged"
      that.profileView.render()
    @cart.on "change", ->
      console.log "cartChanged"
      that.cartView.render()
    @subscriptionView = new SubscriptionView(model: @subscription)
    @subscription.on "change", ->
      console.log "subscriptionChanged"
      that.subscriptionView.render()
    #Exporting fucntion
    Window.Winbits.addToCart = (item)->
      that.cartView.addToCart(item)