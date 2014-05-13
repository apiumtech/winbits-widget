'use strict'
favoriteUtils = require 'lib/favorite-utils'
utils = require 'lib/utils'
EventBroker = Chaplin.EventBroker
$ = Winbits.$

describe 'FavoriteUtilsSpec', ->

  FAVORITE_URL = utils.getResourceURL('users/wish-list-items.json')
  FAVORITE_URL_DELETE = utils.getResourceURL('users/wish-list-items/5.json')
  ADD_TO_FAVORITE_SUCCESS_RESPONSE = '{"meta":{"status":200},"response":[{"id":1,"dateAdded":"2014-05-13T17:10:06Z","name":"Brand","logo":"http://www.google.com"},{"id":5,"dateAdded":"2014-05-13T20:46:11Z","name":"PATITO BRAND","logo":null}]}'
  DELETE_FROM_FAVORITE_SUCCESS_RESPONSE = '{"meta":{"status":200},"response":[{"id":1,"dateAdded":"2014-05-13T17:10:06Z","name":"Brand","logo":"http://www.google.com"}]}'

  before ->
    sinon.stub(utils, 'getApiToken').returns('XXX')
    sinon.stub(utils, 'isLoggedIn').returns(yes)

  after ->
    utils.getApiToken.restore()
    utils.isLoggedIn.restore()

  beforeEach ->
    @xhr = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @xhr.onCreate = (xhr) -> requests.push(xhr)
    sinon.spy(utils, 'ajaxRequest')

  afterEach ->
    @xhr.restore()
    utils.ajaxRequest.restore()

  it 'should request to add brands to wish list', ->
    promise = favoriteUtils.addToWishList({brandId: '5'})
    expect(promise).to.be.promise
    request = @requests[0]
    expect(request.url).to.be.equal(FAVORITE_URL)
    expect(request.method).to.be.equal('POST')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')
    expect(request.requestBody).to.be.equal('{"brandId":"5"}')

  it 'should request to delete brands to wish list', ->
    promise = favoriteUtils.deleteFromWishList({brandId: '5'})
    expect(promise).to.be.promise
    request = @requests[0]
    expect(request.url).to.be.equal(FAVORITE_URL_DELETE)
    expect(request.method).to.be.equal('DELETE')
    expect(request.async).to.be.true
    expect(request.requestHeaders).to.has.property('Wb-Api-Token', 'XXX')
    expect(request.requestHeaders).to.has.property('Content-Type', 'application/json;charset=utf-8')

  it 'should trigger "favorites-changed" event when items successfully added to wish list', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('favorites-changed', stub)
    favoriteUtils.addToWishList({brandId: 5})
    respondSuccess.call(@, ADD_TO_FAVORITE_SUCCESS_RESPONSE)
    expect(stub).to.have.been.calledWith(JSON.parse(ADD_TO_FAVORITE_SUCCESS_RESPONSE))
        .and.to.be.calledOnce
    EventBroker.unsubscribeEvent('favorite-changed', stub)

  it 'should trigger "favorites-changed" event when items successfully deleted to wish list', ->
    stub = sinon.stub()
    EventBroker.subscribeEvent('favorites-changed', stub)
    favoriteUtils.deleteFromWishList({brandId: 5})
    respondSuccess.call(@, DELETE_FROM_FAVORITE_SUCCESS_RESPONSE)
    expect(stub).to.have.been.calledWith(JSON.parse(DELETE_FROM_FAVORITE_SUCCESS_RESPONSE))
        .and.to.be.calledOnce

    EventBroker.unsubscribeEvent('favorite-changed', stub)

  respondSuccess = (obj) ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, obj)


