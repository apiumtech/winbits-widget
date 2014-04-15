'use strict'

ChangePasswordView = require 'views/change-password/change-password-view'
ChangePassword = require 'models/change-password/change-password'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'ChangePasswordViewSpec', ->

  before ->
#    $.validator.setDefaults({ ignore: [] });

  after ->
#    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    @loginData =
      apiToken: 'XXX'
      profile: {}
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @model = new ChangePassword
    @view = new ChangePasswordView model: @model
    @view.attach()

  afterEach ->
    utils.ajaxRequest.restore?()
    @view.dispose()
    @model.dispose()

  it 'change password renderized', ->
    expect(@view.$ '#wbi-change-password-form').to.exist

  it 'do request should succed to change password', ->
    $password = @view.$('input[type=password]').val('qweqwe')
    $password.val('qweqwe')
    $passwordNew = @view.$('input[type=newPassword]').val('qweqwe')
    $passwordNew.val('qweqwe')
    $passwordConf = @view.$('input[type=passwordConfirm]').val('qweqwe')
    $passwordConf.val('qweqwe')
    sinon.stub(@model, 'requestChangePassword').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doChangePasswordSuccess')
    @view.$('#wbi-change-password-btn').click()
#    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

#  it 'do not makes request if form invalid', ->
#    ajaxRequestStub = sinon.stub(@view, 'doChangePasswordError')
#    @view.$('[name=name]').val('')
#    @view.$('#wbi-change-password-btn').click()
#    expect(ajaxRequestStub).to.not.be.called
#
#  it.skip 'show validation errors if form invalid', ->
#    @view.$('[name=name]').val('')
#    @view.$('#wbi-change-password-btn').click()
#    expect(@view.$ '.error').to.exist
#
#  it 'error is shown if api return error', ->
#    sinon.stub(@model, 'requestChangePassword').returns TestUtils.promises.rejected
#    errorStub = sinon.stub(@view, 'doChangePasswordError')
#    @view.$('#wbi-change-password-btn').click()
#
#    expect(errorStub).to.be.calledOnce
#    expect(@view.$ '#wbi-change-password-btn').to.has.prop 'disabled', no
#
#  it 'error is shown if request fail', ->
#    xhr = responseText: 'Server error'
#    sinon.stub(@model, 'requestChangePassword').returns TestUtils.promises.rejected
#    errorStub = sinon.stub(@view, 'doChangePasswordError')
#    @view.$('#wbi-change-password-btn').click()
#
#    expect(errorStub).to.be.calledOnce
#    expect(@view.$ '#wbi-change-password-btn').to.has.prop 'disabled', no