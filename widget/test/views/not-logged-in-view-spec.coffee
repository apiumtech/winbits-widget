'use strict'

NotLoggedInView =  require 'views/not-logged-in/not-logged-in-view'
NotLoggedIn =  require 'models/not-logged-in/not-logged-in'
utils = require 'lib/utils'
$ = Winbits.$


describe 'NotLoggedInViewSpec', ->
  @timeout 1500
  beforeEach ->
    @model = new NotLoggedIn
    @view = new NotLoggedInView model:@model
    currentVertical = id: 1, baseUrl: 'http://www.test-winbits.com', name: 'Winbits Test'
    @envStub =sinon.stub(Winbits.env, 'get')
    .withArgs('current-vertical-id').returns(currentVertical.id)
    .withArgs('api-url').returns('https://apidev.winbits.com/v1')
    .withArgs('current-vertical').returns(currentVertical)
    .withArgs('verticals-data').returns([
      currentVertical,
    { id: 2, baseUrl: 'http://dev.mylooq.com', name: 'My LOOQ' }
    ])
    @envStub.withArgs('rpc').returns(facebookStatus:(callback)->
      callback (status:'connected', authResponse:{userID:'100002184900102'})
    )

    @windowsOpenStub = sinon.stub(window, 'open').returns(focus: $.noop, closed:yes)




  afterEach ->
    utils.redirectTo.restore?()
    window.open.restore?()
#    $.fancybox.restore?()
    Winbits.env.get.restore?()
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
#    sinon.stub @view, 'facebookLoginInterval'
  #    sinonStub= sinon.stub(@model, 'requestExpressfacebookLogin')
    @view.publishEvent 'facebook-button-event'
#    expect(sinonStub).have.been.calledOnce


  it 'should error authentication facebook', ->
    sinon.stub @view, 'facebookLoginInterval'
#    stubModel = sinon.stub(@model, 'requestExpressfacebookLogin').returns TestUtils.promises.done
    console.log ['modeloTest', @model]
    @view.publishEvent 'facebook-button-event'
#    expect(stubModel).not.calledOnce