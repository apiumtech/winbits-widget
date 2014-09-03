'use strict'
RegisterView = require 'views/register/register-view'
Register = require 'models/register/register'
utils =  require 'lib/utils'
$ = Winbits.$
email = 'test@winbits.com'
password = "1234567"

describe 'RegisterViewSpec', ->

  REGISTER_ERROR_RESPONSE_AFER001 = '{"meta":{"status":400,"message":"La cuenta de correo que intentas introducir ya existe","code":"AFER001"},"response":{}}'
  REGISTER_ERROR_RESPONSE_AFER026 = '{"meta":{"status":400,"message":"An unexpected API error ocurred","code":"AFER026"},"response":{"resendConfirmUrl":"/users/resend/emmanuel.maldonado@clickonero.com.mx"}}'
  REGISTER_URL = utils.getResourceURL 'users/register.json'

  before ->
    $.validator.setDefaults({ ignore: [] });

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    @server = sinon.fakeServer.create()
    @model = new Register
    @view = new RegisterView model:@model, autoAttach: no
    sinon.stub(@view, 'showAsModal')
    @view.attach()
    @view.$('[name=email]').val email
    @view.$('[name=password]').val password
    @view.$('[name=passwordConfirm]').val password

  afterEach ->
    @server.restore()
    @view.showAsModal.restore()
    utils.ajaxRequest.restore?()
    @view.dispose()

  it 'register view rendered',  ->
    expect(@view.$el).has.id('wbi-register-modal')
    expect(@view.$ '#wbi-register-form').is.rendered

  it 'do register should succed to Register', ->
    sinon.stub(@model, 'requestRegisterUser').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doRegisterSuccess')
    @view.$('#wbi-register-button').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    sinon.stub(@model, 'requestRegisterUser')
    @view.$('[name=password]').val('')
    @view.$('#wbi-register-button').click()

    expect(@model.requestRegisterUser).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('[name=password]').val('')
    @view.$('#wbi-register-button').click()
    expect(@view.$ '.error').to.exist

  it 'should call doRegisterError when the server respond with error', ->
    sinon.stub(@view, 'doRegisterError')
    @view.$('#wbi-register-button').click()
    @server.requests[0].respond(400, {"Content-Type":"aplication/json"},REGISTER_ERROR_RESPONSE_AFER001)
    expect( @view.doRegisterError).to.have.been.callOnce
    expect( @server.requests[0].url).to.have.been.equals REGISTER_URL
    expect( @server.requests[0].responseText).to.have.been.equals REGISTER_ERROR_RESPONSE_AFER001


  it 'should call shwMessageErrorModal when the server respond with error', ->
    sinon.stub(@view, 'showMessageErrorModal')
    @view.$('#wbi-register-button').click()
    @server.requests[0].respond(400, {"Content-Type":"aplication/json"},REGISTER_ERROR_RESPONSE_AFER001)
    expect( @view.doRegisterError).to.have.been.callOnce
    expect( @view.showMessageErrorModal).to.have.been.callOnce

  it 'should call showMessageErrorModal when the server respond with error with User not confirmed', ->
    sinon.stub(@view, 'showMessageErrorModal')
    @view.$('#wbi-register-button').click()
    @server.requests[0].respond(400, {"Content-Type":"aplication/json"},REGISTER_ERROR_RESPONSE_AFER026)
    expect( @view.doRegisterError).to.have.been.callOnce
    expect( @view.showMessageErrorModal).to.have.been.callOnce

  it 'should publish event facebook-button-event', ->
    stub = sinon.stub @view, 'publishEvent'
    @view.$('#wbi-facebook-link').click()
    expect(stub).to.have.been.calledOnce
