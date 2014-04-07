NotLoggedInView =  require 'views/not-logged-in/not-logged-in-view'
utils = require 'lib/utils'
$ = Winbits.$


describe 'NotLoggedInViewSpec', ->
  'use strict'

  beforeEach ->
    @view = new NotLoggedInView

  afterEach ->
    utils.redirectTo.restore?()
    @view.dispose()

  it 'should render', ->
    expect(@view.$el).to.has.classes ['miCuenta', 'login']
      .and.to.exist
    expect(@view.$ '#wbi-register-link').to.exist
    expect(@view.$ '#wbi-login-btn').to.exist
    expect(@view.$ '#wbi-cart-icon').to.exist

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
