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
    data =
    {
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
      "zipCode": {
        "id": 52846,
        "zipCode": "55080",
        "allRelated": [
          {
            "class": "com.clickonero.hipstore.model.catalog.address.ZipCodeInfo",
            "id": 52845,
            "city": "Ecatepec de Morelos",
            "cityCode": "15",
            "county": "Ecatepec de Morelos",
            "countyCode": "4801",
            "locationCode": "31",
            "locationName": "Lomas de Ecatepec",
            "locationType": "Colonia",
            "postalOfficeCode": "55031",
            "state": "México",
            "stateCode": "15",
            "zipcode": "55080",
            "zone": "Urbano"
          }
        ]
      },
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
        },
        {
          "id": 482046,
          "orderStatus": "PAID",
          "dateCreated": 1387836551000,
          "paidDate": 1387836687000,
          "orderNumber": "1312231609--482046",
          "itemsTotal": 688,
          "total": 767,
          "code": null,
          "shippingStatus": "PENDING",
          "skus": [
            {
            "orderDetailId": 662147,
            "id": 385710,
            "sku": "3952MUROFE011786SU00117003ALCH",
            "status": "AVAILABLE",
            "cost": 189,
            "itemId": 117003,
            "itemType": "PRODUCT",
            "availableWhileRunning": false,
            "customCode": null,
            "quantity": 1,
            "shippingCost": 0,
            "ean": "0.0",
            "name": "Suéter Karen",
            "path": "sueter-karen",
            "shortDescription": "Suéter estampado de punto",
            "url": "//s3.amazonaws.com/store.media.clickonero.com.mx/media/item/00117003/yK63T-1",
            "ext": "jpg",
            "attributes": [
              {
              "attrName": "Color",
              "label": "Azul Marino",
              "value": "#0B0B61",
              "valueType": "COLOR"
              },
              {
              "attrName": "Talla",
              "label": "Small",
              "value": "S",
              "valueType": "TEXT"
              }
            ],
            "endDateCampaign": 1387951199000,
            "dateDelivery": 1389679199000
            },
            {
            "orderDetailId": 662148,
            "id": 390975,
            "sku": "3942HOELGE011949HO00118845PL",
            "status": "AVAILABLE",
            "cost": 499,
            "itemId": 118845,
            "itemType": "PRODUCT",
            "availableWhileRunning": false,
            "customCode": null,
            "quantity": 1,
            "shippingCost": 0,
            "ean": "JES0736SPSS",
            "name": "Microondas A.inox 700W 0.7 CU",
            "path": "microondas-ainox-700w-07-cu",
            "shortDescription": "MICRO 0.7 CU 700W STAINLESS STEEL",
            "url": "//s3.amazonaws.com/store.media.clickonero.com.mx/media/item/00118845/37vaq-1",
            "ext": "jpg",
            "attributes": [
              {
              "attrName": "Color",
              "label": "Plata",
              "value": "#C1C1C1",
              "valueType": "COLOR"
              }
            ],
            "endDateCampaign": 1388383199000,
            "dateDelivery": 1390111199000
            }
          ],
          "shippingStatusMessage": "Pagada  y en espera de envio"
        },
        {
          "id": 431036,
          "orderStatus": "PAID",
          "dateCreated": 1385583502000,
          "paidDate": 1385583505000,
          "orderNumber": "1311271418--431036",
          "itemsTotal": 0,
          "total": 0,
          "code": null,
          "shippingStatus": "PENDING",
          "skus": [
            {
            "orderDetailId": 598847,
            "id": 370050,
            "sku": "0001EXD.$2011051PRnullDEFAULTPPUAP",
            "status": "AVAILABLE",
            "cost": 0,
            "itemId": 111183,
            "itemType": "SERVICE",
            "availableWhileRunning": true,
            "customCode": false,
            "quantity": 1,
            "shippingCost": 0,
            "ean": "0000000000000000000000000",
            "name": "Oferta 3 de 6: $200 de regalo en Crédito clickOnero",
            "path": "x-200-de-regalo-en-credito-click-onero",
            "shortDescription": "Compra esta oferta a $0 y junta las 6 para que te abonemos el crédito clickonero",
            "url": "//s3.amazonaws.com/store.media.clickonero.com.mx/media/item/00111183/GR71h-1",
            "ext": "png",
            "attributes": [
              {
              "attrName": "Default Event Attribute",
              "label": "Default",
              "value": "Default",
              "valueType": "TEXT"
              }
            ],
            "endDateCampaign": 1386021599000,
            "dateDelivery": 1387749599000,
            "coupons": [
              {
              "id": 235944,
              "counter": 148,
              "randomCode": "fj7w15",
              "ccv": "hcu",
              "code": "148#fj7w15-hcu",
              "dateUsed": null,
              "enable": true
              }
            ],
            "claimEnd": 1386050399000
            }
          ],
          "shippingStatusMessage": "Pagada "
        }
        ],
      "oldCoupons": [],
      "puCoupons": []
    }

    @model = new OldOrdersHistory data
    @view = new OldOrdersHistoryView  model: @model