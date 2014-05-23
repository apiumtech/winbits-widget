'use strict'
SocialAccountsView = require 'views/social-accounts/social-accounts-view'
SocialAccounts = require 'models/social-accounts/social-accounts'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator
rpc = Winbits.env.get('rpc')

describe 'SocialAccountsLinkViewSpec', ->

  TWITTER_RESPONSE = '{"meta":{"status":200},"response":{"socialUrl":"https://api.twitter.com/oauth/authorize?oauth_token=12jWNYjnjY8TAQpQTA7tOOYvFHdv27JHBUBEsjXGtA"}}'
  FACEBOOK_RESPONSE = '{"meta":{"status":200},"response":{"socialUrl":"https://graph.facebook.com/oauth/authorize?client_id=486640894740634&response_type=code&redirect_uri=https%3A%2F%2Fapidev.winbits.com%2Fv1%2Fusers%2Fconnect%2Ffacebook%3Fuser%3Dyou_fhater%2540hotmail.com&scope=publish_actions,publish_stream,share_item"}}'
  SOCIAL_ACCOUNTS_WITH_LINK_RESPONSE = '{"meta":{"status":200},"response":{"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":true},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":true}]}}'
  SOCIAL_ACCOUNTS_WITHOUT_LINK_RESPONSE = '{"meta":{"status":200},"response":{"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":false},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}]}}'

  beforeEach ->
    @server = sinon.fakeServer.create()
    @loginData =
      apiToken: 'XXX'
      profile: {}
      "socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":false},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}]
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @windowsOpenStub = sinon.stub(window, 'open').returns(focus: $.noop, closed:yes)
    @clock = sinon.useFakeTimers()
    @model = new SocialAccounts @loginData
    @view = new SocialAccountsView model: @model

  afterEach ->
    rpc.facebookStatus.restore?()
    @clock.restore()
    window.open.restore()
    @server.restore()
    @view.dispose()
    @model.dispose()

    utils.showConfirmationModal.restore?()
    utils.ajaxRequest.restore?()

  it "Should be called success when the api response with facebook", ->
    sinon.stub(@view, 'successConnectFacebookLink')
    @view.$('.wbc-facebook-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, TWITTER_RESPONSE)
    expect(@view.successConnectFacebookLink).to.be.calledOnce

  it "Should be called error when the api response with facebook", ->
    sinon.stub(@view, 'showErrorMessageLinkSocialAccount')
    @view.$('.wbc-facebook-link').click()
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect(@view.showErrorMessageLinkSocialAccount).to.be.calledOnce


  it "Should be called error when the api of facebook response success", ->
    sinon.stub(rpc, 'facebookStatus', (callback)->
      callback (status:'connected', authResponse:{userID:'100002184900102'})
    )
    sinon.stub @model, 'set'
    @view.$('.wbc-facebook-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, FACEBOOK_RESPONSE)
    @clock.tick(150)
    expect(@windowsOpenStub).have.been.calledOnce
    expect(@model.set).to.be.calledOnce

  it "Should be called error when the api of facebook response error", ->
    sinon.stub(rpc, 'facebookStatus', (callback)->
      callback (status:'disconnected', authResponse:{userID:'100002184900102'})
    )
    sinon.stub @model, 'set'
    sinon.stub(@view, 'showErrorMessageLinkSocialAccount')
    @view.$('.wbc-facebook-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, FACEBOOK_RESPONSE)
    @clock.tick(150)
    expect(@windowsOpenStub).have.been.calledOnce
    expect(@model.set).not.to.be.calledOnce
    expect(@view.showErrorMessageLinkSocialAccount).to.be.calledOnce

  it "Should be called success when the api response with twitter", ->
    sinon.stub(@view, 'successConnectTwitterLink')
    @view.$('.wbc-twitter-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, TWITTER_RESPONSE)
    console.log ['server request', @server.requests]
    expect(@view.successConnectTwitterLink).to.be.calledOnce

  it "Should be called error when the api response with twitter", ->
    sinon.stub(@view, 'showErrorMessageLinkSocialAccount')
    @view.$('.wbc-twitter-link').click()
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect(@view.showErrorMessageLinkSocialAccount).to.be.calledOnce


  it "Should be called success when the api of twitter response", ->
    sinon.stub(@view, 'showErrorMessageLinkSocialAccount')
    sinon.stub(@model, 'set')
    @view.$('.wbc-twitter-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, TWITTER_RESPONSE)
    expect(@windowsOpenStub).have.been.calledOnce
    @clock.tick(150)
    @server.requests[1].respond(200, { "Content-Type": "application/json" }, SOCIAL_ACCOUNTS_WITH_LINK_RESPONSE)
    expect(@view.showErrorMessageLinkSocialAccount).not.to.be.calledOnce
    expect(@model.set).to.be.calledOnce


  it "Should be called error when the api of twitter response", ->
    sinon.stub(@view, 'showErrorMessageLinkSocialAccount')
    @view.$('.wbc-twitter-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, TWITTER_RESPONSE)
    expect(@windowsOpenStub).have.been.calledOnce
    @clock.tick(150)
    @server.requests[1].respond(200, { "Content-Type": "application/json" }, SOCIAL_ACCOUNTS_WITHOUT_LINK_RESPONSE)
    expect(@view.showErrorMessageLinkSocialAccount).to.be.calledOnce

  it "Should be called error when the api of twitter response and validation don't respond success", ->
    sinon.stub(@view, 'showErrorMessageLinkSocialAccount')
    @view.$('.wbc-twitter-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, TWITTER_RESPONSE)
    expect(@windowsOpenStub).have.been.calledOnce
    @clock.tick(150)
    @server.requests[1].respond(400, { "Content-Type": "application/json" }, '')
    expect(@view.showErrorMessageLinkSocialAccount).to.be.calledOnce

