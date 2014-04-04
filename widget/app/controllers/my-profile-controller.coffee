Controller = require "controllers/logged-in-controller"
MyProfileView = require 'views/my-profile/my-profile-view'
#MyProfileModel = require 'model/my-profile/my-profile'
$ = Winbits.$

module.exports = class MyProfileController extends Controller

#  beforeAction: (params)->
#    super
#    model = new MyProfileModel(params)
#    @reuse 'my-profile', MyProfileView, model:model

  index: ->
    console.log 'my-profile#index'
    $('.miCuentaDiv').slideDown()