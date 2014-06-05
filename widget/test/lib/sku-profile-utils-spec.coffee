'use strict'
skuProfileUtils = require 'lib/sku-profile-utils'
utils = require 'lib/utils'
$ = Winbits.$
mediator = Winbits.Chaplin.mediator

describe 'SkuProfileUtilsSpec', ->

  SKU_PROFILE_URL = utils.getResourceURL('catalog/sku-profiles/1/info.json')
  SKU_PROFILES_URL = utils.getResourceURL('catalog/sku-profiles-info.json')
  SKU_PROFILE_SUCCESS_RESPONSE = '{"meta":{"status":200},"response":{"id":14502,"status":{"id":1,"description":null,"name":"ACTIVE"},"quantityOnHand":1,"quantityReserved":1,"stock":0,"isInWishList":false}}'
  SKU_PROFILES_SUCCESS_RESPONSE = '{"meta":{"status":200},"response":[{"id":1,"status":{"id":1,"description":null,"name":"ACTIVE"},"quantityOnHand":-1,"quantityReserved":7,"stock":6,"isInWishList":false},{"id":2,"status":{"id":1,"description":null,"name":"ACTIVE"},"quantityOnHand":-1,"quantityReserved":3,"stock":0,"isInWishList":false},{"id":3,"status":{"id":1,"description":null,"name":"ACTIVE"},"quantityOnHand":-1,"quantityReserved":0,"stock":0,"isInWishList":false},{"id":4,"status":{"id":1,"description":null,"name":"ACTIVE"},"quantityOnHand":70,"quantityReserved":12,"stock":58,"isInWishList":false}]}'

  before ->
    sinon.stub(utils, 'isLoggedIn').returns(no)
    sinon.stub(utils, 'getApiToken').returns(undefined)


  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()

  beforeEach ->
    @loginData =
      id: 19
      apiToken: '6ue7zrBfNkxgNTvT4ReGpuh55yjNLRl6qEHiXMFyXFx6M3ymV21EaARwilDZK0zM'
      bitsBalance: 0
      profile:
        pendingOrdersCount: 2
    mediator.data.set 'login-data', @loginData
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    sinon.spy(utils, 'ajaxRequest')

  afterEach ->
    @xhr.restore()
    utils.ajaxRequest.restore()
    skuProfileUtils.skuProfileSuccessRequest.restore?()
    skuProfileUtils.skuProfileErrorRequest.restore?()

  it 'should request to get skus profile info when not logged user', ->
    promise = skuProfileUtils.getSkuProfilesInfo({ ids: [1, 2, 3, 4]})
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(SKU_PROFILES_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')
    expect(request.requestBody).to.be.equal('{"ids":"1,2,3,4"}')

  it 'should request to get sku profile info when not logged user', ->
    promise = skuProfileUtils.getSkuProfileInfo({ id: 1})
    expect(promise).to.be.promise
    request = @requests[0]
    expect(request.url).to.be.equal(SKU_PROFILE_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')

  it 'should request get sku profile info response success when not logged user', ->
    sinon.stub skuProfileUtils, 'skuProfileSuccessRequest'
    skuProfileUtils.getSkuProfileInfo({id:1})
    respondSuccess.call(@, SKU_PROFILE_SUCCESS_RESPONSE)
    expect(skuProfileUtils.skuProfileSuccessRequest).to.have.been.calledOnce

  it 'should request get skus profile info response success when not logged user', ->
    sinon.stub skuProfileUtils, 'skuProfileSuccessRequest'
    skuProfileUtils.getSkuProfilesInfo({ids:[1,2,3,4]})
    respondSuccess.call(@, SKU_PROFILES_SUCCESS_RESPONSE)
    expect(skuProfileUtils.skuProfileSuccessRequest).to.have.been.calledOnce

  it 'should request to get skus profile info when logged user', ->
    setLoginContext()
    promise = skuProfileUtils.getSkuProfilesInfo({ ids: [1, 2, 3, 4]})
    expect(promise).to.be.promise
    request = @requests[0]
    expect(request.url).to.be.equal(SKU_PROFILES_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')
    expect(request.requestBody).to.be.equal('{"userId":19,"ids":"1,2,3,4"}')

  it 'should request to get sku profile info when logged user', ->
    setLoginContext()
    promise = skuProfileUtils.getSkuProfileInfo({ id: 1})
    expect(promise).to.be.promise

    request = @requests[0]
    expect(request.url).to.be.equal(SKU_PROFILE_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')
    expect(request.requestBody).to.be.equal('{"userId":19}')

  it 'should request get sku profile info response success when logged user', ->
    setLoginContext()
    sinon.stub skuProfileUtils, 'skuProfileSuccessRequest'
    skuProfileUtils.getSkuProfileInfo({id:1})
    respondSuccess.call(@, SKU_PROFILE_SUCCESS_RESPONSE)
    expect(skuProfileUtils.skuProfileSuccessRequest).to.have.been.calledOnce

  it 'should request get skus profile info response success when logged user', ->
    setLoginContext()
    sinon.stub skuProfileUtils, 'skuProfileSuccessRequest'
    skuProfileUtils.getSkuProfilesInfo({ids:[1,2,3,4]})
    respondSuccess.call(@, SKU_PROFILES_SUCCESS_RESPONSE)
    expect(skuProfileUtils.skuProfileSuccessRequest).to.have.been.calledOnce

  respondSuccess = (obj) ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, obj)

  setLoginContext = () ->
    utils.getApiToken.returns('XXX')
    utils.isLoggedIn.returns(yes)
