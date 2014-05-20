'use strict'
FavoriteView = require 'views/favorite/favorite-view'
Favorite = require 'models/favorite/favorite'
utils = require 'lib/utils'
favoriteUtils = require 'lib/favorite-utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$

describe 'FavoriteViewSpec', ->

  FAVORITE_URL = utils.getResourceURL('users/wish-list-items.json')
  FAVORITE_RESPONSE = '{"meta":{"status":200},"response":[{"id":1,"dateAdded":"2014-05-13T17:10:06Z","name":"Brand","logo":"http://www.google.com"},{"id":5,"dateAdded":"2014-05-13T20:46:11Z","name":"PATITO BRAND","logo":null}]}'
  FAVORITE_WITH_ONE_BRAND_RESPONSE = '{"meta":{"status":200},"response":[{"id":1,"dateAdded":"2014-05-13T17:10:06Z","name":"Brand","logo":"http://www.google.com"}]}'

  beforeEach ->
    @data = sinon.useFakeXMLHttpRequest()
    requests = @requests = []
    @data.onCreate = (data) -> requests.push(data)

    @model = new Favorite
    @view = new FavoriteView model: @model

  afterEach ->
    @data.restore()
    @view.dispose()
    @model.dispose()
    utils.showConfirmationModal.restore?()
    utils.ajaxRequest.restore?()
    favoriteUtils.publishWishListChangeEvent.restore?()
    favoriteUtils.showWishListErrorMessage.restore?()

  it 'favorite view renderized with no brands', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, "")
    expect(@view.$('div.addInfo')).to.exist


  it 'favorite view renderized with have at least one brand', ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, FAVORITE_RESPONSE)
    expect(@view.$('a.wbc-delete-brand-link')).to.exist

  it "should request get all brands", ->
    request = @requests[0]
    expect(request.method).to.be.equal('GET')
    expect(request.url).to.be.equal(FAVORITE_URL)

  it "With brand exist icon to delete it", ->
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, FAVORITE_RESPONSE)
    deleteButton =@view.$('a.wbc-delete-brand-link')
    expect(deleteButton).to.exist

  it "Should be called modal render", ->
    sinon.stub(@view,'doDeleteBrand')
    confirmationStub = sinon.stub(utils, 'showConfirmationModal')
    request = @requests[0]
    request.respond(200, { "Content-Type": "application/json" }, FAVORITE_WITH_ONE_BRAND_RESPONSE)
    @view.$('a.wbc-delete-brand-link').click()
    expect(confirmationStub).to.be.calledOnce


  it "Should delete brand from wish list", ->
    sinon.stub(utils, 'ajaxRequest').returns TestUtils.promises.resolved
    successStub = sinon.stub(favoriteUtils, 'publishWishListChangeEvent')
    errorStub = sinon.stub(favoriteUtils, 'showWishListErrorMessage')
    @view.doRequestDeleteBrand('1')
    expect(successStub).to.be.calledOnce
    expect(errorStub).to.not.be.calledOnce

  it "Should no delete brand from wish list with error in api", ->
    sinon.stub(utils, 'ajaxRequest').returns TestUtils.promises.rejected
    successStub = sinon.stub(favoriteUtils, 'publishWishListChangeEvent')
    errorStub = sinon.stub(favoriteUtils, 'showWishListErrorMessage')
    @view.doRequestDeleteBrand('1')
    expect(successStub).to.not.be.calledOnce
    expect(errorStub).to.be.calledOnce
