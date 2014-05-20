'use strict'

_ = Winbits._

specs = [
  './models/header-spec'
  './views/not-logged-in-view-spec'
  './views/logged-in-view-spec'
  './views/header-view-spec'
  './views/register-view-spec'
  './views/login-view-spec'
  './views/my-account-view-spec'
  './views/recover-password-view-spec'
  './views/reset-password-view-spec'
  './views/personal-data-view-spec'
  './views/social-media-view-spec'
  './views/change-password-view-spec'
  './views/shipping-addresses-view-spec'
  './views/mailing-view-spec'
  './views/new-shipping-address-view-spec'
  './views/edit-shipping-address-view-spec'
  './views/complete-register-view-spec'
  './other/jquery-location-select-spec'
  './views/cart/cart-view-spec'
  './views/cart/cart-items-view-spec'
  './views/cart/cart-totals-view-spec'
  './views/cart/cart-bits-view-spec'
  './views/cart/cart-payment-methods-view-spec'
  './models/virtual-cart-spec'
  './models/cart-spec'
  './views/virtual-cart-view-spec'
  './lib/cart-utils-spec'
  './winbits-spec'
  './lib/utils-spec'
  './lib/favorite-utils-spec'
  './views/cards/cards-view-spec'
  './models/cards/cards-spec'
  './views/cards/new-card-view-spec'
  './models/cards/card-spec'
  './views/cards/edit-card-view-spec'
  './views/switch-user-view-spec'
  './views/favorite-view-spec'
  './views/account-history-view-spec'
  './other/jquery-wbpaginator-spec'
]

for spec in _.unique(specs)
  console.log ['Executing Spec -> ', spec]
  require spec
