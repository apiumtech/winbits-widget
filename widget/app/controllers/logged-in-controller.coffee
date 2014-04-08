Controller = require "controllers/base/controller"
LoggedInView = require 'views/logged-in/logged-in-view'
LoggedInModel = require 'models/logged-in/logged-in'
utils = require 'lib/utils'
MyProfileView = require 'views/my-profile/my-profile-view'
MyProfile = require 'models/my-profile/my-profile'
MyAccountView = require 'views/my-account/my-account-view'
MyAccountModel = require 'models/my-account/my-account'
mediator = Winbits.Chaplin.mediator

module.exports = class LoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    loginData = mediator.data.get 'login-data'
    if loginData
      model = new LoggedInModel(loginData)
      @reuse 'logged-in', LoggedInView, model: model
      @reuse 'my-account', MyAccountView, model: new MyAccountModel
      @reuse 'my-profile', MyProfileView, model: new MyProfile loginData
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'logged-in#index'
