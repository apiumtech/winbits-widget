'use strict'

SocialMediaView = require 'views/social-accounts/social-accounts-view'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'SocialAccountsViewSpec', ->

  beforeEach ->
    @loginData =
      apiToken: 'XXX'
      profile: {}
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @view = new SocialMediaView
    @view.attach()

  it 'social media renderized', ->
    expect(@view.$ '.fbCircle').to.exist