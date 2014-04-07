LoggedInView =  require 'views/logged-in/logged-in-view'
LoggedInModel = require 'models/logged-in/logged-in'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$


describe 'LoggedInViewSpec', ->
  'use strict'

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 0
    mediator.data.set 'login-data', @loginData
    @model = new LoggedInModel @loginData
    @view = new LoggedInView model: @model

  afterEach ->
    utils.ajaxRequest.restore?()
    @view.dispose()
    mediator.data.clear()

  it 'logged in view renderized', ->
    expect(@view.$el).to.has.class('miCuenta')
    expect(@view.$ '#wbi-my-account-link').to.exist
      .and.to.has.classes(['spanDropMenu', 'link'])
    expect(@view.$ '#wbi-my-bits').to.exist
      .and.to.has.class('bits')
      .and.to.has.text('0')
    expect(@view.$ '#wbi-my-cart').to.exist
      .and.to.has.class('spanDropMenu')
    expect(@view.$ 'input#wbi-checkout-btn').to.exist

  it 'do logout when clicked button', ->
    sinon.stub(@model, 'requestLogout').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doLogoutSuccess')
    @view.$('.miCuenta-logout').click()

    expect(successStub).to.be.calledOnce

  it 'do not logout when clicked button and apiToken does not exist', ->
    sinon.stub(@model, 'requestLogout').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doLogoutError')
    @view.$('.miCuenta-logout').click()

    expect(errorStub).to.be.calledOnce

