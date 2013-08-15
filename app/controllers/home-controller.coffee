ChaplinController = require 'chaplin/controller/controller'
WidgetSiteView = require 'views/widget/widget-site-view'
LoginView = require 'views/widget/login-view'
AddressView = require 'views/widget/addressView'
ProfileView = require 'views/widget/profile-view'
CartView = require 'views/widget/cart-view'
SubscriptionView = require 'views/widget/subscription-view'
Subscription = require "models/subscription"
RegisterView = require "views/widget/register-view"
Address = require "models/address"
Profile = require "models/profile"
Cart = require "models/cart"
RegisterFb = require "models/registerfb"
BitRecord = require "models/bitRecord"
BitRecordView = require "views/widget/bitRecord-view"
HistoryView = require "views/widget/history-view"
OrderHistory = require "models/orderHistory"
OrdersHistoryView = require "views/widget/ordersHistory-view"

module.exports = class HomeController extends ChaplinController

  initialize: ->
    super
    @widgetSiteView = new WidgetSiteView()
    @widgetSiteView.render()

  index: ->
    that=this
    @view = new LoginView region: 'main'
    @address = new Address
    @profile = new Profile
    @cart = new Cart
    @subscription = new Subscription
    @registerfb = new RegisterFb
    @addressView = new AddressView(model: @address)
    @profileView = new ProfileView(model: @profile )
    @cartView = new CartView(model:@cart)
    @registerView = new RegisterView(model: @registerfb)
    @historyView = new HistoryView
    @bitRecord = new BitRecord
    @bitRecordView = new BitRecordView(model: @bitRecord)
    @orderHistory = new OrderHistory
    @ordersHistoryView = new OrdersHistoryView(model: @orderHistory)

    @address.fetch()
    @profile.on "change", ->
      that.profileView.render()
    @cart.on "change", ->
      that.cartView.render()
    @subscriptionView = new SubscriptionView(model: @subscription)
    @subscription.on "change", ->
      that.subscriptionView.render()
    @registerfb.on "change", ->
      that.registerView.render()
    @address.on "change", ->
      console.log "addressChanged"
      that.addressView.render()
    #Exporting function
    window.Winbits.addToCart = (item)->
      that.cartView.addToCart(item)


