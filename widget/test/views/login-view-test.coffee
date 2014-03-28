LoginView = require 'views/login/login-view'
utils = require 'lib/utils'
$ = Winbits.$

describe 'Should do login', ->
    before ->
        $.validator.setDefaults({ ignore: [] });

    after ->
        $.validator.setDefaults({ ignore: ':hidden' });

    beforeEach ->
        @view = new LoginView autoAttach: false
        # sinon.spy($,"ajax")
        sinon.stub(@view, 'showAsModal')
        @view.attach()
        @view.$('[name=email]').val('test@winbits.com')
        @view.$('[name=password]').val('123456')

    afterEach ->
        @view.showAsModal.restore()
        @view.dispose()

    it 'login view renderized', ->
        expect(@view.$el).has.id('wbi-login-modal')
                .and.has.class('wbc-hide')
        expect(@view.$ '#wbi-login-form').is.rendered

    it 'do login should succed to Login', ->
        sinon.stub(utils, 'ajaxRequest').yieldsTo('success', {})
        successStub = sinon.stub(@view, 'doLoginSuccess')
        @view.$('#wbi-login-in-btn').click()

        successStub.calledOnce
        expect(@view.$ '.error').is.not.rendered

        utils.ajaxRequest.restore()

    it 'do not makes request if form invalid', ->
        ajaxRequestStub = sinon.stub(utils, 'ajaxRequest')
        @view.$('[name=password]').val('')
        @view.$('#wbi-login-in-btn').click()

        expect(ajaxRequestStub.called).to.be.false

        utils.ajaxRequest.restore()

    # it 'do login should throws an error to Login', ->
    #     util.validateForm = sinon.stub().returns(true)
    #     util.ajaxRequest = sinon.stub().returns('error')
    #     event = sinon.stub()
    #     response = @view.doLogin(event)
    #     expect(response).to.equal 'error'
