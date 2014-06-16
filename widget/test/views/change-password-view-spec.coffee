'use strict'

ChangePasswordView = require 'views/change-password/change-password-view'
ChangePassword = require 'models/change-password/change-password'
utils = require 'lib/utils'
testUtils = require 'test/lib/test-utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'ChangePasswordViewSpec', ->

  before ->
    $.validator.setDefaults({ignore:[]})

  after ->
    $.validator.setDefaults({ignore:'hidden'})

  beforeEach ->
    @loginData =
      apiToken: 'XXX'
      profile: {}
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @model = new ChangePassword
    @model.set {password : 'qweqwe', newPassword : 'qweqwe', passwordConfirm : 'qweqwe'}
    @view = new ChangePasswordView model: @model
    sinon.stub(@view, 'doResetPasswordView')
    @view.attach()
    @view.$('input[type=password]').val('qweqwe')

  afterEach ->
    utils.ajaxRequest.restore?()
    @view.doResetPasswordView.restore?()
    @view.dispose()
    @model.dispose()

  it 'change password renderized', ->
    expect(@view.$ '#wbi-change-password-form').to.exist

  it 'do request should succeed to change password', ->
    sinon.stub(@model, 'requestChangePassword')
      .returns testUtils.resolvedPromiseWith(@view)
    sinon.stub(@view, 'doChangePasswordSuccess')
    @view.$('input[type=password]').val('qweqwe')
    @view.$('#wbi-change-password-btn').click()
    expect(@view.doChangePasswordSuccess).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    ajaxRequestStub = sinon.stub(@view, 'doChangePasswordError')
    @view.$('[name=password]').val('')
    @view.$('#wbi-change-password-btn').click()
    expect(ajaxRequestStub).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('[name=password]').val('')
    @view.$('#wbi-change-password-btn').click()
    expect(@view.$ '.error').to.exist

  it 'error is shown if api return error', ->
    sinon.stub(@model, 'requestChangePassword')
      .returns testUtils.rejectedPromiseWith(@view)
    errorStub = sinon.stub(@view, 'doChangePasswordError')
    @view.$('#wbi-change-password-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-change-password-btn').to.has.prop 'disabled', no

  it 'error is shown if request fail', ->
    xhr = responseText: 'Server error'
    sinon.stub(@model, 'requestChangePassword')
      .returns testUtils.rejectedPromiseWith(@view)
    errorStub = sinon.stub(@view, 'doChangePasswordError')
    @view.$('#wbi-change-password-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-change-password-btn').to.has.prop 'disabled', no
