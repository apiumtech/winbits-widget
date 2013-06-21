(function(){
// +++++++++++++++++++++++++++++++++++++++++++++
//      ACCORDEON: Acordeón para el historial
// +++++++++++++++++++++++++++++++++++++++++++++

  window.WinbitsControls = {
	accordeon: function (options){
		if($(options.obj).length){
			if(options.first){
				$(options.obj).find(options.trigger).first().addClass(options.claseActivo)
				.find('.icon').toggleClass(options.minusIcon);
				$(options.obj).find(options.contenedor).not(':first').hide();
			} else {
				$(options.obj).find(options.contenedor).hide();
			}
			$(options.obj).find(options.trigger).click(function(){
				$(this).next(options.contenedor).slideToggle().siblings(options.contenedor+':visible').slideUp();
				$(this).toggleClass(options.claseActivo).find('.icon').toggleClass(options.minusIcon);
				$(this).siblings(options.trigger).removeClass(options.claseActivo).find('.icon').removeClass(options.minusIcon);
			});
		}
	},

// ++++++++++++++++++++++++++++++++
//      ADDEVENT: Atachar evento
// ++++++++++++++++++++++++++++++++

	addEvent: function ( obj, type, fn ){
		if (obj.addEventListener){
			obj.addEventListener( type, fn, false );
		} else if (obj.attachEvent){
			obj["e"+type+fn] = fn;
			obj[type+fn] = function(){ obj["e"+type+fn]( window.event ); };
			obj.attachEvent( "on"+type, obj[type+fn] );
		}
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CHANGEBOX: Cambiar div para seleccionar direccion/tarjeta
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	changeBox: function (options) {
		if($(options.obj).length){
			$(options.objetivo).each(function(){
				var $this = $(this);
				$this.click(function(){
					quitaClase({obj: options.objetivo, clase: options.activo});
					uncheck(options.inputradio);
					$this.addClass(options.activo);
					$this.find('input').attr('checked', true);
				});
			});
		}
	},

// +++++++++++++++++++++++++++++++++++++++++
//      CUSTOMCHECKBOX: Cambiar checkbox
// +++++++++++++++++++++++++++++++++++++++++

	customCheckbox: function (obj){
		if($(obj).length){
			$(obj).each(function(){
				var $this = $(this),
					$clase;
				if($this.prop('checked')){
					$clase = 'selectCheckbox';
				} else {
					$clase = 'unselectCheckbox';
				}
				$(this).next().andSelf().wrapAll('<div class="divCheckbox"/>');
				$this.parent().prepend('<span class="icon spanCheckbox '+$clase+'"/>');
				$this.parent().find('.spanCheckbox').click(function(){
					if($this.prop('checked')){
						$(this).removeClass('selectCheckbox');
						$(this).addClass('unselectCheckbox');
						$this.attr('checked', false);
					} else {
						$(this).removeClass('unselectCheckbox');
						$(this).addClass('selectCheckbox');
						$this.attr('checked', true);
					}
				});
			});
		}
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMRADIO: Cambiar radio buttons por input text para el género
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	customRadio: function (obj){
		if($(obj).length){
			$(obj).find('input[type="radio"]').each(function(){
				var $this = $(this);
				$this.wrap('<div class="divRadio"/>');
				$this.parent().append('<span class="spanRadio">'+$(this).val()+'</span>');
				$this.parent().find('.spanRadio').click(function(){
					if($this.prop('checked')){
						unchecRadio(obj);
					} else {
						unchecRadio(obj);
						$this.attr('checked', true);
						$(this).addClass('spanSelected');
					}
				});
			});
		}
	},

	unchecRadio: function (obj){
		var $radio = $(obj).find('input[type="radio"]');
		$radio.each(function(){
			$(this).attr('checked', false);
			$(this).parent().find('.spanRadio')
			.removeClass('spanSelected');
		});
	},

// +++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSELECT: Customizar el select
// +++++++++++++++++++++++++++++++++++++++++++

	customSelect: function (obj){
		if($(obj).length){
			$(obj).each(function () {
				var $this = $(this),
				numberOfOptions = $(this).children('option').length,
				selectContent;
				$this.addClass('selectHidden');
				$this.wrap('<div class="selectContainer"/>');
				if($this.data('clase')){
					$this.parent().addClass($this.data('clase'));
				}
				if($this.data('inputselect')) {
					selectContent = '<input type="text" class="selectContent">';
				} else {
					selectContent = '<span class="selectContent"/>';
				}
				$this.after(selectContent+'<span class="icon selectTrigger"/>');
				var $styledSelect = $this.next('.selectContent');
				if($this.data('inputselect')) {
					$styledSelect.attr('placeholder',$this.children('option').eq(0).text())
					.addClass($this.children('option').eq(0).data('icon'));
				} else {
					$styledSelect.text($this.children('option').eq(0).text())
					.addClass($this.children('option').eq(0).data('icon'));
				}
				var $list = $('<ul />', {
					'class': 'selectOptions'
				}).insertAfter($this.parent().find('span.selectTrigger'));
				for (var i = 0; i < numberOfOptions; i++) {
					$('<li />', {
						text: $this.children('option').eq(i).text(),
						rel: $this.children('option').eq(i).val(),
						'data-class': $this.children('option').eq(i).data('icon')
					}).appendTo($list);
				}
				var $listItems = $list.children('li');
				$this.parent().find('span.selectTrigger').click(function (e) {
					e.stopPropagation();
					$('div.styledSelect.active').each(function () {
						$(this).removeClass('active').next('ul.selectOptions').hide();
					});
					$(this).toggleClass('active').next('ul.selectOptions').toggle();
				});
				$listItems.click(function (e) {
					e.stopPropagation();
					if($this.data('inputselect')) {
						$styledSelect.val($(this).text()).removeClass('active')
						.removeClass().addClass('selectActive selectContent '+$(this).data('class'));
					} else {
						$styledSelect.text($(this).text()).removeClass('active')
						.removeClass().addClass('selectActive selectContent '+$(this).data('class'));
					}
					$this.val($(this).attr('rel'));
					$list.hide();
				});
				$(document).click(function () {
					$styledSelect.removeClass('active');
					$list.hide();
				});
			});
		}
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSLIDER: Deslizar el rango para cambiar valor de bits
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	customSlider: function (obj){
		if($(obj).length) {
			$(obj).each(function(){
				var $this = $(this);
				$this.wrap('<div class="slider"><div class="slider-holder"/>');
				$this.parent().append('<a href="#" class="ui-slider-handle"><span class="bit"></span><span class="amount">$<em>'+$this.val()+'</em></span></a>');
				$this.parent().parent().append('<span class="text-value min-val">'+$this.data('min')+'</span><span class="text-value max-val">'+$this.data('max')+'</span>');
				$this.parent().parent().find('.slider-holder').slider({
					range: 'min',
					value: +$this.val(),
					min: +$this.data('min'),
					max: +$this.data('max'),
					slide: function(event, ui){
						$this.val(ui.value);
						$this.parent().find('.amount em').text(ui.value);
					},
					step: $this.data('step')
				});
			});
		}
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSTEPPER: Sumar y restar valores del stepper
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	customStepper: function (obj) {
    var $obj = $(obj);
    if($obj.length){
      $obj.each(function(){
        $(this).wrap('<div class="stepper"/>');
        var $this = $(this).parent();
        $this.append('<span class="icon plus"/><span class="icon minus"/>');
        $this.find('.icon').click(function(){
          var $newVal,
            $button = $(this),
            $oldValue = parseInt($button.parent().find("input").val(), 10);
          if ($button.hasClass('plus')) {
            $newVal = $oldValue + 1;
          } else if ($button.hasClass('minus')){
            if ($oldValue >= 2) {
              $newVal = $oldValue - 1;
            } else {
              $newVal = 1;
            }
          }
          $button.parent().find("input").val($newVal).trigger('step', $oldValue);
        });
        $this.find('input').keydown(function (e) {
          var keyCode = e.keyCode || e.which,
            arrow = {up: 38, down: 40 },
            $newVal,
            $oldValue = parseInt($(this).val(), 10);
          switch (keyCode) {
            case arrow.up:
              $newVal = $oldValue + 1;
            break;
            case arrow.down:
              $newVal = $oldValue - 1;
            break;
          }
          if($newVal >= 1) {
            $(this).val($newVal).trigger('step', $oldValue);
          }
        });
      });
		}
    return obj;
	},

// +++++++++++++++++++++++++++++++++++
//      DROPMENU: Abrir los menús
// +++++++++++++++++++++++++++++++++++

	dropMenu: function (options){
		if($(options.obj).length){
			$(options.trigger).click(function(){
				$(options.other).slideUp();
				$(options.obj).slideDown();
			});
			$(options.obj).each(function(){
				var $objeto;
				if (options.carro === true) {
					$objeto = $(this).find('.wrapper').children().eq(0);
				} else {
					$objeto = $(this).find('.wrapper');
				}
				$objeto.bind({
					click: function(e){
						e.stopPropagation();
					},
					mouseenter: function(){
						$(this).slideDown();
					},
					mouseleave: function(){
						$(document).click(function(){
							$(options.obj).slideUp();
							$(document).unbind('click');
						});
					}
				});
			});
		}
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      OPENFOLDER: Abrir el DIV superior del encabezado
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	openFolder: function (options){
		if($(options.obj).length){
			$(options.trigger).click(function(){
				$(options.obj).slideUp();
				$(options.objetivo).slideDown();
			});
		}
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      QUITACLASE: Remover todas las clases con una iteración
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	quitaClase: function (options){
		$(options.obj).each(function(){
			$(this).removeClass(options.clase);
		});
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      UNCHECK: Iterar para remover el checked en radiobutton y checkbox
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	uncheck: function (obj) {
		$(obj).each(function(){
			$(this).attr('checked', false);
		});
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      VALIDAR: Validar formularios
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	validar: function (obj) {
		if($(obj.container).length) {
			$(obj.form).validate({
				errorClass: 'errorInputError',
				errorElement: 'span',
				errorLabelContainer: obj.container+' .errorDiv p',
				showErrors: function (errorMap, errorList){
					var err = this.numberOfInvalids();
					if (err) {
						$(obj.label).html('Verifique el(los) <strong>'+ err +'</strong> error(es):');
					} else {
						$(obj.label).html('');
					}
					this.defaultShowErrors();
				},
				onfocusout: function (element) {
					$(element).valid();
				},
				success: function (label) {
					label.addClass('errorInputOK');
				},
				rules: obj.rules,
				validClass: 'errorInputOK'
			});
		}
	},

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      VERTICALCAROUSEL: Carrusel vertical para carrito
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	verticalCarousel: function (obj){
		if($(obj).length){
			$(obj).each(function(){
				if($(obj).parent().parent().parent().parent().css('display') === 'none'){
					$(obj).parent().parent().parent().parent().show();
				}
				if (!($(this).parent().find('.upDownDiv').length)) {
					$(this).parent().append('<div class="upDownDiv"><span class="icon upCarritoDiv">&uarr;</span><span class="icon downCarritoDiv">&darr;</span></div>');
				}
				var $this = $(this),
					$content = $this.find('.'+$this.data('content')),
					$upButton = $this.parent().find('.upCarritoDiv'),
					$downButton = $this.parent().find('.downCarritoDiv'),
					$bothButton = $this.parent().find('.upDownDiv span.icon'),
					$margin = parseInt($content.css('marginTop'), 10),
					$height = -(parseInt($content.css('height'), 10) - parseInt($this.css('height'), 10));
        WinbitsControls.viewUpDownDiv(obj);
				if ($margin >= 0){
					$downButton.addClass('deactivate');
				} else if ($margin <= $height) {
					$upButton.addClass('deactivate');
				}
				$bothButton.click(function(){
					if(!($(this).hasClass('deactivate'))){
						var $plusLessMargin;
						if($(this).hasClass('upCarritoDiv')){
							$downButton.removeClass('deactivate');
							$plusLessMargin = '-=100';
						} else if($(this).hasClass('downCarritoDiv')){
							$upButton.removeClass('deactivate');
							$plusLessMargin = '+=100';
						}
						$margin = parseInt($content.css('marginTop'), 10);
						$content.animate({
							marginTop: $plusLessMargin
						},400, function(){
							$margin = parseInt($content.css('marginTop'), 10);
							if($margin >= 0){
								$upButton.removeClass('deactivate');
								$downButton.addClass('deactivate');
							} else if($margin <= $height){
								$downButton.removeClass('deactivate');
								$upButton.addClass('deactivate');
							}
						});
					} else {
						$upButton.removeClass('deactivate');
						$downButton.addClass('deactivate');
						$content.animate({
							marginTop: 0
						});
					}
				});
				$(obj).parent().parent().parent().parent().hide();
			});
		}
	},

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      VIEWUPDOWNDIV: Visibilidad de las flechas del carrito
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	viewUpDownDiv: function(obj) { // viewUpDownDiv('.carritoDivLeft .carritoContainer')
		var $altoContainer = parseInt($(obj).css('height'), 10),
			$altoContent = parseInt($(obj).find('.'+$(obj).data('content')).css('height'), 10);
		if($altoContent < $altoContainer){
			$(obj).parent().find('.upDownDiv').hide();
		}
	}
  };

  jQuery.extend(jQuery.validator.messages, {
    required: "Campo requerido.",
    remote: "Llena este campo.",
    email: "Escribe una dirección de correo válida",
    url: "Escribe una URL válida.",
    date: "Escribe una fecha válida.",
    dateISO: "Escribe una fecha (ISO) válida.",
    number: "Escribe un número entero válido.",
    digits: "Escribe sólo dígitos.",
    creditcard: "Escribe un número de tarjeta válido.",
    equalTo: "Escribe el mismo valor de nuevo.",
    accept: "Escribe un valor con una extensión aceptada.",
    maxlength: jQuery.validator.format("No escribas más de {0} caracteres."),
    minlength: jQuery.validator.format("No escribas menos de {0} caracteres."),
    rangelength: jQuery.validator.format("Escribe un valor entre {0} y {1} caracteres."),
    range: jQuery.validator.format("Escribe un valor entre {0} y {1}."),
    max: jQuery.validator.format("Escribe un valor menor o igual a {0}."),
    min: jQuery.validator.format("Escribe un valor mayor o igual a {0}.")
  });

  WinbitsControls.init = function() {
    WinbitsControls.accordeon({
      obj: '.accordeonWinbits',
      trigger: 'h2',
      first: false, // Si quieren que sea abra el primer elemento en la carga, poner TRUE
      claseActivo: 'activo',
      contenedor: '.accordeonContent',
      minusIcon: 'minusIcon'
    });
    WinbitsControls.changeBox({
      obj: '.shippingAddresses',
      objetivo: '.shippingItem',
      activo: 'shippingSelected',
      inputradio: '.shippingRadio'
    });
    WinbitsControls.changeBox({
      obj: '.creditcards',
      objetivo: '.creditcardItem',
      activo: 'creditcardSelected',
      inputradio: '.creditcardRadio'
    });
    WinbitsControls.customCheckbox('.checkbox');
    WinbitsControls.customRadio('.divGender');
    WinbitsControls.customSelect ('.select');
    WinbitsControls.customSlider('.slideInput');
    WinbitsControls.customStepper('.inputStepper');
    WinbitsControls.dropMenu({
      obj: '.miCuentaDiv',
      clase: '.dropMenu',
      trigger: '.triggerMiCuenta, .miCuenta .link',
      other: '.miCarritoDiv'
    });
    WinbitsControls.dropMenu({
      obj: '.miCarritoDiv',
      clase: '.dropMenu',
      trigger: '.shopCarMin',
      other: '.miCuentaDiv',
      carro: true
    });
    WinbitsControls.openFolder({
      obj: '.knowMoreMin',
      trigger: '.knowMoreMin .openClose',
      objetivo: '.knowMoreMax'
    });
    WinbitsControls.openFolder({
      obj: '.knowMoreMax',
      trigger: '.knowMoreMax .openClose',
      objetivo: '.knowMoreMin'
    });
    WinbitsControls.openFolder({
      obj: '.myProfile .miPerfil',
      trigger:  '.myProfile .miPerfil .editBtn',
      objetivo: '.myProfile .editMiPerfil'
    });
    WinbitsControls.openFolder({
      obj: '.myProfile .editMiPerfil',
      trigger: '.myProfile .editMiPerfil .editBtn',
      objetivo: '.myProfile .miPerfil'
    });
    WinbitsControls.openFolder({
      obj: '.myProfile .miPerfil',
      trigger: '.myProfile .miPerfil .changePassBtn',
      objetivo: '.myProfile .changePassDiv'
    });
    WinbitsControls.openFolder({
      obj: '.myProfile .changePassDiv',
      trigger: '.myProfile .changePassDiv .editBtn',
      objetivo: '.myProfile .miPerfil'
    });
    WinbitsControls.openFolder({
      obj: '.myAddress .miDireccion',
      trigger: '.myAddress .miDireccion .editBtn, .myAddress .miDireccion .changeAddressBtn',
      objetivo: '.myAddress .editMiDireccion'
    });
    WinbitsControls.openFolder({
      obj: '.myAddress .editMiDireccion',
      trigger: '.myAddress .editMiDireccion .editBtn',
      objetivo: '.myAddress .miDireccion'
    });
    WinbitsControls.openFolder({
      obj: '.mySuscription .miSuscripcion',
      trigger: '.mySuscription .miSuscripcion .editBtn, .mySuscription .miSuscripcion .editLink',
      objetivo: '.mySuscription .editSuscription'
    });
    WinbitsControls.openFolder({
      obj: '.mySuscription .editSuscription',
      trigger: '.mySuscription .editSuscription .editBtn',
      objetivo: '.mySuscription .miSuscripcion'
    });
    WinbitsControls.openFolder({
      obj: '.shippingAddresses',
      trigger: '.shippingAdd',
      objetivo: '.shippingNewAddress'
    });
    WinbitsControls.openFolder({
      obj: '.shippingNewAddress',
      trigger: '.submitButton .btnCancel',
      objetivo: '.shippingAddresses'
    });
    WinbitsControls.openFolder({
      obj: '.creditcards',
      trigger: '.creditcardAdd',
      objetivo: '.creditcardNew'
    });
    WinbitsControls.openFolder({
      obj: '.creditcardNew',
      trigger: '.creditcardNew .btnCancel',
      objetivo: '.creditcards'
    });
    WinbitsControls.openFolder({
      obj: '.checkoutPaymentCreditcard',
      trigger: '.checkoutPaymentCreditcard .btnCheckout',
      objetivo: '.checkoutPaymentCreditValidate'
    });
    WinbitsControls.openFolder({
      obj: '.checkoutPaymentCreditValidate',
      trigger: '.checkoutPaymentCreditValidate .btnCancel',
      objetivo: '.checkoutPaymentCreditcard'
    });
    WinbitsControls.openFolder({
      obj: '.checkoutPaymentCreditcard',
      trigger: '.paymentMethod .debitCreditCard',
      objetivo: '.checkoutPaymentNewCard'
    });
    WinbitsControls.openFolder({
      obj: '.checkoutPaymentNewCard',
      trigger: '.checkoutPaymentNewCard .btnCancel',
      objetivo: '.checkoutPaymentCreditcard'
    });
    WinbitsControls.openFolder({
      obj: '.checkoutPaymentCreditcard',
      trigger: '.paymentMethod .cashDeposit',
      objetivo: '.checkoutPaymentCash'
    });
    WinbitsControls.openFolder({
      obj: '.checkoutPaymentCreditcard',
      trigger: '.paymentMethod .paypalPay',
      objetivo: '.checkoutPaymentPayPal'
    });
    WinbitsControls.openFolder({
      obj: '.checkoutPaymentCreditcard',
      trigger: '.paymentMethod .oxxoPay',
      objetivo: '.checkoutPaymentOxxo'
    });
    WinbitsControls.validar({
      container: '.editMiPerfil',
      form: '#editMiPerfil'
    });
    WinbitsControls.validar({
      container: '.changePassDiv',
      form: '#changePassDiv',
      rules: {
        winbitsPasswordNewAgain: {
          equalTo: '#winbitsPasswordNew'
        }
      }
    });
    WinbitsControls.validar({
      container: '.shippingNewAddress',
      form: '#shippingNewAddress'
    });
    WinbitsControls.validar({
      container: '.editMiDireccion',
      form: '#editMiDireccion'
    });
    WinbitsControls.validar({
      container: '.creditcardNew',
      form: '#creditcardNew'
    });
    WinbitsControls.validar({
      container: '.checkoutPaymentCreditValidate',
      form: '#checkoutPaymentCreditValidate'
    });
    WinbitsControls.validar({
      container: '.checkoutPaymentNewCard',
      form: '#checkoutPaymentNewCard'
    });
    WinbitsControls.validar({
      container: '.bodyModal',
      form: '#bodyModal'
    });
    WinbitsControls.verticalCarousel('.carritoDivLeft .carritoContainer');
  }
})();