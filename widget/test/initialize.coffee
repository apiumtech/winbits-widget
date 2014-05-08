
specs = [
  # './models/header-spec'
  # './views/not-logged-in-view-spec'
  # './views/logged-in-view-spec'
  # './views/header-view-spec'
  # './views/register-view-spec'
  # './views/login-view-spec'
  # './views/my-account-view-spec'
  # './views/recover-password-view-spec'
  # './views/reset-password-view-spec'
  # './views/personal-data-view-spec'
  # './views/social-media-view-spec'
  # './views/change-password-view-spec'
  # './views/shipping-addresses-view-spec'
  # './views/new-shipping-address-view-spec'
  # './views/complete-register-view-spec'
  # './other/jquery-location-select-spec'
  # './other/jquery-location-select-spec'
  # './views/cart-view-spec'
  # './views/cart-items-view-spec'
  # './views/cart-totals-view-spec'
  # './views/cart-bits-view-spec'
  # './views/cart-payment-methods-view-spec'
  # './models/virtual-cart-spec'
  # './models/cart-spec'
  # './views/virtual-cart-view-spec'
  # './lib/cart-utils-spec'
  # './winbits-spec'
  # './lib/utils-spec'
  './views/cards-view-spec'
  './models/cards-spec'
]

for spec in specs
    console.log ['Executing Spec -> ', spec]
    require spec
