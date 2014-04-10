Controller = require "controllers/base/controller"
LoggedInView = require 'views/logged-in/logged-in-view'
utils = require 'lib/utils'
MyProfile = require 'models/my-profile/my-profile'
MyProfileView = require 'views/my-profile/my-profile-view'
MyAccountView = require 'views/my-account/my-account-view'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

module.exports = class LoggedInController extends Controller
  # Reusabilities persist stuff between controllers.
  # You may also persist models etc.
  beforeAction: ->
    super
    $ -> $.fancybox.close()
    loginData = mediator.data.get 'login-data'
    if loginData
      @reuse 'logged-in', LoggedInView
      @reuse 'my-account', MyAccountView
      @reuse 'my-profile-view',
        compose: ->
          mediator.data.set 'profile-composed', yes
          @model = new MyProfile
          @view = new MyProfileView model: @model

        check: -> mediator.data.get 'profile-composed'
    else
      @redirectTo 'home#index'

  index: ->
    console.log 'logged-in#index'
