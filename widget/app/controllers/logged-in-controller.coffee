'use strict'
Controller = require "controllers/base/controller"
LoggedInView = require 'views/logged-in/logged-in-view'
utils = require 'lib/utils'
MyProfile = require 'models/my-profile/my-profile'
MyProfileView = require 'views/my-profile/my-profile-view'
MyAccountView = require 'views/my-account/my-account-view'
LoaderToCheckout = require 'views/loader-to-checkout/loader-to-checkout-view'
ShippingAddressesView = require 'views/shipping-addresses/shipping-addresses-view'
ShippingAddressesModel = require 'models/shipping-addresses/shipping-addresses'
MailingModel = require 'models/mailing/mailing'
MailingView = require 'views/mailing/mailing-view'
FavoriteView = require 'views/favorite/favorite-view'
Favorite = require 'models/favorite/favorite'
AccountHistoryView = require 'views/account-history/account-history-view'
AccountHistory = require 'models/account-history/account-history'
SocialAccountsView = require 'views/social-accounts/social-accounts-view'
SocialAccounts = require 'models/social-accounts/social-accounts'
ChangePasswordView = require 'views/change-password/change-password-view'
ChangePassword = require 'models/change-password/change-password'
PersonalDataView = require 'views/personal-data/personal-data-view'
CartView = require 'views/cart/cart-view'
Cart = require 'models/cart/cart'
CardsView =  require 'views/cards/cards-view'
Cards =  require 'models/cards/cards'
SwitchUserView =  require 'views/switch-user/switch-user-view'
SwitchUser =  require 'models/switch-user/switch-user'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

module.exports = class LoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    utils. restoreVerticalContent()
    loginData = mediator.data.get 'login-data'
    if loginData
      @reuse 'logged-in', LoggedInView
      @reuse 'my-account', MyAccountView
      @reuse 'my-profile-view', MyProfileView
      @reuse 'personal-data-view',
        compose: ->
          mediator.data.set 'profile-composed', yes
          @model = new MyProfile
          @view = new PersonalDataView model: @model

        check: -> mediator.data.get 'profile-composed'

      @reuse 'loader-to-checkout-view',
        compose: ->
          mediator.data.set 'loader-to-checkout-composed', yes
          @model = new LoaderToCheckout

        check: -> mediator.data.get 'loader-to-checkout-composed'

      @reuse 'change-password-view',
        compose: ->
          mediator.data.set 'change-password-composed', yes
          @model = new ChangePassword
          @view = new ChangePasswordView model: @model

        check: -> mediator.data.get 'change-password-composed'

      @reuse 'social-media-view',
        compose: ->
          mediator.data.set 'social-accounts-composed', yes
          @model = new SocialAccounts
          @view = new SocialAccountsView model:@model
        check: -> mediator.data.get 'social-accounts-composed'

      @reuse 'shipping-addresses',
        compose: ->
          mediator.data.set 'shipping-addresses-composed', yes
          @model = new ShippingAddressesModel
          @view = new ShippingAddressesView model:@model

        check: -> mediator.data.get 'shipping-addresses-composed'

      @reuse 'mailing',
         compose: ->
           mediator.data.set 'mailing-composed', yes
           loginData = loginData = mediator.data.get 'login-data'
           @model = new MailingModel subscriptions: loginData.subscriptions, newsletterPeriodicity: loginData.profile.newsletterPeriodicity, newsletterFormat: loginData.profile.newsletterFormat
           @view = new MailingView model:@model

        check: -> mediator.data.get 'mailing-composed'

      @reuse 'user-cart-view',
        compose: ->
          mediator.data.set 'profile-composed', yes
          @model = new Cart
          @view = new CartView container: '#wbi-user-cart', model: @model

        check: -> mediator.data.get 'profile-composed'

      @reuse 'cards-view',
        compose: ->
          mediator.data.set 'cards-composed', yes
          @model = new Cards
          @view = new CardsView model: @model

        check: -> mediator.data.get 'cards-composed'

      @reuse 'favorite-view',
        compose: ->
          mediator.data.set 'favorite-composed', yes
          @model = new Favorite
          @view = new FavoriteView model: @model

        check: -> mediator.data.get 'favorite-composed'

      @reuse 'account-history-view',
        compose: ->
          mediator.data.set 'account-history-composed', yes
          @model = new AccountHistory
          @view = new AccountHistoryView model: @model

        check: -> mediator.data.get 'account-history-composed'

      if (utils.isSwitchUser())
        @reuse 'switch-user-view',
          compose: ->
            mediator.data.set 'switch-user-composed', yes
            @model = new SwitchUser
            @view = new SwitchUserView model: @model

          check: -> mediator.data.get 'switch-user-composed'
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'logged-in#index'
