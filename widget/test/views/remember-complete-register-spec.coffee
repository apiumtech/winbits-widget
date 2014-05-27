LoginView = require 'views/login/login-view'
LoginModel = require 'models/login/login'
utils = require 'lib/utils'
$ = Winbits.$
email = 'test@winbits.com'
password = '123456'

describe 'RememberCompleteRegisterModalSpec', ->
  'use strict'

  LOGIN_RESPONSE = '{"meta":{"status":200},"response":{"id":4,"email":"emmanuel.maldonado@clickonero.com.mx","apiToken":"mOm5rihnt2cHoXrBGxmpjyx8Z2XwwtTxm76jM5xzJYnaGtSSQ461YV88XQQmJTaE","bitsBalance":300,"profile":{"name":"Emmanuel","lastName":"Maldonado Cuña","birthdate":"1988-05-11","gender":"male","zipCodeInfo":{"id":1,"locationName":"Location","locationCode":"1","locationType":"1","county":"San Carlos","city":"Mexico","state":"Edo. Mex","zipCode":"11111"},"zipCode":"11111","location":"Location","phone":"55787098788","newsletterPeriodicity":"daily","newsletterFormat":"unified","wishListCount":0,"waitingListCount":0,"pendingOrdersCount":0},"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":false},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}],"subscriptions":[{"id":2,"name":"My Looq","active":true},{"id":3,"name":"Panda Sports","active":true},{"id":4,"name":"clickOnero","active":true}],"mainShippingAddres":{"id":6,"firstName":"PRUEBA","lastName":"PRUEBA","betweenStreets":null,"indications":"PRUEBA","main":true,"zipCodeInfo":{"id":1,"locationName":"Location","locationCode":"1","locationType":"1","county":"San Carlos","city":"Mexico","state":"Edo. Mex","zipCode":"11111"},"zipCode":"11111","location":"Location","county":"San Carlos","state":"Edo. Mex","lastName2":"PRUEBA","street":"PRUEBA","internalNumber":"PRUEB","externalNumber":"PRUEB","phone":"111111111111111"},"loginRedirectUrl":"http://localhost/widgets/logout.html","cashbackForComplete":100,"showRemainder":true}}'
  LOGIN_RESPONSE_FALSE = '{"meta":{"status":200},"response":{"id":4,"email":"emmanuel.maldonado@clickonero.com.mx","apiToken":"mOm5rihnt2cHoXrBGxmpjyx8Z2XwwtTxm76jM5xzJYnaGtSSQ461YV88XQQmJTaE","bitsBalance":300,"profile":{"name":"Emmanuel","lastName":"Maldonado Cuña","birthdate":"1988-05-11","gender":"male","zipCodeInfo":{"id":1,"locationName":"Location","locationCode":"1","locationType":"1","county":"San Carlos","city":"Mexico","state":"Edo. Mex","zipCode":"11111"},"zipCode":"11111","location":"Location","phone":"55787098788","newsletterPeriodicity":"daily","newsletterFormat":"unified","wishListCount":0,"waitingListCount":0,"pendingOrdersCount":0},"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":false},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}],"subscriptions":[{"id":2,"name":"My Looq","active":true},{"id":3,"name":"Panda Sports","active":true},{"id":4,"name":"clickOnero","active":true}],"mainShippingAddres":{"id":6,"firstName":"PRUEBA","lastName":"PRUEBA","betweenStreets":null,"indications":"PRUEBA","main":true,"zipCodeInfo":{"id":1,"locationName":"Location","locationCode":"1","locationType":"1","county":"San Carlos","city":"Mexico","state":"Edo. Mex","zipCode":"11111"},"zipCode":"11111","location":"Location","county":"San Carlos","state":"Edo. Mex","lastName2":"PRUEBA","street":"PRUEBA","internalNumber":"PRUEB","externalNumber":"PRUEB","phone":"111111111111111"},"loginRedirectUrl":"http://localhost/widgets/logout.html","cashbackForComplete":100,"showRemainder":false}}'

  before ->
    $.validator.setDefaults ignore: []

  after ->
    $.validator.setDefaults ignore: ':hidden'

  beforeEach ->
    @server = sinon.fakeServer.create()
    sinon.stub(utils,'redirectTo')

    currentVertical = id: 1, baseUrl: 'http://www.test-winbits.com', name: 'Winbits Test'
    sinon.stub(Winbits.env, 'get')
      .withArgs('current-vertical-id').returns(currentVertical.id)
      .withArgs('current-vertical').returns(currentVertical)
      .withArgs('verticals-data').returns([
        currentVertical,
        { id: 2, baseUrl: 'http://dev.mylooq.com', name: 'My LOOQ' }
      ])
    @model = new LoginModel
    @view = new LoginView model: @model, autoAttach: no
    sinon.stub(@view, 'showAsModal')
    @view.attach()
    @view.$('[name=email]').val email
    @view.$('[name=password]').val password

  afterEach ->
    @server.restore()
    @view.showAsModal.restore?()
    utils.ajaxRequest.restore?()
    utils.redirectTo.restore?()
    Winbits.env.get.restore?()

    @view.dispose()

  it 'should view remember complete register', ->
    utilsShowConfirmationCompleteRegister = sinon.stub(utils,'showConfirmationModal')
    @view.$('#wbi-login-in-btn').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, LOGIN_RESPONSE)
    expect(utilsShowConfirmationCompleteRegister).to.be.called
    utils.showConfirmationModal.restore()

  it 'should NOT view remember complete register', ->
    utilsShowConfirmationCompleteRegister = sinon.stub(utils,'showConfirmationModal')
    @view.$('#wbi-login-in-btn').click()
    @server.requests[0].respond(200, { "Content-Type": "application/json" }, LOGIN_RESPONSE_FALSE)
    expect(utilsShowConfirmationCompleteRegister).to.not.be.called
    utils.showConfirmationModal.restore()
