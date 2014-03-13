ModalLoginPageView = require 'views/modal-login/modal-login-view'
util = require 'lib/util'

class ModalLoginPageViewTest extends ModalLoginPageView
    render: ->
        super
        

    describe 'Should do login', ->
        beforeEach ->
            @view = new ModalLoginPageViewTest
            sinon.spy($,"ajax")
            util.serializeForm = sinon.stub().returns('{"user": "","password": "", "verticalId":""}')
            
        afterEach ->
            $.ajax.restore()
            @view.dispose()
            

        it 'do login with incomplete form', ->
            util.validateForm = sinon.stub().returns(false)
            event = sinon.stub()
            expect(@view.doLogin(event)).to.equal 'Fail to login 1'

        it 'do login should throws an error to Login', ->
            util.validateForm = sinon.stub().returns(true)
            util.ajaxRequest = sinon.stub().returns('error')
            event = sinon.stub()
            response = @view.doLogin(event)
            expect(response).to.equal 'error'
        
        it 'do login should succed to Login', ->
            util.validateForm = sinon.stub().returns(true)
            util.ajaxRequest = sinon.stub().returns('success')
            event = sinon.stub()
            response = @view.doLogin(event)
            expect(response).to.equal 'success'
            


