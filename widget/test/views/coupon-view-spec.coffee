'use strict'
CouponsView = require 'views/coupons/coupons-view'
Coupons = require 'models/coupons/coupons'
utils = require 'lib/utils'

describe 'CouponModalViewSpec', ->

  COUPON_SERVICE_RESPONSE =
    [{"orderDetailId":18,"id":3,"couponType":"NOT_AVAILABLE_WHILE_RUNNING","status":"AVAILABLE","filename":"champs1","code":"coupon_code","availableCouponDate":"08/07/2014","expireCouponDate":"66/66/6666"},
     {"orderDetailId":18,"id":4,"couponType":"Custom","status":"AVAILABLE","filename":"champs2","code":"coupon_code","availableCouponDate":null,"expireCouponDate":"66/66/6666"}]

  COUPON_SERVICE_RESPONSE_WITH_CREATE_STATUS =
    [{"orderDetailId":18,"id":3,"couponType":"NOT_AVAILABLE_WHILE_RUNNING","status":"AVAILABLE","filename":"champs1","code":"coupon_code","availableCouponDate":"08/07/2014","expireCouponDate":"66/66/6666"},
    {"orderDetailId":18,"id":4,"couponType":"Custom","status":"CREATED","filename":"champs2","code":"coupon_code","availableCouponDate":null,"expireCouponDate":"66/66/6666"}]


  beforeEach ->
    @model = new Coupons(coupons: COUPON_SERVICE_RESPONSE, description: "shortDescription",title: "ItemGroupProfile")
    @view = new CouponsView model: @model, autoAttach: no
    sinon.stub(@view, 'showAsModal')
    @view.attach()

  afterEach ->
    @view.showAsModal.restore()
    @view.dispose()
    @model.dispose()

  it 'coupon modal view renderized with all available coupons', ->
    expect(@view.$('#wbi-coupon-title').text()).equal('ItemGroupProfile')
    expect(@view.$('#wbi-coupon-description').text()).equal('shortDescription')
    expect(@view.$('.confirmationTable')).to.exist
    expect(@view.$('.wbc-download-pdf-link')).to.exist
    expect(@view.$('.wbc-download-html-link')).to.exist

  it 'coupon modal view renderized with not all available coupons', ->
    data= response :{coupons: COUPON_SERVICE_RESPONSE_WITH_CREATE_STATUS, description: "shortDescription",title: "ItemGroupProfile"}
    @model.setData(data)
    @view.render()
    expect(@view.$('#wbi-coupon-title').text()).equal('ItemGroupProfile')
    expect(@view.$('#wbi-coupon-description').text()).equal('shortDescription')
    expect(@view.$('.confirmationTable')).to.not.exist
    expect(@view.$('#wbi-no-availabe-coupons')).to.exist

  it 'when click in pdf icon call function', ->
    sinon.stub(@view,'doCouponPdfLink')
    sinon.stub @view,'doRequestCouponService'
    @view.$('.wbc-download-pdf-link').click()

  it 'when click in html icon call function', ->
    sinon.stub(@view,'doCouponHtmlLink')
    sinon.stub @view,'doRequestCouponService'
    @view.$('.wbc-download-html-link').click()
    expect(@view.doRequestCouponService).to.be.called