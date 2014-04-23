Controller = require "controllers/logged-in-controller"
MyAccountAddressView = require 'views/my-account-address/my-account-address-view'
$ = Winbits.$

module.exports = class MiCuentaAddressController extends Controller

  index: ->
    console.log 'my-account-address#index'
    @view = new MyAccountAddressView
    $('#wbi-my-account-div').slideDown()