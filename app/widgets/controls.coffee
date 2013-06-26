module.exports = (app) ->
  app.initControls = ($) ->
    app.$widgetContainer.find(":input[placeholder]").placeholder()
    app.$widgetContainer.find("form").validate()

    #  var $form = Winbits.$widgetContainer.find('#wb-change-password-form');
    #  $form.find('.editBtn').click(function(e) {
    #    if (!Winbits.$widgetContainer.find('#wb-change-password-form').valid()) {
    #      e.stopImmediatePropagation();
    #    };
    #  });
    changeShippingAddress
      obj: ".shippingAddresses"
      objetivo: ".shippingItem"
      activo: "shippingSelected"
      inputradio: ".shippingRadio"

    customCheckbox ".checkbox"
    customRadio ".divGender"
    customSelect ".select"
    customSlider ".slideInput"
    customStepper ".inputStepper"
    dropMenu
      obj: ".miCuentaDiv"
      clase: ".dropMenu"
      trigger: ".triggerMiCuenta"
      other: ".miCarritoDiv"

    dropMenu
      obj: ".miCarritoDiv"
      clase: ".dropMenu"
      trigger: ".shopCarMin"
      other: ".miCuentaDiv"

    openFolder
      obj: ".knowMoreMin"
      trigger: ".knowMoreMin .openClose"
      objetivo: ".knowMoreMax"

    openFolder
      obj: ".knowMoreMax"
      trigger: ".knowMoreMax .openClose"
      objetivo: ".knowMoreMin"

    openFolder
      obj: ".myProfile .miPerfil"
      trigger: ".myProfile .miPerfil .editBtn"
      objetivo: ".myProfile .editMiPerfil"

    openFolder
      obj: ".myProfile .editMiPerfil"
      trigger: ".myProfile .editMiPerfil .editBtn"
      objetivo: ".myProfile .miPerfil"

    openFolder
      obj: ".myProfile .miPerfil"
      trigger: ".myProfile .miPerfil .changePassBtn"
      objetivo: ".myProfile .changePassDiv"

    openFolder
      obj: ".myProfile .changePassDiv"
      trigger: ".myProfile .changePassDiv .editBtn"
      objetivo: ".myProfile .miPerfil"

    openFolder
      obj: ".myAddress .miDireccion"
      trigger: ".myAddress .miDireccion .editBtn, .myAddress .miDireccion .changeAddressBtn"
      objetivo: ".myAddress .editMiDireccion"

    openFolder
      obj: ".myAddress .editMiDireccion"
      trigger: ".myAddress .editMiDireccion .editBtn"
      objetivo: ".myAddress .miDireccion"

    openFolder
      obj: ".mySuscription .miSuscripcion"
      trigger: ".mySuscription .miSuscripcion .editBtn, .mySuscription .miSuscripcion .editLink"
      objetivo: ".mySuscription .editSuscription"

    openFolder
      obj: ".mySuscription .editSuscription"
      trigger: ".mySuscription .editSuscription .editBtn"
      objetivo: ".mySuscription .miSuscripcion"

    openFolder
      obj: ".shippingAddresses"
      trigger: ".shippingAdd"
      objetivo: ".shippingNewAddress"

    openFolder
      obj: ".shippingNewAddress"
      trigger: ".submitButton .btnCancel"
      objetivo: ".shippingAddresses"

    sendEmail ".btnSmall"
    verticalCarousel ".carritoDivLeft .carritoContainer"
    console.log "Winibits Initialized"
