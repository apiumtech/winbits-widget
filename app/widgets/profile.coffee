module.exports = (app) ->

  app.loadUserProfile = ($, profile) ->
    console.log ["Loading user profile", profile]
    me = profile.profile
    app.$widgetContainer.find(".wb-user-bits-balance").text me.bitsBalance
    $myProfilePanel = app.$widgetContainer.find(".miPerfil")
    $myProfileForm = app.$widgetContainer.find(".editMiPerfil")
    $myProfilePanel.find(".profile-full-name").text (me.name or "") + " " + (me.lastName or "")
    $myProfileForm.find("[name=name]").val me.name
    $myProfileForm.find("[name=lastName]").val me.lastName
    $myProfilePanel.find(".profile-email").text(profile.email).attr "href", "mailto:" + profile.email
    if me.birthdate
      $myProfilePanel.find(".profile-age").text me.birthdate
      $myProfileForm.find(".day-input").val me.birthdate.substr(8, 2)
      $myProfileForm.find(".month-input").val me.birthdate.substr(5, 2)
      $myProfileForm.find(".year-input").val me.birthdate.substr(2, 2)
    $myProfileForm.find("[name=gender]." + me.gender).attr("checked", "checked").next().addClass "spanSelected"  if me.gender
    $myProfilePanel.find(".profile-location").text (if me.location then "Col." + me.location else "")
    $myProfilePanel.find(".profile-zip-code").text (if me.zipCode then "CP." + me.zipCode else "")
    $myProfileForm.find("[name=zipCode]").val me.zipCode
    $myProfilePanel.find(".profile-phone").text (if me.phone then "Tel." + me.phone else "")
    $myProfileForm.find("[name=phone]").val me.phone
    address = profile.mainShippingAddress
    if address
      $myAddressPanel = app.$widgetContainer.find(".miDireccion")
      $myAddressPanel.find(".address-street").text (if address.street then "Col." + address.street else "")
      $myAddressPanel.find(".address-location").text (if address.location then "Col." + address.location else "")
      $myAddressPanel.find(".address-state").text (if address.zipCodeInfo.state then "Del." + address.zipCodeInfo.state else "")
      $myAddressPanel.find(".address-zip-code").text (if address.zipCodeInfo.zipCode then "CP." + address.zipCodeInfo.zipCode else "")
      $myAddressPanel.find(".address-phone").text (if address.phone then "Tel." + address.phone else "")
    subscriptions = profile.subscriptions
    if subscriptions
      $mySubscriptionsPanel = app.$widgetContainer.find(".miSuscripcion")
      $subscriptionsList = $mySubscriptionsPanel.find(".wb-subscriptions-list")
      $subscriptionsChecklist = app.$widgetContainer.find(".wb-subscriptions-checklist")
      $.each subscriptions, (i, subscription) ->
        $("<li>" + subscription.name + "<a href=\"#\" class=\"editLink\">edit</a></li>").appendTo $subscriptionsList  if subscription.active
        $verticalCheck = $("<input type=\"checkbox\" class=\"checkbox\"><label class=\"checkboxLabel\"></label>")
        $checkbox = $($verticalCheck[0])
        $checkbox.attr "value", subscription.id
        $checkbox.attr "checked", "checked"  if subscription.active
        $($verticalCheck[1]).text subscription.name
        $subscriptionsChecklist.append $verticalCheck
        customCheckbox $checkbox
