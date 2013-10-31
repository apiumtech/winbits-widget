mediator = require 'chaplin/mediator'
util = require 'lib/util'
config = require 'config'
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
ShippingAddress = require "models/shipping/shipping-address"
ShippingAddressView = require "views/widget/shipping/shipping-address-view"
ShippingMainView = require "views/widget/shipping/shipping-main-view"
ForgotPasswordView = require "views/widget/forgot-password-view"
Resume = require "models/checkout/resume"
ResumeView = require "views/checkout/resume-view"
Cards = require "models/checkout/cards"
CardsView = require "views/checkout/cards-view"
CardsManagerView = require "views/widget/account/cards-manager-view"
ResetPassword = require "models/reset-password"
ResetPasswordView = require "views/widget/reset-password-view"


module.exports = class HomeController extends ChaplinController

  initialize: ->
    super
    @widgetSiteView = new WidgetSiteView()

  index: ->
    that=this
    @view = new LoginView region: 'main'
    @forgotPasswordView = new ForgotPasswordView
    @address = new Address
    @profile = new Profile
    @cart = new Cart
    @shippingAddress = new ShippingAddress
    @cards = new Cards(mainOnClick: yes, loadingIndicator: yes)
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
    @shippingMainView = new ShippingMainView
    @shippingAddressView = new ShippingAddressView(model: @shippingAddress)
    @resume = new Resume
    @resumeView = new ResumeView(model: @resume)
    @cardsManagerView = new CardsManagerView
    @cardsView = new CardsView(model: @cards)
    @resetPassword = new ResetPassword
    @resetPasswordView = new ResetPasswordView(model: @resetPassword)
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
    @cards.on 'change', ->
      console.log "Cards model changed"
      that.cardsView.render()
    #Exporting function
    window.Winbits.addToCart = (item)->
      that.cartView.addToCart(item)

    window.Winbits.getUserProfile = () ->
      if mediator.flags.loggedIn
        mediator.global.profile
      else
        throw 'Not available if not logged in!'

    window.Winbits.isUserLoggedIn = () ->
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
          if account.providerId is 'twitter' and !account.available
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
            console.log "info.json Success!"
            if options.success
              options.success.call({}, [data.response])

          error: (xhr, textStatus, errorThrown) ->
            console.log "info.json Error!"
            error = JSON.parse(xhr.responseText)
            console.log ['Error', error.meta.message]
            if options.error
              options.error.call({}, [error.response])

          complete: ->
            console.log "info.json Completed!"
            if options.complete
              options.complete.call({}, [])
      else
        throw 'Not available if not logged in!'

    window.Winbits.share = (options)->
      options = options or {}
      if mediator.flags.loggedIn
        socialAccounts = window.Winbits.getSocialAccounts()
        if socialAccounts.length is 0
          throw 'Facebook not connected!'

        w$.each socialAccounts, (i, account) ->
          console.log ['account', account]
          if account.providerId is 'facebook' and !account.available
            throw 'Facebook not connected!'
        message = options.message or 'Test message'
        Backbone.$.ajax config.apiUrl + "/affiliation/facebookPublish/share.json",
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
            console.log "info.json Success!"
            if options.success
              options.success.call({}, [data.response])

          error: (xhr, textStatus, errorThrown) ->
            console.log "info.json Error!"
            error = JSON.parse(xhr.responseText)
            console.log ['Error', error.meta.message]
            if options.error
              options.error.call({}, [error.response])

          complete: ->
            console.log "info.json Completed!"
            if options.complete
              options.complete.call({}, [])
      else
        throw 'Not available if not logged in!'

    window.Winbits.getSkuProfileInfo = (options) ->
      options = options or {}
      data = `undefined`
      if mediator.flags.loggedIn
        data = {userId: mediator.profile.userId}
      Backbone.$.ajax config.apiUrl + "/catalog/sku-profiles/" + options.id + "/info.json",
        type: "POST"
        dataType: "json"
        data: data
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log "info.json Success!"
          if options.success
            options.success.call({}, [data.response])

        error: (xhr) ->
          console.log "info.json Error!"
          error = JSON.parse(xhr.responseText)
          console.log ['Error', error.meta.message]
          if options.error
            options.error.call({}, [error.response])

        complete: ->
          console.log "info.json Completed!"
          if options.complete
            options.complete.call({}, [])

    window.Winbits.getSkuProfilesInfo = (options) ->
      options = options or {}
      if not options.ids
        throw "Argument 'ids' is required!"
      data = {ids: options.ids.join()}
      if mediator.flags.loggedIn
        data.userId =mediator.profile.userId
      Backbone.$.ajax config.apiUrl + "/catalog/sku-profiles-info.json",
        type: "POST"
        dataType: "json"
        data: data
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log "info.json Success!"
          options.success.call({}, [data.response]) if typeof options.success is 'function'

        error: (xhr) ->
          console.log "info.json Error!"
          error = JSON.parse(xhr.responseText)
          console.log ['Error', error.meta.message]
          options.error.call({}, [error.response]) if typeof options.error is 'function'

        complete: ->
          console.log "info.json Completed!"
          options.complete.call({}, []) if typeof options.complete is 'function'

    window.Winbits.getWishListItems = () ->
      options = options or {}
      if !mediator.flags.loggedIn
        throw 'Not available if not logged in!'

      Backbone.$.ajax config.apiUrl + "/affiliation/wish-list-items.json",
        contentType: "application/json"
        dataType: "json"
        xhrFields:
          withCredentials: true
        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)
        success: (data) ->
          console.log "info.json Success!"
          options.success.call({}, [data.response]) if typeof options.success is 'function'
        error: (xhr) ->
          console.log "info.json Error!"
          error = JSON.parse(xhr.responseText)
          options.error.call({}, [error.response]) if typeof options.error is 'function'
        complete: ->
          console.log "info.json Completed!"
          options.complete.call({}, []) if typeof options.complete is 'function'

    window.Winbits.addToWishList = (options) ->
      options = options or {}
      if !mediator.flags.loggedIn
        throw 'Not available if not logged in!'

      Backbone.$.ajax config.apiUrl + "/affiliation/wish-list-items.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify {brandId: options.brandId}
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log "info.json Success!"
          if options.success
            options.success.call({}, [data.response])

        error: (xhr, textStatus, errorThrown) ->
          console.log "info.json Error!"
          error = JSON.parse(xhr.responseText)
          console.log ['Error', error.meta.message]
          if options.error
            options.error.call({}, [error.response])

        complete: ->
          console.log "info.json Completed!"
          if options.complete
            options.complete.call({}, [])

    window.Winbits.deleteFromWishList = (options) ->
      options = options or {}
      if !mediator.flags.loggedIn
        throw 'Not available if not logged in!'

      Backbone.$.ajax config.apiUrl + "/affiliation/wish-list-items/" + options.brandId + "/.json",
        type: "DELETE"
        dataType: "json"
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log "info.json Success!"
          if options.success
            options.success.call({}, [data.response])

        error: (xhr, textStatus, errorThrown) ->
          console.log "info.json Error!"
          error = JSON.parse(xhr.responseText)
          console.log ['Error', error.meta.message]
          if options.error
            options.error.call({}, [error.response])

        complete: ->
          console.log "info.json Completed!"
          if options.complete
            options.complete.call({}, [])

    window.Winbits.addToWaitingList = (options) ->
      options = options or {}
      if !mediator.flags.loggedIn
        throw 'Not available if not logged in!'
      Backbone.$.ajax config.apiUrl + "/affiliation/waiting-list-items.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify {skuProfileId: options.id}
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log "info.json Success!"
          if options.success
            options.success.call({}, [data.response])

        error: (xhr, textStatus, errorThrown) ->
          console.log "info.json Error!"
          error = JSON.parse(xhr.responseText)
          console.log ['Error', error.meta.message]
          if options.error
            options.error.call({}, [error.response])

        complete: ->
          console.log "info.json Completed!"
          if options.complete
            options.complete.call({}, [])

    window.Winbits.deleteFromWaitingList = (options) ->
      options = options or {}
      if !mediator.flags.loggedIn
        throw 'Not available if not logged in!'

      Backbone.$.ajax config.apiUrl + "/affiliation/wish-list-items/" + options.id + "/.json",
        type: "DELETE"
        dataType: "json"
        xhrFields:
          withCredentials: true

        headers:
          "Accept-Language": "es"
          "WB-Api-Token":  util.getCookie(config.apiTokenName)

        success: (data) ->
          console.log "info.json Success!"
          if options.success
            options.success.call({}, [data.response])

        error: (xhr, textStatus, errorThrown) ->
          console.log "info.json Error!"
          error = JSON.parse(xhr.responseText)
          console.log ['Error', error.meta.message]
          if options.error
            options.error.call({}, [error.response])

        complete: ->
          console.log "info.json Completed!"
          if options.complete
            options.complete.call({}, [])
