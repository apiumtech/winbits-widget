'use strict'

NotLoggedInView =  require 'views/not-logged-in/not-logged-in-view'
NotLoggedIn =  require 'models/not-logged-in/not-logged-in'
utils = require 'lib/utils'
$ = Winbits.$

describe 'NotLoggedInViewSpec', ->

  beforeEach ->
    Winbits.Chaplin.mediator.data.set('first-entry', yes)
    currentVertical = id: 1, baseUrl: 'http://www.test-winbits.com', name: 'Winbits Test'
    sinon.stub($.fancybox, "close")

    @envStub = sinon.stub(Winbits.env, 'get')
    .withArgs('current-vertical-id').returns(currentVertical.id)
    .withArgs('api-url').returns('https://apidev.winbits.com/v1')
    .withArgs('current-vertical').returns(currentVertical)
    .withArgs('verticals-data').returns([
      currentVertical
      { id: 2, baseUrl: 'http://dev.mylooq.com', name: 'My LOOQ/rpc' }
    ])

    @windowsOpenStub = sinon.stub(window, 'open').returns(focus: $.noop, closed:yes)
    @view = new NotLoggedInView
    @model = @view.model

  afterEach ->
    Winbits.Chaplin.mediator.data.set('first-entry', undefined )
    Winbits.env.get.restore()
    window.open.restore()
    utils.redirectTo.restore?()
    @view.doFacebookLoginSuccess.restore?()
    @model.requestExpressFacebookLogin.restore?()
    utils.showMessageModal.restore?()
    $.fancybox.close.restore?()
    @view.afterRender.restore?()
    @model.dispose()
    @view.dispose()

  it 'should render', ->
    expect(@view.$el).and.to.exist
      .and.to.has.classes ['miCuenta', 'login']
    expect(@view.$ '#wbi-register-link').to.exist
    expect(@view.$ '#wbi-login-btn').to.exist
    expect(@view.$ '#wbi-virtual-cart').to.exist

  it 'should redirect to #login when login button is clicked', ->
    utilsStub = sinon.stub utils, 'redirectTo'

    @view.$('#wbi-login-btn').click()

    expect(utilsStub).to.have.been.calledWith(controller: 'login', action: 'index')
      .and.to.have.been.calledOnce

  it 'should redirect to #register when register link is clicked', ->
    utilsStub = sinon.stub utils, 'redirectTo'

    @view.$('#wbi-register-link').click()

    expect(utilsStub).to.have.been.calledWith(controller: 'register', action: 'index')
      .and.to.have.been.calledOnce

  it 'should success popup facebook api', ->
    @view.publishEvent 'facebook-button-event'
    expect(@windowsOpenStub).have.been.calledWith('https://apidev.winbits.com/v1/users/facebook-login/connect?verticalId=1',
        "facebook", "menubar=0,resizable=0,width=980,height=500")
        .and.to.have.been.calledOnce

  it 'should success authentication facebook login/register', ->
    sinon.stub(@model, 'requestExpressFacebookLogin').returns TestUtils.promises.resolved
    sinon.stub(@view, 'doFacebookLoginSuccess').returns TestUtils.promises.resolved
    @view.publishEvent 'success-authentication-fb-register', {code: "success-authentication-fb-register",facebookId: "12549831832183",verticalId: "2"}
    expect(@model.requestExpressFacebookLogin).has.been.calledOnce

  it 'should error denied authentication facebook login/register', ->
    sinon.stub utils, 'showMessageModal'
    @view.publishEvent 'denied-authentication-fb-register', {code: "denied-authentication-fb-register",errorCode: "DAFR",verticalId: "2"}
    expect(utils.showMessageModal).has.been.calledOnce



  it 'should error denied permission facebook login/register', ->
    sinon.stub utils, 'showMessageModal'
    @view.publishEvent 'denied-permissions-fb-register', {code: "denied-permissions-fb-register",errorCode: "DPFR",verticalId: "2"}
    expect(utils.showMessageModal).has.been.calledOnce

  it 'should error email inactive in facebook login/register', ->
    sinon.stub utils, 'showMessageModal'
    @view.publishEvent 'email-inactive-fb-register', {code: "email-inactive-fb-register",errorCode: "EIFR",verticalId: "2"}
    expect(utils.showMessageModal).has.been.calledOnce