RegisterView = require 'views/register/register-view'
utils =  require 'lib/utils'
$ = Winbits.$
email = 'test@winbits.com'
password = "1234567"

describe 'test view register', ->
  'use strict'

  before ->
    $.validator.setDefaults({ ignore: [] });

  after ->
    $.validator.setDefaults({ ignore: ':hidden' });

  beforeEach ->
    @registerView = new RegisterView autoAttach: false
    sinon.stub(@registerView, 'showAsModal')
    @registerView.attach()
    @registerView.$('[name=email]').val email
    @registerView.$('[name=password]').val password
    @registerView.$('[name=passwordConfirm]').val password

  afterEach ->
    @registerView.showAsModal.restore?()
    utils.ajaxRequest.restore?()
    @registerView.dispose()

  it 'register view rendered',  ->
    expect(@registerView.$el).has.id('wbi-register-modal')
          .and.has.class('wbc-hide')
    expect(@registerView.$ '#wbi-register-form').is.rendered

  it 'do login should succed to Register', ->
    sinon.stub(utils, 'ajaxRequest').yieldsTo('success', {})
    successStub = sinon.stub(@registerView, 'doRegisterSuccess')
    @registerView.$('#wbi-register-button').click()
    console.log ['VALIDATION ERRORS', @registerView.$('input.error').attr('name'),
    @registerView.$('input.error').val(), @registerView.$('#password').val()]
    expect(successStub).to.be.calledOnce
    console.log "first test"
    expect(@registerView.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest')
    @registerView.$('[name=password]').val('')
    @registerView.$('#wbi-register-button').click()

    expect(ajaxRequestStub).to.not.be.called

  it 'show validation errors if form invalid', ->
    @registerView.$('[name=password]').val('')
    @registerView.$('#wbi-register-button').click()

    expect(@registerView.$ '.error').to.exist

  it 'error is shown if api return error', ->
    xhr = responseText: '{"meta":{"message":"Todo es culpa de Layún!"}}'
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest').yieldsToOn('error', @registerView, xhr)
    @registerView.$('#wbi-register-button').click()

    expectAjaxArgs.call(@, ajaxRequestStub, "Todo es culpa de Layún!")

  it 'error is shown if request fail', ->
    xhr = responseText: 'Server error'
    ajaxRequestStub = sinon.stub(utils, 'ajaxRequest').yieldsToOn('error', @registerView, xhr)
    @registerView.$('#wbi-register-button').click()

    expectAjaxArgs.call(@, ajaxRequestStub, "El servidor no está disponible, por favor inténtalo más tarde.")

  expectAjaxArgs = (ajaxRequestStub, errorText)->
    ajaxConfigArg = ajaxRequestStub.args[0][1]
    expect(ajaxConfigArg).to.has.property('context', @registerView)
    expect(ajaxConfigArg).to.has.property('data')
    .that.contain('"verticalId":1')
    expect(@registerView.$ '.errorDiv p').to.has.text(errorText)