'use strict'
LoggedInController = require 'controllers/logged-in-controller'
CheckoutTempView = require 'views/checkout-temp/checkout-temp-view'
CheckoutTemp = require 'models/checkout-temp/checkout-temp'
utils = require 'lib/utils'

module.exports = class CheckoutController extends LoggedInController

  index: (params)->
    params ={"id":80,"email":"you_fhater@hotmail.com","orderNumber":"1406111237--80","itemsTotal":0,"shippingTotal":0,"bitsTotal":0,"total":0,"cashTotal":0,"status":"CHECKOUT","orderDetails":[],"paymentMethods":[{"id":1,"identifier":"user.bits","maxAmount":0,"minAmount":0,"displayOrder":0,"offline":false,"logo":null}],"vertical":{"id":2,"url":"http://dev.mylooq.com"},"shippingOrder":null,"cashback":0,"estimatedDeliveryDate":null,"failedCartDetails":[{"thumbnail":"http://d17puf58klsok4.cloudfront.net/Thumbnail/Thumbnail_2014392314_LEGO.jpg","name":"nameTo24","brand":{"id":1,"dateCreated":"2013-10-18T21:02:56-05:00","deleted":false,"description":"description","lastUpdated":"2013-10-18T21:02:56-05:00","logo":"http://www.google.com","name":"Brand","vertical":{"class":"Vertical","id":1}},"attributes":[{"name":"attribute1","label":"label1","value":"value1","type":"TEXT"}],"mainAttribute":{"name":"atributoName2","label":"atributoLabel","type":"TEXT","value":"AtributoLAbel"},"vertical":{"id":2,"active":true,"baseUrl":"http://dev.mylooq.com","logo":null,"maxPerVertical":100000,"name":"Looq","order":0}}]}
    if (params)
      @model = new CheckoutTemp params
      @view = new CheckoutTempView  model: @model
    else
      utils.redirectToLoggedInHome()