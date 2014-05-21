'use strict'

SocialMediaView = require 'views/social-accounts/social-accounts-view'
SocialMedia = require 'models/social-accounts/social-accounts'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'SocialAccountsViewSpec', ->

  beforeEach ->
    @loginData =
      apiToken: 'XXX'
      profile: {}
      socialAccounts: [{name:'Facebook', avalilable:'false'}, {name:'Twitter', available:'false'}]
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @model = new SocialMedia  @loginData
    @view = new SocialMediaView model:@model
    @view.attach()

  it 'social media renderized', ->
    expect(@view.$ '.iconFont-facebookCircle').to.exist