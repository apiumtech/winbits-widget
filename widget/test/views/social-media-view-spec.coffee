'use strict'

SocialMediaView = require 'views/social-media/social-media-view'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'SocialMediaViewSpec', ->

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