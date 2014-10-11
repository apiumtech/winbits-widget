'use strict'
LoggedInController = require 'controllers/logged-in-controller'
OldOrdersHistoryView = require 'views/old-orders-history/old-orders-history-view'
OldOrdersHistory = require 'models/old-orders-history/old-orders-history'
utils = require 'lib/utils'

module.exports = class OldOrdersHistoryController extends LoggedInController

  beforeAction: ->
    super

  index: ->
    console.log ["old-orders-view"]
    DATA_ORDERS =
      [
        {
          "id":868869,
          "orderStatus":"PAID",
          "dateCreated":1412045904000,
          "paidDate":1412046126000,
          "orderNumber":"1409292158--868869",
          "itemsTotal":199,
          "total":199,
          "code":null,
          "shippingStatus":"PENDING",
          "skus":
            [
              {
                "orderDetailId":1210259,
                "id":633218,
                "sku":"3318MUROXO022305BL00217865BEME",
                "status":"AVAILABLE",
                "cost":199,
                "itemId":217865,
                "itemType":"PRODUCT",
                "availableWhileRunning":false,
                "customCode":null,
                "quantity":1,
                "shippingCost":0,
                "ean":"0.0",
                "name":"Blusa Forest",
                "path":"blusa-forest",
                "shortDescription":"Blusa sin mangas",
                "url":"//s3.amazonaws.com/store.media.clickonero.com.mx/media/item/00217865/J27aS-1",
                "ext":"jpg",
                "attributes":
                  [
                    {
                      "attrName":"Color",
                      "label":"Beige",
                      "value":"#F6F4DF",
                      "valueType":"COLOR"
                    },
                    {
                      "attrName":"Talla",
                      "label":"Med",
                      "value":"M",
                      "valueType":"TEXT"
                    }
                  ]
                "endDateCampaign":1412312399000,
                "dateDelivery":1414040399000
              }
            ]
          "shippingStatusMessage":"Pagada  y en espera de envio"
        },
        {
          "id":868869,
          "orderStatus":"PAID",
          "dateCreated":1412045904000,
          "paidDate":1412046126000,
          "orderNumber":"1409292158--868869",
          "itemsTotal":199,
          "total":199,
          "code":null,
          "shippingStatus":"PENDING",
          "skus":
            [
             {
              "orderDetailId":1210259,
              "id":633218,
              "sku":"3318MUROXO022305BL00217865BEME",
              "status":"AVAILABLE",
              "cost":199,
              "itemId":217865,
              "itemType":"PRODUCT",
              "availableWhileRunning":false,
              "customCode":null,
              "quantity":1,
              "shippingCost":0,
              "ean":"0.0",
              "name":"Blusa Forest",
              "path":"blusa-forest",
              "shortDescription":"Blusa sin mangas",
              "url":"//s3.amazonaws.com/store.media.clickonero.com.mx/media/item/00217865/J27aS-1",
              "ext":"jpg",
              "attributes":
                [
                 {
                  "attrName":"Color",
                  "label":"Beige",
                  "value":"#F6F4DF",
                  "valueType":"COLOR"
                 },
                 {
                  "attrName":"Talla",
                  "label":"Med",
                  "value":"M",
                  "valueType":"TEXT"
                 }
                ]
              "endDateCampaign":1412312399000,
              "dateDelivery":1414040399000
             }
            ]
          "shippingStatusMessage":"Pagada  y en espera de envio"
        }
      ]
    @model=new OldOrdersHistory(orders: DATA_ORDERS)
    @view=new OldOrdersHistoryView  model: @model