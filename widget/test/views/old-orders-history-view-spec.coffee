'use strict'
OldOrdersHistoryView = require 'views/old-orders-history/old-orders-history-view'
OldOrdersHistory = require 'models/old-orders-history/old-orders-history'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

describe 'OldOrdersHistoryViewSpec', ->

  OLD_ORDERS_HISTORY_RESPONSE = {
      "id": 2570990,
      "email": "emmanuel.maldonado@clickonero.com.mx",
      "firstName": "Emmanuel",
      "lastName": "Maldonado Cuña",
      "birthdate": 579333600000,
      "gender": "M",
      "referrerCode": "rzhwg1dyx6rmpd2",
      "registered": true,
      "enabled": true,
      "accountLocked": false,
      "merchantId": null,
      "merchantType": 0,
      "dateCreated": 1380890988000,
      "lastUpdated": 1403365451000,
      "phoneNumber": "51166854",
      "orders": [
          {
              "id": 868869,
              "orderStatus": "PAID",
              "dateCreated": 1412045904000,
              "paidDate": 1412046126000,
              "orderNumber": "1409292158--868869",
              "itemsTotal": 199,
              "total": 199,
              "code": null,
              "shippingStatus": "PENDING",
              "skus": [
                  {
                      "orderDetailId": 1210259,
                      "id": 633218,
                      "sku": "3318MUROXO022305BL00217865BEME",
                      "status": "AVAILABLE",
                      "cost": 199,
                      "itemId": 217865,
                      "itemType": "PRODUCT",
                      "availableWhileRunning": false,
                      "customCode": null,
                      "quantity": 1,
                      "shippingCost": 0,
                      "ean": "0.0",
                      "name": "Blusa Forest",
                      "path": "blusa-forest",
                      "shortDescription": "Blusa sin mangas",
                      "url": "//s3.amazonaws.com/store.media.clickonero.com.mx/media/item/00217865/J27aS-1",
                      "ext": "jpg",
                      "attributes": [
                          {
                              "attrName": "Color",
                              "label": "Beige",
                              "value": "#F6F4DF",
                              "valueType": "COLOR"
                          },
                          {
                              "attrName": "Talla",
                              "label": "Med",
                              "value": "M",
                              "valueType": "TEXT"
                          }
                      ],
                      "endDateCampaign": 1412312399000,
                      "dateDelivery": 1414040399000
                  }
              ],
              "shippingStatusMessage": "Pagada  y en espera de envio"
          }
      ]
  }

  beforeEach ->
    @loginData =
      apiToken: 'XXX'
      profile: { name: 'Jorge', lastName:"Moreno", gender:'male', birthdate:'1988-11-11', pendingOrdersCount:'0'}
      email: 'a@aa.aa'
      bitsBalance:100
    mediator.data.set 'login-data', @loginData
    sinon.stub(utils, "redirectTo")
    @model = new OldOrdersHistory (OLD_ORDERS_HISTORY_RESPONSE)
    @view = new OldOrdersHistoryView model: @model

  afterEach ->
    utils.redirectTo.restore()
    @view.dispose()
    @model.dispose()

  it "Should render table with orders", ->
    expect(@view.$('#wbi-shipping-order-link-text')).to.exist
    expect(@view.$('.dataTable-fila')).to.exist
    expect(@view.$('.dataTable')).to.exist
    expect(@view.$('#wbi-old-orders-history-btn-back')).to.exist

  it "Back to Shipping order history view", ->
    @view.$('#wbi-shipping-order-link').click()
    expect(utils.redirectTo).calledOnce

  it "Back to vertical", ->
    @view.$('#wbi-old-orders-history-btn-back').click()
    expect(utils.redirectTo).calledOnce

