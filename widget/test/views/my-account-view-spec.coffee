MyAccountView = require 'views/my-account/my-account-view'
MyAccountModel = require 'models/my-account/my-account'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$


describe 'MyAccountViewSpec', ->
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
    @model = new MyAccountModel @loginData
    @view = new MyAccountView model: @model

  afterEach ->
    utils.ajaxRequest.restore?()
    @view.dispose?()
    @model.dispose?()
    mediator.data.clear?()

  it 'my account view renderized', ->
    expect(@view.$el).to.has.classes(['dropMenu','miCuentaDiv'])
    expect(@view.$ 'input#wbi-my-account-logout-btn').to.exist
    .and.to.has.class('btn').and.to.has.value("Salir")
    expect(@view.$ '#wbi-ajax-loading-layer').to.exist

  it 'do logout when clicked button', ->
    sinon.stub(@model, 'requestLogout').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doLogoutSuccess')
    @view.$('#wbi-my-account-logout-btn').click()
    expect(successStub).to.be.calledOnce

  it 'do not logout when clicked button and apiToken does not exist', ->
    sinon.stub(@model, 'requestLogout').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doLogoutError')
    @view.$('#wbi-my-account-logout-btn').click()
    expect(errorStub).to.be.calledOnce


