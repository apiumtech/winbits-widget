MyProfileView = require 'views/my-profile/my-profile-view'
MyProfile = require 'models/my-profile/my-profile'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'MyProfileView', ->
  'use strict'

  before ->
    console.log "before"

  after ->
    console.log "after"

  beforeEach ->
    console.log "before each"
    @loginData =
      apiToken: 'XXX'
      profile: {}
      email:'a@aa.aa'
    @view = new MyProfileView model: new MyProfile @loginData

  afterEach ->
    console.log "after each"

  it 'my profile renderized', ->
    expect(@view.$el).to.has.id('wbi-my-profile')
    expect(@view.$ '#wbi-personal-data-form').to.exist
    expect(@view.$ '#wbi-change-password-form').to.exist
    expect(@view.$ '#wbi-social-media-panel').to.exist

  it 'should render profile form data with data', ->
    personalData = name: 'Jorge', lastName:"Moreno", zipCode:'11111', phone:'431256789'
    @view.model.set personalData
    _.each personalData, (value, key) ->
      expect(@view.$ "[name=#{key}]").to.has.value value
    , @