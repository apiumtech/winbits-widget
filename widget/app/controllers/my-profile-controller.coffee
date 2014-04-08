Controller = require "controllers/logged-in-controller"
MyProfileView = require 'views/my-profile/my-profile-view'
$ = Winbits.$

module.exports = class MyProfileController extends Controller

  index: ->
    console.log 'my-profile#index'
    $('#wbi-my-account-div').slideDown()