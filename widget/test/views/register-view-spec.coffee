RegisterView = require 'views/register/register-view'
utils =  require 'lib/utils'
$ = Winbits.$

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
    @registerView.$('[name=email]').val('test@winbits.com')
    @registerView.$('[name=password]').val('1231')
    @registerView.$('[name=againPassword]').val('1231')

  afterEach ->
    @registerView.showAsModal.restore?()
    utils.ajaxRequest.restore?()
    @registerView.dispose()

  it 'register view rendered',  ->
    expect(@registerView.$el).has.id('wbi-register-modal')
          .and.has.class('wbc-hide')
    expect(@registerView.$ '#wbi-register-form').is.rendered

  it 'do succed Register test', ->
    sinon.stub(utils, 'ajaxRequest').yieldTo('success', {})
    successStub = sinon.stub(@registerView, 'doRegisterSuccess')
    @registerView.$('#wbi-register-button').click()
    expect(successStub).to.be.calledOnce
    expect(@registerView.$ '.error').to.not.be.rendered


 ###it 'do validate Register test failed', ->
    console.log 'error'

  it 'do error ajax Register test', ->
    console.log 'error'###