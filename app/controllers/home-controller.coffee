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
BitRecord = require "models/account/bitRecord"
BitRecordView = require "views/widget/account/bitRecord-view"
HistoryView = require "views/widget/history-view"
OrderHistory = require "models/account/orderHistory"
OrdersHistoryView = require "views/widget/account/ordersHistory-view"
AccordionView = require "views/widget/account/accordion-view"
WaitingList = require "models/account/waitingList"
WaitingListView = require "views/widget/account/waitingList-view"
WishList = require "models/account/wishList"
WishListView = require "views/widget/account/wishList-view"
mediator = require 'chaplin/mediator'
util = require 'lib/util'
config = require 'config'

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
    @accordionView = new AccordionView
    @waitingList = new WaitingList
    @waitingListView = new WaitingListView(model: @waitingList)
    @wishList = new WishList
    @wishListView = new WishListView(model: @wishList)
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

    window.Winbits.getUserActive = () ->
      mediator.flags.loggedIn

    window.Winbits.getBitsBalance = ()->
      if mediator.flags.loggedIn
        mediator.profile.bitsBalance
      else
        throw 'Not available if not logged in!'

    window.Winbits.getSocialAccounts = ()->
      if mediator.flags.loggedIn
        mediator.profile.socialAccounts
      else
        throw 'Not available if not logged in!'

    window.Winbits.tweet = (options)->
      options = options or {}
      if mediator.flags.loggedIn
        socialAccounts = window.Winbits.getSocialAccounts()
        if socialAccounts.length is 0
          throw 'Twitter not connected!'
        w$.each socialAccounts, (i, account) ->
          if account.providerId is 'twitter' and !account.linked
            throw 'Twitter not connected!'
        message = options.message or 'Test message'
        Backbone.$.ajax config.apiUrl + "/affiliation/twitterPublish/updateStatus.json",
          type: "POST"
          contentType: "application/json"
          dataType: "json"
          data: JSON.stringify(message: message)
          xhrFields:
            withCredentials: true

          headers:
            "Accept-Language": "es"
            "WB-Api-Token":  util.getCookie(config.apiTokenName)

          success: (data) ->
        console.log "updateStatus.json Success!"

        error: (xhr, textStatus, errorThrown) ->
          console.log "updateStatus.json Error!"
          error = JSON.parse(xhr.responseText)
          alert error.meta.message

        complete: ->
          console.log "updateStatus.json Completed!"
      else
        throw 'Not available if not logged in!'

    window.Winbits.share = (options)->
      options = options or {}
      if mediator.flags.loggedIn
        socialAccounts = window.Winbits.getSocialAccounts()
        if socialAccounts.length is 0
          throw 'Facebook not connected!'
        w$.each socialAccounts, (i, account) ->
          if account.providerId is 'facebook' and !account.linked
            throw 'Facebook not connected!'
        message = options.message or 'Test message'
        Backbone.$.ajax config.apiUrl + "/affiliation/facebookPublish/share.json",
          type: "POST"
          contentType: "application/json"
          dataType: "json"
          data: JSON.stringify(message: 'Yo ya me registré en Winbits (facebook test)')
          xhrFields:
            withCredentials: true

          headers:
            "Accept-Language": "es"
            "WB-Api-Token":  util.getCookie(config.apiTokenName)

          success: (data) ->
            console.log "share.json Success!"

          error: (xhr, textStatus, errorThrown) ->
            console.log "share.json Error!"
            error = JSON.parse(xhr.responseText)
            alert error.meta.message

          complete: ->
          console.log "share.json Completed!"
      else
        throw 'Not available if not logged in!'

    window.Winbits.getSkuProfileInfo = (options) ->
      result = ""
      data = undefined
      if mediator.flags.loggedIn
        data = {userId: mediator.profile.userId}
      Backbone.$.ajax config.apiUrl + "/catalog/sku-profiles/" + options.id + "/info.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: data
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log "info.json Success!"
          result = data

        error: (xhr, textStatus, errorThrown) ->
          console.log "info.json Error!"
          error = JSON.parse(xhr.responseText)
          alert error.meta.message

        complete: ->
          console.log "info.json Completed!"

      result