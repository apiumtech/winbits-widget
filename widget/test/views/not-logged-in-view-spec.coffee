'use strict'

NotLoggedInView =  require 'views/not-logged-in/not-logged-in-view'
NotLoggedIn =  require 'models/not-logged-in/not-logged-in'
utils = require 'lib/utils'
$ = Winbits.$
rpc = Winbits.env.get('rpc')

describe 'NotLoggedInViewSpec', ->
  beforeEach ->
    @clock = sinon.useFakeTimers()
    currentVertical = id: 1, baseUrl: 'http://www.test-winbits.com', name: 'Winbits Test'
    sinon.stub($.fancybox, "close")

    @envStub = sinon.stub(Winbits.env, 'get')
    .withArgs('current-vertical-id').returns(currentVertical.id)
    .withArgs('api-url').returns('https://apidev.winbits.com/v1')
    .withArgs('current-vertical').returns(currentVertical)
    .withArgs('rpc').returns(rpc)
    .withArgs('verticals-data').returns([
      currentVertical
      { id: 2, baseUrl: 'http://dev.mylooq.com', name: 'My LOOQ' }
    ])

    @windowsOpenStub = sinon.stub(window, 'open').returns(focus: $.noop, closed:yes)
    @view = new NotLoggedInView
    @model = @view.model

  afterEach ->
    @clock.restore()
    Winbits.env.get.restore()
    window.open.restore()

    rpc.facebookStatus.restore?()
    utils.redirectTo.restore?()
    @view.facebookLoginInterval.restore?()
    @view.doFacebookLoginSuccess.restore?()
    @view.doFacebookLoginError.restore?()
    @model.requestExpressFacebookLogin.restore?()
    $.fancybox.close.restore?()

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
    sinon.stub @view, 'facebookLoginInterval'
    @view.publishEvent 'facebook-button-event'
    expect(@windowsOpenStub).have.been.calledWith('https://apidev.winbits.com/v1/users/facebook-login/connect?verticalId=1',
        "facebook", "menubar=0,resizable=0,width=800,height=500")
        .and.to.have.been.calledOnce

  it 'should success authentication facebook', ->
    sinon.stub(rpc, 'facebookStatus', (callback)->
      callback (status:'connected', authResponse:{userID:'100002184900102'})
    )
    sinon.stub(@view, 'doFacebookLoginSuccess')
    sinon.stub(@view, 'doFacebookLoginError')
    sinon.stub(@model, 'requestExpressFacebookLogin').returns TestUtils.promises.resolved
    @view.publishEvent 'facebook-button-event'
    @clock.tick(150)
    expect(@model.requestExpressFacebookLogin).to.have.been.calledOnce
    expect(@view.doFacebookLoginSuccess).to.have.been.calledOnce
    expect(@view.doFacebookLoginError).to.have.been.not.calledOnce

  it 'should error authentication facebook', ->
    sinon.stub(rpc, 'facebookStatus', (callback)->
      callback (status:'connected', authResponse:{userID:'100002184900102'})
    )
    sinon.stub(@view, 'doFacebookLoginSuccess')
    sinon.stub(@view, 'doFacebookLoginError')
    sinon.stub(@model, 'requestExpressFacebookLogin').returns TestUtils.promises.rejected
    @view.publishEvent 'facebook-button-event'
    @clock.tick(150)
    expect(@model.requestExpressFacebookLogin).to.have.been.calledOnce
    expect(@view.doFacebookLoginSuccess).to.have.been.not.calledOnce
    expect(@view.doFacebookLoginError).to.have.been.calledOnce


  it 'should error authorization facebook', ->
    sinon.stub(rpc, 'facebookStatus', (callback)->
      callback (status:'not-authorized', authResponse:{userID:'100002184900102'})
    )
    sinon.stub(@model, 'requestExpressFacebookLogin')
    @view.publishEvent 'facebook-button-event'
    @clock.tick(150)
    expect(@model.requestExpressFacebookLogin).not.calledOnce