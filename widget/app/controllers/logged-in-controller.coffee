Controller = require "controllers/base/controller"
LoggedInView = require 'views/logged-in/logged-in-view'
utils = require 'lib/utils'
MyProfile = require 'models/my-profile/my-profile'
MyProfileView = require 'views/my-profile/my-profile-view'
MyAccountView = require 'views/my-account/my-account-view'
SocialMediaView = require 'views/social-media/social-media-view'
ChangePasswordView = require 'views/change-password/change-password-view'
ChangePassword = require 'models/change-password/change-password'
PersonalDataView = require 'views/personal-data/personal-data-view'
CartView = require 'views/cart/cart-view'
Cart = require 'models/cart/cart'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

module.exports = class LoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
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
      @reuse 'change-password-view',
        compose: ->
          mediator.data.set 'change-password-composed', yes
          @model = new ChangePassword
          @view = new ChangePasswordView model: @model

        check: -> mediator.data.get 'change-password-composed'
      @reuse 'social-media-view', SocialMediaView
      @reuse 'user-cart-view',
        compose: ->
          mediator.data.set 'profile-composed', yes
          @model = new Cart
          @view = new CartView container: '#wbi-user-cart', model: @model

        check: -> mediator.data.get 'profile-composed'
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'logged-in#index'
