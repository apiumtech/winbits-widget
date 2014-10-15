'use strict'
SwitchUserView = require 'views/switch-user/switch-user-view'
SwitchUser = require 'models/switch-user/switch-user'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$


describe 'SwitchUserViewSpec', ->

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 0
      switchUser: 'Jacinto@yahoo.es'
    mediator.data.set 'login-data', @loginData
    @model = new SwitchUser {switchUser:'Jacinto@yahoo.es'}
    @view = new SwitchUserView model: @model

  afterEach ->
    utils.ajaxRequest.restore?()
    @view.dispose()
    @model.dispose()
    mediator.data.clear()

  it 'switch user view renderized', ->
    $view = @view.$el
    expect($view.find('span.wbc-logout')).to.exist
    .and.to.has.classes(['iconFont-close', 'wbc-logout'])
    expect($view.find('em')).to.exist
    .and.to.has.text('Jacinto@yahoo.es')

  it 'do logout when clicked icon close switch user', ->
    sinon.stub(@model, 'requestLogout').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doLogoutSuccess')
    @view.$('#wbi-switch-user-logout').click()
    expect(successStub).to.be.calledOnce

  it 'do not logout when clicked icon close switch user and  apiToken does not exist', ->
    sinon.stub(@model, 'requestLogout').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doLogoutError')
    @view.$('#wbi-switch-user-logout').click()
    expect(errorStub).to.be.calledOnce

