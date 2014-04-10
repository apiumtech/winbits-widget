Controller = require "controllers/base/controller"
LoggedInView = require 'views/logged-in/logged-in-view'
utils = require 'lib/utils'
MyProfileView = require 'views/my-profile/my-profile-view'
MyAccountView = require 'views/my-account/my-account-view'
mediator = Winbits.Chaplin.mediator

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
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'logged-in#index'
