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
      digits: true
      range: [1, 12]
    cardNumber:
      required: true
      creditcard: true
      minlength: 2
      wbiSupportInstallments:
        paymentMethod: 'amex'
        selector: 'numberOfPayments'

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
          wbiSupportInstallments:
            paymentMethod: 'cybersource'
            selector: 'totalMsi'
  
  successSupportInstallment: (data, method, select) -> 
    if not data.responseJSON
      Winbits.$("#method-#{method}_msi .selectContent").hide()
      Winbits.$("#method-#{method}_msi .selectTrigger").hide()
      Winbits.$("#method-#{method}_msi .selectPreMessage").show()
      false
    else
      Winbits.$("#method-#{method}_msi .selectContent").show()
      Winbits.$("#method-#{method}_msi .selectTrigger").show()
      Winbits.$("#method-#{method}_msi .selectPreMessage").hide()
      Winbits.$("#wbi-#{method}-card-payment-form label[for=#{select}]").hide()
      true
