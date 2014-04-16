Controller = require "controllers/logged-in-controller"
MicuentaAddressView = require 'views/micuenta-address/micuenta-address-view'
$ = Winbits.$

module.exports = class MiCuentaAddressController extends Controller

  index: ->
    console.log 'micuenta-address#index'
    @view = new MicuentaAddressView
    $('#wbi-my-account-div').slideDown()