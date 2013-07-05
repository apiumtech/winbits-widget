ChaplinController = require 'chaplin/controller/controller'
LoginView = require 'views/login-view'
AddressView = require 'views/addressView'
ProfileView = require 'views/profile-view'
WidgetSiteView = require 'views/widget-site-view'
Address = require "models/address"
Profile = require "models/profile"

module.exports = class HomeController extends ChaplinController

  initialize: ->
    super
    @widgetSiteView = new WidgetSiteView()
    @widgetSiteView.render()

  index: ->
    console.log ":-0"
    that=this
    @view = new LoginView region: 'main'
    @address = new Address
    @profile = new Profile
    @address.on "change", ->
      console.log "addressChanged"
    @addressView = new AddressView(model: @address)
    @profileView = new ProfileView(model: @profile )
    @profile.on "change", ->
      console.log "profileChanged"
      that.profileView.render()
    #@view.render()
