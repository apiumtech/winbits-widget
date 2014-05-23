'use strict'

SocialAccountsView = require 'views/social-accounts/social-accounts-view'
SocialAccounts = require 'models/social-accounts/social-accounts'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'SocialAccountsViewSpec', ->

  beforeEach ->
    @loginData =
      apiToken: 'XXX'
      profile: {}
      "socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":false},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}]
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @model = new SocialAccounts @loginData
    @view = new SocialAccountsView model:@model

  afterEach ->
    utils.redirectTo.restore?()
    $.fancybox.close.restore?()
    @model.dispose()
    @view.dispose()


  it 'social account renderized without any link', ->
    expect(@view.$('h3')).to.exist
    expect(@view.$('.iconFont-facebookCircle.icon-black')).to.exist
    expect(@view.$('.iconFont-twitterCircle.icon-black')).to.exist
    expect(@view.$('.wbc-twitter-link')).to.exist
    expect(@view.$('.wbc-facebook-link')).to.exist

  it 'social account renderized with facebook linked and twitter unlinked', ->
    @model.set 'Facebook', yes
    expect(@view.$('.iconFont-facebookCircle.icon-blueFB')).to.exist
    expect(@view.$('.iconFont-twitterCircle.icon-black')).to.exist
    expect(@view.$('.wbc-twitter-link')).to.exist
    expect(@view.$('.wbc-facebook-unlink')).to.exist

  it 'social account renderized with twitter linked and facebook unlinked', ->
    @model.set 'Twitter', yes
    expect(@view.$('.iconFont-facebookCircle.icon-black')).to.exist
    expect(@view.$('.iconFont-twitterCircle.icon-blueTW')).to.exist
    expect(@view.$('.wbc-twitter-unlink')).to.exist
    expect(@view.$('.wbc-facebook-link')).to.exist

  it 'social account renderized with twitter linked and facebook linked', ->
    @model.set 'Twitter', yes
    @model.set 'Facebook', yes
    expect(@view.$('.iconFont-facebookCircle.icon-blueFB')).to.exist
    expect(@view.$('.iconFont-twitterCircle.icon-blueTW')).to.exist
    expect(@view.$('.wbc-twitter-unlink')).to.exist
    expect(@view.$('.wbc-facebook-unlink')).to.exist

  it 'should success social account url facebook', ->
    sinon.stub(@view, 'successConnectFacebookLink')
    sinon.stub(@model, 'requestConnectionLink').returns TestUtils.promises.resolved
    @view.$('.wbc-facebook-link').click()
    expect(@model.requestConnectionLink).to.have.been.calledOnce


  it 'should success social account url twitter', ->
    sinon.stub(@view, 'successConnectTwitterLink')
    sinon.stub(@model, 'requestConnectionLink').returns TestUtils.promises.resolved
    @view.$('.wbc-twitter-link').click()
    expect(@model.requestConnectionLink).to.have.been.calledOnce