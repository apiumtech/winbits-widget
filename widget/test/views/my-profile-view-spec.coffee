'use strict'

MyProfileView = require 'views/my-profile/my-profile-view'
MyProfile = require 'models/my-profile/my-profile'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'MyProfileViewSpec', ->

  beforeEach ->
    @loginData =
      apiToken: 'XXX'
      profile: {}
      email:'a@aa.aa'
    @model = new MyProfile @loginData
    @view = new MyProfileView model: @model

  afterEach ->
    @view.dispose()
    @model.dispose()

  it 'my profile renderized', ->
    expect(@view.$el).to.has.id('wbi-my-profile')
#    expect(@view.$ '#wbi-personal-data-form').to.exist
#    expect(@view.$ '#wbi-change-password-form').to.exist
#    expect(@view.$ '#wbi-social-media-panel').to.exist
