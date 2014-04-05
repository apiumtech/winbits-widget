LoggedInView =  require 'views/logged-in/logged-in-view'
LoggedInModel = require 'models/logged-in/logged-in'
utils = require 'lib/utils'
$ = Winbits.$


describe 'LoggedInView', ->
  'use strict'

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    model = new LoggedInModel
    @view = new LoggedInView model: model

  afterEach ->
    utils.ajaxRequest.restore?()
    LoggedInModel.requestLogout.restore?()
    @view.dispose()

  it 'logged in view renderized', ->
    expect(@view.$el).to.has.class('miCuenta')

  it 'do logout when clicked button', ->
    sinon.stub(LoggedInModel, 'requestLogout').yieldsTo('done',{})
    sinon.stub(utils, 'ajaxRequest').yieldsTo('success',{})
    successStub = sinon.stub(@view, 'doLogoutSuccess')
    @view.$('.miCuenta-logout').click()

    expect(successStub).to.be.calledOnce

  it 'dont logout when clicked button and apiToken does not exist', ->
    sinon.stub(LoggedInModel, 'requestLogout').yieldsTo('fail',{})
    sinon.stub(utils, 'ajaxRequest').yieldsTo('error',{})
    successStub = sinon.stub(@view, 'doLogoutError')
    @view.$('.miCuenta-logout').click()

    expect(successStub).to.be.calledOnce

