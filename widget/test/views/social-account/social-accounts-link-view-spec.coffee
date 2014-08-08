'use strict'
SocialAccountsView = require 'views/social-accounts/social-accounts-view'
SocialAccounts = require 'models/social-accounts/social-accounts'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

describe 'SocialAccountsLinkViewSpec', ->

  TWITTER_RESPONSE = '{"meta":{"status":200},"response":{"socialUrl":"https://api.twitter.com/oauth/authorize?oauth_token=12jWNYjnjY8TAQpQTA7tOOYvFHdv27JHBUBEsjXGtA"}}'
  FACEBOOK_RESPONSE = '{"meta":{"status":200},"response":{"socialUrl":"https://graph.facebook.com/oauth/authorize?client_id=486640894740634&response_type=code&redirect_uri=https%3A%2F%2Fapidev.winbits.com%2Fv1%2Fusers%2Fconnect%2Ffacebook%3Fuser%3Dyou_fhater%2540hotmail.com&scope=publish_actions,publish_stream,share_item"}}'
  SUCCESS_DELETE_SOCIAL_ACCOUNT = '{"meta":{"status":200},"response":{}}'

  beforeEach ->
    @server = sinon.fakeServer.create()
    @loginData =
      apiToken: 'XXX'
      profile: {}
      "socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":false},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}]
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @windowsOpenStub = sinon.stub(window, 'open').returns(focus: $.noop, closed:yes)
    sinon.stub(utils, 'showAjaxLoading')
    sinon.stub(utils, 'showMessageModal')
    @model = new SocialAccounts @loginData
    @view = new SocialAccountsView model: @model


  afterEach ->
    utils.showAjaxLoading.restore()
    utils.showMessageModal.restore()
    utils.showConfirmationModal.restore?()
    utils.showError.restore?()
    utils.ajaxRequest.restore?()
    window.open.restore()
    @server.restore()
    @view.dispose()
    @model.dispose()


  it "Should be called success when the api response with facebook", ->
    sinon.stub(@view, 'successConnectLink')
    @view.$('.wbc-facebook-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, FACEBOOK_RESPONSE)
    expect(@view.successConnectLink).to.be.calledOnce

  it "Should be called error when the api response with facebook", ->
    sinon.stub(utils, 'showError')
    @view.$('.wbc-facebook-link').click()
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect(utils.showError).to.be.calledOnce

  it "Should be called success when the api of facebook response success", ->
    sinon.stub @model, 'set'
    sinon.stub @view, 'doChangeLoginSocialAccounts'
    @view.publishEvent 'success-authentication-fb-link', {code: "success-authentication-fb-link",successCode: "Facebook",verticalId: "2"}
    expect( @model.set).has.been.calledOnce
    expect( @view.doChangeLoginSocialAccounts).has.been.calledOnce

  it "Should be called error when the api of facebook response authorization error", ->
    sinon.stub @model, 'set'
    @view.publishEvent 'denied-authentication-fb-link', {accountId: "facebook",code: "denied-authentication-fb-link",errorCode: "DAFL",verticalId: "2"}
    expect( @model.set).has.not.been.called
    expect(utils.showMessageModal).has.been.calledOnce

  it "Should be called error when the api of facebook response permissions error", ->
    sinon.stub @model, 'set'
    @view.publishEvent 'denied-permissions-fb-link', {accountId: "facebook",code: "denied-permissions-fb-link",errorCode: "DPFL",verticalId: "2"}
    expect( @model.set).has.not.been.called
    expect(utils.showMessageModal).has.been.calledOnce


  it "Should be called error when the api of facebook response has other account link error", ->
    sinon.stub @model, 'set'
    @view.publishEvent 'fb-has-link-account', {accountId: "facebook",code: "fb-has-link-account",errorCode: "FHLA",verticalId: "2"}
    expect( @model.set).has.not.been.called
    expect(utils.showMessageModal).has.been.calledOnce

  it "Should be called success when the api response with twitter", ->
    sinon.stub(@view, 'successConnectLink')
    @view.$('.wbc-twitter-link').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, TWITTER_RESPONSE)
    expect(@view.successConnectLink).to.be.calledOnce

  it "Should be called error when the api response with twitter", ->
    sinon.stub(utils, 'showError')
    @view.$('.wbc-twitter-link').click()
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect(utils.showError).to.be.calledOnce

  it "Should be called success when the api of twitter response success", ->
    sinon.stub @model, 'set'
    sinon.stub @view, 'doChangeLoginSocialAccounts'
    @view.publishEvent 'success-authentication-tw-link', {code: "success-authentication-tw-link",successCode: "Twitter",verticalId: "2"}
    expect( @model.set).has.been.calledOnce
    expect( @view.doChangeLoginSocialAccounts).has.been.calledOnce

  it "Should be called error when the api of twitter response authorization error", ->
    sinon.stub @model, 'set'
    @view.publishEvent 'denied-authentication-tw-link', {accountId: "facebook",code: "denied-authentication-tw-link",errorCode: "DATL",verticalId: "2"}
    expect( @model.set).has.not.been.called
    expect(utils.showMessageModal).has.been.calledOnce

  it "Should be called error when the api of twitter response has other account link error", ->
    sinon.stub @model, 'set'
    @view.publishEvent 'tw-has-link-account', {accountId: "twitter",code: "tw-has-link-account",errorCode: "THLA",verticalId: "2"}
    expect( @model.set).has.not.been.called
    expect(utils.showMessageModal).has.been.calledOnce

  it "Should be set in model Facebook unlink success", ->
    @model.set 'Facebook', yes
    sinon.stub @model, 'set'
    @view.doRequestDeleteSocialAccount('Facebook')
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, SUCCESS_DELETE_SOCIAL_ACCOUNT)
    expect(@model.set).to.have.been.calledOnce

  it "Should be set in model Twitter unlink success", ->
    @model.set 'Twitter', yes
    sinon.stub @model, 'set'
    @view.doRequestDeleteSocialAccount('Twitter')
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, SUCCESS_DELETE_SOCIAL_ACCOUNT)
    expect(@model.set).to.have.been.calledOnce

  it "Should be set in model Facebook unlink fail", ->
    @model.set 'Facebook', yes
    sinon.stub @model, 'set'
    sinon.stub utils, 'showError'
    @view.doRequestDeleteSocialAccount('Facebook')
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect(@model.set).to.not.have.been.called
    expect(utils.showError).to.have.been.calledOnce

  it "Should be set in model Twitter unlink fail", ->
    @model.set 'Twitter', yes
    sinon.stub @model, 'set'
    sinon.stub utils, 'showError'
    @view.doRequestDeleteSocialAccount('Twitter')
    @server.requests[0].respond(500, { "Content-Type": "application/json" }, '')
    expect(@model.set).to.not.have.been.called
    expect(utils.showError).to.have.been.calledOnce
