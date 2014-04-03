MyAccountView = require 'views/my-profile/my-profile-view'
utils = require 'lib/utils'
$ = Winbits.$

describe 'MyAccountView', ->
  'use strict'

  before ->
    console.log "xxxxx"

  after ->
    console.log "sssss"

  beforeEach ->
    console.log "before each"

  afterEach ->
    console.log "after each"

  it 'my profile renderized', ->
    expect(@view.$el).to.has.id('wbi-my-profile')
    expect(@view.$ '#wbi-personal-data-form').to.be.rendered
    expect(@view.$ '#wbi-change-password-form').to.be.rendered
    expect(@view.$ '#wbi-social-link-form').to.be.rendered