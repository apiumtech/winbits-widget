config = require 'config'

module.exports =
  wbiAmexCardPayment:
    firstName:
      required: true
      minlength: 2
    lastName:
      required: true
      minlength: 2
    expirationMonth:
      required: true
      minlength: 2
      digits: true
      range: [1, 12]
    expirationYear:
      required: true
      minlength: 2
      digits: true
    cvv2Number:
      required: true
      digits: true
      minlength: 4
    street:
      required: true
      minlength: 2
    number:
      required: true
    zipCode:
      required: true
      minlength: 4
      digits: true
    phone:
      required: true
      minlength: 10
      digits: true
    city:
      required: true
      minlength: 2
    location:
      required: true
      minlength: 2
    county:
      required: true
      minlength: 2
    state:
      required: true
      minlength: 2
    cardNumber:
      required: true
      creditcard: true

  wbiAmexCardPaymentMsi:
        numberOfPayments:
          required: true
        cardNumber:
          required: true
          creditcard: true
          minlength: 2
          remote: 
            url: "#{config.apiUrl}/orders/cards/support-installment"
            success: (data) -> 
              console.log ["DATA", data]
              if not data
                Winbits.$("#method-amex_msi .selectContent").hide()
                Winbits.$("#method-amex_msi .selectTrigger").hide()
              else
                Winbits.$("#method-amex_msi .selectContent").show()
                Winbits.$("#method-amex_msi .selectTrigger").show()


  wbiCreditCardPayment :
    firstName:
      required: true
      minlength: 2
    lastName:
      required: true
      minlength: 2
    expirationMonth:
      required: true
      minlength: 2
      digits: true
      range: [1, 12]
    expirationYear:
      required: true
      minlength: 2
      digits: true
    cvNumber:
      required: true
      digits: true
      minlength: 3
    street1:
      required: true
      minlength: 2
    number:
      required: true
    postalCode:
      required: true
      minlength: 5
      digits: true
    phoneNumber:
      required: true
      minlength: 10
      digits: true
    state:
      required: true
      minlength: 2
    colony:
      required: true
      minlength: 2
    municipality:
      required: true
      minlength: 2
    city:
      required: true
      minlength: 2
    accountNumber:
      required: true
      creditcard: true
      minlength: 16

  wbiCreditCardPaymentMsi:
        totalMsi:
          required: true
          digits: true
          range: [1, 12]
        accountNumber:
          required: true
          creditcard: true
          minlength: 16
          remote: 
            url: "#{config.apiUrl}/orders/cards/support-installment"
            complete: (data) -> 
              if not data.responseJSON
                Winbits.$("#method-cybersource_msi .selectContent").hide()
                Winbits.$("#method-cybersource_msi .selectTrigger").hide()
                Winbits.$("#method-cybersource_msi .selectPreMessage").show()
                false
              else
                Winbits.$("#method-cybersource_msi .selectContent").show()
                Winbits.$("#method-cybersource_msi .selectTrigger").show()
                Winbits.$("#method-cybersource_msi .selectPreMessage").hide()
                Winbits.$("#wbi-credit-card-payment-form-msi label[for=totalMsi]").hide()
                true

