module.exports = (match) ->
  match '', 'home#index'
  match 'wb-login', 'login#index'
  match 'wb-logged-in', 'logged-in#index'
  match 'wb-not-logged-in', 'not-logged-in#index'
  match 'wb-register', 'register#index'
  match 'wb-recover-password', 'recover-password#index'
  match 'wb-reset-password', 'reset-password#index'
  match 'wb-complete-register', 'complete-register#index'
  match 'wb-bits-history', 'bits-history#index'
  match 'wb-shipping-order-history', 'shipping-order-history#index'
  match 'wb-transfer-cart-error', 'transfer-cart-errors#index'
  match 'wb-checkout-temp', 'checkout-temp#index'
  match 'wb-video', 'video#index'
  match 'wb-coupon', 'coupon#index'

  #Hash controller
  match 'wb-complete-register-:apiToken', 'hash#completeRegister'
  match 'wb-switch-user-:apiToken', 'hash#switchUser'
  match 'wb-reset-password-:salt', 'hash#resetPassword'

  #My Account Controller
  match 'wb-profile', 'my-account#index', params: tabId: 'wbi-my-profile-link'
  match 'wb-shipping-addresses', 'my-account#index', params: tabId: 'wbi-shipping-addresses-link'
  match 'wb-credit-cards', 'my-account#index', params: tabId: 'wbi-credit-cards-link'
  match 'wb-mailing', 'my-account#index', params: tabId: 'wbi-mailing-link'
  match 'wb-favorites', 'my-account#index', params: tabId: 'wbi-favorites-link'
  match 'wb-waiting-list', 'my-account#index', params: tabId: 'wbi-waiting-list-link'
  match 'wb-account-history', 'my-account#index', params: tabId: 'wbi-account-history-link'
