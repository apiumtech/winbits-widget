'use strict'

NotLoggedInView =  require 'views/not-logged-in/not-logged-in-view'
NotLoggedIn =  require 'models/not-logged-in/not-logged-in'
utils = require 'lib/utils'
$ = Winbits.$

describe 'NotLoggedInViewSpec', ->

  beforeEach ->
    @model = new NotLoggedIn
    @view = new NotLoggedInView model:@model

  afterEach ->
    utils.redirectTo.restore?()
    window.open.restore?()
    $.fancybox.restore?()
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

  it 'should open popup facebook api', ->
    sinonPopup = sinon.stub @view, 'popupFacebookLogin'
    sinon.stub @view, 'facebookLoginInterval'
    sinon.stub window, 'open'
    @view.publishEvent 'facebook-button-event'
    expect(sinonPopup).have.been.calledOnce

  it 'should success popup facebook api', ->
    sinonPopup = sinon.stub @view, 'popupFacebookLogin'
    sinon.stub @view, 'facebookLoginInterval'
    sinon.stub window, 'open'
    @view.publishEvent 'facebook-button-event'
    expect(sinonPopup).have.been.calledOnce
