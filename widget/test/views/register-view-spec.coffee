'use strict'
RegisterView = require 'views/register/register-view'
Register = require 'models/register/register'
utils =  require 'lib/utils'
$ = Winbits.$
email = 'test@winbits.com'
password = "1234567"

describe 'RegisterViewSpec', ->

  before ->
    $.validator.setDefaults({ ignore: [] });

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    @server = sinon.fakeServer.create()
    @model = new Register
    @registerView = new RegisterView model:@model, autoAttach: no
    sinon.stub(@registerView, 'showAsModal')
    @registerView.attach()
    @registerView.$('[name=email]').val email
    @registerView.$('[name=password]').val password
    @registerView.$('[name=passwordConfirm]').val password

  afterEach ->
    @server.restore()
    @registerView.showAsModal.restore()
    utils.ajaxRequest.restore?()
    @registerView.dispose()

  it 'register view rendered',  ->
    expect(@registerView.$el).has.id('wbi-register-modal')
    expect(@registerView.$ '#wbi-register-form').is.rendered

  it 'do login should succed to Register', ->
    sinon.stub(@model, 'requestRegisterUser').returns TestUtils.promises.resolved
    successStub = sinon.stub(@registerView, 'doRegisterSuccess')
    @registerView.$('#wbi-register-button').click()
    expect(successStub).to.be.calledOnce
    expect(@registerView.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    sinon.stub(@model, 'requestRegisterUser')
    @registerView.$('[name=password]').val('')
    @registerView.$('#wbi-register-button').click()

    expect(@model.requestRegisterUser).to.not.be.called

  it 'show validation errors if form invalid', ->
    @registerView.$('[name=password]').val('')
    @registerView.$('#wbi-register-button').click()
    expect(@registerView.$ '.error').to.exist

