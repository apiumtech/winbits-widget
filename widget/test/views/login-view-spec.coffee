LoginView = require 'views/login/login-view'
utils = require 'lib/utils'
$ = Winbits.$

describe 'Should do login', ->
    'use strict'

    before ->
        $.validator.setDefaults({ ignore: [] });

    after ->
        $.validator.setDefaults({ ignore: ':hidden' });

    beforeEach ->
        @view = new LoginView autoAttach: false
        sinon.stub(@view, 'showAsModal')
        @view.attach()
        @view.$('[name=email]').val('test@winbits.com')
        @view.$('[name=password]').val('123456')

    afterEach ->
        @view.showAsModal.restore?()
        utils.ajaxRequest.restore?()

        @view.dispose()

    it 'login view renderized', ->
        expect(@view.$el).to.has.id('wbi-login-modal')
                .and.to.has.class('wbc-hide')
        expect(@view.$ '#wbi-login-form').to.be.rendered

    it 'do login should succed to Login', ->
        sinon.stub(utils, 'ajaxRequest').yieldsTo('success', {})
        successStub = sinon.stub(@view, 'doLoginSuccess')
        @view.$('#wbi-login-in-btn').click()

        successStub.calledOnce
        expect(@view.$ '.error').to.be.not.rendered

    it 'do not makes request if form invalid', ->
        ajaxRequestStub = sinon.stub(utils, 'ajaxRequest')
        @view.$('[name=password]').val('')
        @view.$('#wbi-login-in-btn').click()

        expect(ajaxRequestStub.called).to.be.false

    it 'show validation errors if form invalid', ->
        @view.$('[name=password]').val('')
        @view.$('#wbi-login-in-btn').click()

        expect(@view.$ '.error').to.be.rendered

    it 'error is shown if api return error', ->
        xhr = responseText: '{"meta":{"message":"Todo es culpa de Layún!"}}'
        ajaxRequestStub = sinon.stub(utils, 'ajaxRequest').yieldsToOn('error', @view, xhr)
        @view.$('#wbi-login-in-btn').click()

        expect(ajaxRequestStub.args[0][1]).to.has.property('context', @view)
        expect(@view.$ '.errorDiv p').to.has.text("Todo es culpa de Layún!")

    it 'error is shown if request fail', ->
        xhr = responseText: 'Server error'
        ajaxRequestStub = sinon.stub(utils, 'ajaxRequest').yieldsToOn('error', @view, xhr, 'Todo es culpa de Layún!')
        @view.$('#wbi-login-in-btn').click()

        expect(ajaxRequestStub.args[0][1]).to.has.property('context', @view)
        expect(@view.$ '.errorDiv p').to.has.text("Todo es culpa de Layún!")
