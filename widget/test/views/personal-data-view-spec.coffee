'use strict'

PersonalDataView = require 'views/personal-data/personal-data-view'
MyProfile = require 'models/my-profile/my-profile'
testUtils = require 'test/lib/test-utils'
utils = require 'lib/utils'
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

describe 'PersonalDataViewSpec', ->

  RESPONSE_CASHBACK_UPDATED = '{"meta":{"status":200},"response":{"id":109,"email":"you_fhater@hotmail.com","apiToken":"HMfRfZ55FFkK5A7OvdG06oTlbD9GoYSOq77EvskAjNd7DT7VQWYXB27IzIzELMT4","bitsBalance":130,"profile":{"name":"qweqwe","lastName":"qweqwe","birthdate":"1999-11-11","gender":"male","zipCodeInfo":{"id":1,"locationName":"qwqqq","locationCode":"1","locationType":"qwqq","county":"as","city":"mex","state":"qwq","zipCode":"11111"},"zipCode":"11111","location":"qwqqq","phone":"123123123123123","newsletterPeriodicity":"weekly","newsletterFormat":"unified","wishListCount":1,"waitingListCount":0,"pendingOrdersCount":1},"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":true},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}],"subscriptions":[{"id":2,"name":"Looq","active":false},{"id":3,"name":"Sportlet","active":false},{"id":4,"name":"clickOnero","active":false},{"id":16,"name":"vertical-23-d9XSuSr","active":false}],"mainShippingAddres":{"id":3,"firstName":"qweqwe","lastName":"qweqwe","betweenStreets":"qweqwe","indications":"qwe","main":true,"zipCodeInfo":{"id":1,"locationName":"qwqqq","locationCode":"1","locationType":"qwqq","county":"as","city":"mex","state":"qwq","zipCode":"11111"},"zipCode":"11111","location":"qwqqq","county":"as","state":"qwq","lastName2":null,"street":"qwe","internalNumber":"qwe","externalNumber":"qwe","phone":"1231231231"},"loginRedirectUrl":"http://localhost/widgets/logout.html","cashbackForComplete":100,"cashback":100}}'
  CASHBACK_UPDATED = {"meta":{"status":200},"response":{"id":109,"email":"you_fhater@hotmail.com","apiToken":"HMfRfZ55FFkK5A7OvdG06oTlbD9GoYSOq77EvskAjNd7DT7VQWYXB27IzIzELMT4","bitsBalance":130,"profile":{"name":"qweqwe","lastName":"qweqwe","birthdate":"1999-11-11","gender":"male","zipCodeInfo":{"id":1,"locationName":"qwqqq","locationCode":"1","locationType":"qwqq","county":"as","city":"mex","state":"qwq","zipCode":"11111"},"zipCode":"11111","location":"qwqqq","phone":"123123123123123","newsletterPeriodicity":"weekly","newsletterFormat":"unified","wishListCount":1,"waitingListCount":0,"pendingOrdersCount":1},"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":true},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}],"subscriptions":[{"id":2,"name":"Looq","active":false},{"id":3,"name":"Sportlet","active":false},{"id":4,"name":"clickOnero","active":false},{"id":16,"name":"vertical-23-d9XSuSr","active":false}],"mainShippingAddres":{"id":3,"firstName":"qweqwe","lastName":"qweqwe","betweenStreets":"qweqwe","indications":"qwe","main":true,"zipCodeInfo":{"id":1,"locationName":"qwqqq","locationCode":"1","locationType":"qwqq","county":"as","city":"mex","state":"qwq","zipCode":"11111"},"zipCode":"11111","location":"qwqqq","county":"as","state":"qwq","lastName2":null,"street":"qwe","internalNumber":"qwe","externalNumber":"qwe","phone":"1231231231"},"loginRedirectUrl":"http://localhost/widgets/logout.html","cashbackForComplete":100,"cashback":100}}
  RESPONSE_WITHOUT_CASHBACK_UPDATED = '{"meta":{"status":200},"response":{"id":109,"email":"you_fhater@hotmail.com","apiToken":"HMfRfZ55FFkK5A7OvdG06oTlbD9GoYSOq77EvskAjNd7DT7VQWYXB27IzIzELMT4","bitsBalance":130,"profile":{"name":"qweqwe","lastName":"qweqwe","birthdate":"1999-11-11","gender":"male","zipCodeInfo":{"id":1,"locationName":"qwqqq","locationCode":"1","locationType":"qwqq","county":"as","city":"mex","state":"qwq","zipCode":"11111"},"zipCode":"11111","location":"qwqqq","phone":"123123123123123","newsletterPeriodicity":"weekly","newsletterFormat":"unified","wishListCount":1,"waitingListCount":0,"pendingOrdersCount":1},"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":true},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}],"subscriptions":[{"id":2,"name":"Looq","active":false},{"id":3,"name":"Sportlet","active":false},{"id":4,"name":"clickOnero","active":false},{"id":16,"name":"vertical-23-d9XSuSr","active":false}],"mainShippingAddres":{"id":3,"firstName":"qweqwe","lastName":"qweqwe","betweenStreets":"qweqwe","indications":"qwe","main":true,"zipCodeInfo":{"id":1,"locationName":"qwqqq","locationCode":"1","locationType":"qwqq","county":"as","city":"mex","state":"qwq","zipCode":"11111"},"zipCode":"11111","location":"qwqqq","county":"as","state":"qwq","lastName2":null,"street":"qwe","internalNumber":"qwe","externalNumber":"qwe","phone":"1231231231"},"loginRedirectUrl":"http://localhost/widgets/logout.html","cashbackForComplete":100}}'
  WITHOUT_CASHBACK_UPDATED = {"meta":{"status":200},"response":{"id":109,"email":"you_fhater@hotmail.com","apiToken":"HMfRfZ55FFkK5A7OvdG06oTlbD9GoYSOq77EvskAjNd7DT7VQWYXB27IzIzELMT4","bitsBalance":130,"profile":{"name":"qweqwe","lastName":"qweqwe","birthdate":"1999-11-11","gender":"male","zipCodeInfo":{"id":1,"locationName":"qwqqq","locationCode":"1","locationType":"qwqq","county":"as","city":"mex","state":"qwq","zipCode":"11111"},"zipCode":"11111","location":"qwqqq","phone":"123123123123123","newsletterPeriodicity":"weekly","newsletterFormat":"unified","wishListCount":1,"waitingListCount":0,"pendingOrdersCount":1},"socialAccounts":[{"name":"Facebook","providerId":"facebook","logo":"facebook.png","available":true},{"name":"Twitter","providerId":"twitter","logo":"twitter.png","available":false}],"subscriptions":[{"id":2,"name":"Looq","active":false},{"id":3,"name":"Sportlet","active":false},{"id":4,"name":"clickOnero","active":false},{"id":16,"name":"vertical-23-d9XSuSr","active":false}],"mainShippingAddres":{"id":3,"firstName":"qweqwe","lastName":"qweqwe","betweenStreets":"qweqwe","indications":"qwe","main":true,"zipCodeInfo":{"id":1,"locationName":"qwqqq","locationCode":"1","locationType":"qwqq","county":"as","city":"mex","state":"qwq","zipCode":"11111"},"zipCode":"11111","location":"qwqqq","county":"as","state":"qwq","lastName2":null,"street":"qwe","internalNumber":"qwe","externalNumber":"qwe","phone":"1231231231"},"loginRedirectUrl":"http://localhost/widgets/logout.html","cashbackForComplete":100}}

  before ->
    sinon.stub($, 'ajax').returns(testUtils.promiseResolvedWithData())
    $.validator.setDefaults({ ignore: [] });


  after ->
    $.validator.setDefaults({ ignore: ':hidden' });
    $.ajax.restore()


  beforeEach ->
    @server = sinon.fakeServer.create()
    @loginData =
      apiToken: 'XXX'
      profile: { name: 'Jorge', lastName:"Moreno", gender:'male', birthdate:'1988-11-11'}
      email: 'a@aa.aa'
    mediator.data.set 'login-data', @loginData
    @model = new MyProfile @loginData
    @view = new PersonalDataView model: @model
    @view.attach()

    @view.$('[name=name]').val 'Jorge'
    @view.$('[name=lastname]').val 'Moreno'

    @view.$('#wbi-birthdate-day').val('11')
    @view.$('#wbi-birthdate-month').val('11')
    @view.$('#wbi-birthdate-year').val('11')
    @view.$('[name=zipCode]').val '12345'
    @view.$('#wbi-personal-data-zipCode').val('12345')
    @view.$('[name=zipCodeInfo]').wblocationselect('loadZipCode', '12345')
    @view.$('.wbc-gender-male').prev().addClass('radio-selected')

    sinon.stub utils, 'redirectTo'

  afterEach ->
    @server.restore()
    utils.redirectTo.restore()
    utils.ajaxRequest.restore?()
    utils.updateProfile.restore?()
    utils.publishEvent.restore?()
    utils.showMessageModal.restore?()
    @view.dispose()
    @model.dispose()


  it 'personal data renderized', ->
    expect(@view.$ '#wbi-personal-data-form').to.exist

  it 'should render profile form data with data', ->
    personalData = name: 'Jorge', lastName:"Moreno"
    @view.model.set personalData
    _.each personalData, (value, key) ->
      expect(@view.$ "[name=#{key}]").to.has.value value
    , @

  it 'should render gender', ->
    @view.model.set gender: 'male'
    expect(@view.$ '[name=gender][value=H]').to.be.wbRadioChecked
    expect(@view.$ '[name=gender][value=M]').to.be.wbRadioUnchecked

    @view.model.set gender: 'female'
    expect(@view.$ '[name=gender][value=M]').to.be.wbRadioChecked
    expect(@view.$ '[name=gender][value=H]').to.be.wbRadioUnchecked

  it 'do request should succed to update profile', ->
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doUpdateProfileSuccess')
    @view.$('#wbi-update-profile-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

  it 'do not makes request if form invalid', ->
    ajaxRequestStub = sinon.stub(@view, 'doUpdateProfileError')
    @view.$('[name=name]').val('')
    @view.$('#wbi-update-profile-btn').click()
    expect(ajaxRequestStub).to.not.be.called

  it 'show validation errors if form invalid', ->
    @view.$('[name=name]').val('')
    @view.$('#wbi-update-profile-btn').click()
    expect(@view.$ '.error').to.exist

  it 'error is shown if api return error', ->
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doUpdateProfileError')
    @view.$('#wbi-update-profile-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-update-profile-btn').to.has.prop 'disabled', no

  it 'error is shown if request fail', ->
    xhr = responseText: 'Server error'
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.rejected
    errorStub = sinon.stub(@view, 'doUpdateProfileError')
    @view.$('#wbi-update-profile-btn').click()

    expect(errorStub).to.be.calledOnce
    expect(@view.$ '#wbi-update-profile-btn').to.has.prop 'disabled', no

  it 'show validation errors if day is invalid', ->
    @view.$('#wbi-birthdate-day').val('58')
    @view.$('#wbi-birthdate-month').val('02')
    @view.$('#wbi-birthdate-year').val('02')
    @view.$('#wbi-update-profile-btn').click()
    expect(@view.$ '.error').to.exist

  it 'show validation errors if month is invalid', ->
    @view.$('#wbi-birthdate-day').val('08')
    @view.$('#wbi-birthdate-month').val('15')
    @view.$('#wbi-birthdate-year').val('02')
    @view.$('#wbi-update-profile-btn').click()
    expect(@view.$ '.error').to.exist

  it 'no show validation errors if date is valid', ->
    @view.$('#wbi-birthdate-day').val('18')
    @view.$('#wbi-birthdate-month').val('02')
    @view.$('#wbi-birthdate-year').val('02')
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    successStub = sinon.stub(@view, 'doUpdateProfileSuccess')
    @view.$('#wbi-update-profile-btn').click()
    expect(successStub).to.be.calledOnce
    expect(@view.$ '.error').to.not.exist

  it 'do request should succed to update with refactor', ->
    sinon.stub(@model, 'requestUpdateProfile').returns TestUtils.promises.resolved
    successStub = sinon.stub(utils, 'updateProfile')
    @view.$('#wbi-update-profile-btn').click()
    expect(successStub).to.be.calledOnce

  it 'do request should succed to update and win cashback bits', ->
    sinon.stub utils, "showMessageModal"
    updateProfile = sinon.stub utils, "updateProfile"
    sinon.stub utils, 'publishEvent'
      .withArgs('profile-changed', CASHBACK_UPDATED)
      .withArgs('cashback-bits-won', CASHBACK_UPDATED.response.cashback)
      .withArgs('bits-updated')
    @view.$('#wbi-update-profile-btn').click()
    expect(updateProfile).to.be.calledOnce

  it 'do request should succed to update and not win cashback bits', ->
    updateProfile = sinon.stub utils, "updateProfile"
    sinon.stub utils, 'publishEvent'
      .withArgs('profile-changed', WITHOUT_CASHBACK_UPDATED)
      .withArgs('bits-updated')
    sinon.stub utils, 'showMessageModal'
    @view.$('#wbi-update-profile-btn').click()
    expect(updateProfile).to.be.calledOnce

  it 'do request should succed to update, not win cashback bits and bitsBalance is different', ->
    updateProfile = sinon.stub utils, "updateProfile"
    sinon.stub utils, 'publishEvent'
      .withArgs('profile-changed', WITHOUT_CASHBACK_UPDATED)
      .withArgs('bits-updated')
    sinon.stub utils, 'showMessageModal'
    @view.$('#wbi-update-profile-btn').click()
    expect(updateProfile).to.be.calledOnce

  it 'do request should succed to update, not win cashback bits and bitsBalance is equal', ->
    $loginData = mediator.data.get 'login-data'
    updateProfile = sinon.stub utils, "updateProfile"
    $loginData.bitsBalance = 130
    mediator.data.set 'login-data', $loginData
    sinon.stub utils, 'showMessageModal'
    @view.$('#wbi-update-profile-btn').click()
    expect(updateProfile).to.be.calledOnce
