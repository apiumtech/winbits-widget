// +++++++++++++++++++++++++++++++++++++++++
//      CUSTOMCHECKBOX: Cambiar checkbox
// +++++++++++++++++++++++++++++++++++++++++

function customCheckbox(obj){
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
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMRADIO: Cambiar radio buttons por input text para el género
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function customRadio(obj){
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
}
function unchecRadio (obj){
	$(obj).find('input[type="radio"]').each(function(){
		var $this = $(this);
		$this.attr('checked', false);
		$this.parent().find('.spanRadio').removeClass('spanSelected');
	});
}

// +++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSELECT: Customizar el select
// +++++++++++++++++++++++++++++++++++++++++++

function customSelect (obj){
	if($(obj).length){
		$(obj).each(function () {
			var $this = $(this),
			numberOfOptions = $(this).children('option').length;
			$this.addClass('selectHidden');
			$this.wrap('<div class="selectContainer"/>');
			if($this.data('clase')){
				$this.parent().addClass($this.data('clase'));
			}
			$this.after('<span class="selectContent"/><span class="icon selectTrigger"/>');
			var $styledSelect = $this.next('span.selectContent');
			$styledSelect.text($this.children('option').eq(0).text())
			.addClass($this.children('option').eq(0).data('icon'));
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
				$styledSelect.text($(this).text()).removeClass('active')
				.removeClass().addClass('selectActive selectContent '+$(this).data('class'));
				$this.val($(this).attr('rel'));
				$list.hide();
			});
			$(document).click(function () {
				$styledSelect.removeClass('active');
				$list.hide();
			});
		});
	}
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSLIDER: Deslizar el rango para cambiar valor de bits
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function customSlider(obj){
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
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSTEPPER: Sumar y restar valores del stepper
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function customStepper (obj) {
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
}

// +++++++++++++++++++++++++++++++++++
//      DROPMENU: Abrir los menús
// +++++++++++++++++++++++++++++++++++

function dropMenu(options){
	if($(options.obj).length){
		$(options.trigger).click(function(){
      var $trigger = $(this);
      var $targetDropDown = $trigger.closest('.drop-down-holder').find('.dropMenu');
      if ($targetDropDown.is(':visible')) {
        $targetDropDown.slideUp();
      } else {
        Winbits.$widgetContainer.find('.dropMenu').slideUp();
        $targetDropDown.slideDown();
      }
		});
		$(options.obj).each(function(){
			$(this).bind({
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
}


// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      OPENFOLDER: Abrir el DIV superior del encabezado
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function openFolder(options){
	if($(options.obj).length){
		$(options.trigger).click(function(){
      console.log("Opening folder");
			$(options.obj).slideUp();
			$(options.objetivo).slideDown();
		});
	}
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      PLACEHOLDER: Agregar texto cuando haya Placeholder
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function placeholder (obj, textarea){
	if($(obj).length) {
		$(obj).each(function(){
			if($(this).attr('placeholder')){
				if(textarea) {
					$(this).html($(this).attr('placeholder')).addClass('placeholder');
				} else {
					if ($(this).val() === $(this).attr('placeholder') || $(this).val() === "") {
						$(this).val($(this).attr('placeholder')).addClass('placeholder');
					}
					if($(this).attr('type') === 'password'){
						$(this).addClass('passwordHide').hide().after('<input type="text" value="'+$(this).val()+'" class="placeholder password">');
					}
				}
				$(this).next('.password').focus(function(){
					$(this).hide().prev().css('display','block').focus();
				});
				$(this).focus(function(){
					if(textarea){
						if($(this).html() === $(this).attr('placeholder')){
							$(this).html('').removeClass('placeholder');
						}
					} else {
						if($(this).val() === $(this).attr('placeholder')){
							$(this).val('').removeClass('placeholder');
						}
					}
						
				}).blur(function(){
					if(textarea){
						if($(this).html() === ''){
							$(this).html($(this).attr('placeholder')).addClass('placeholder');
						}
					} else {
						if($(this).val() === ''){
							$(this).val($(this).attr('placeholder')).addClass('placeholder');
							if($(this).hasClass('passwordHide')){
								$(this).blur(function(){
									if($(this).val() === $(this).attr('placeholder') || $(this).val() === ""){
										$(this).hide().next('.password').css('display', 'block');
									}
								});
							}
						}
					}
				});
			}
		});
	}
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      SENDEMAIL: Enviar el correo electrónico desde el formulario INSCRIBETE a la ventana modal
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function sendEmail(obj){
	if($(obj).length){
		$(obj).click(function(){
//			hs.Expander.prototype.onAfterExpand = function(sender){
//				$('#' + sender.contentId).find('#emailRegister').val(this.custom.sendEmail);
//				var exp = window.hs.getExpander();
//				if(exp) {
//					exp.reflow();
//				}
//            };
		});
	}
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      VALIDAR: Validar formularios
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

function validar (obj) {
	if($(obj.container).length) {
    var $forms = $(obj.form);
		$forms.validate({
			errorClass: obj.errorClass,
			errorElement: obj.errorElement,
			errorLabelContainer: obj.errorLabel,
			showErrors: function (errorMap, errorList){
        console.log('Showing errors');
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
				recarga();
			},
			success: function (label) {
				label.addClass(obj.classSuccess);
			},
			validClass: obj.classSuccess
		});
	}
}
function recarga(){
//	var exp = hs.getExpander();
//    if(exp) {
//		exp.reflow();
//    }
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      VERTICALCAROUSEL: Carrusel vertical para carrito
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function verticalCarousel(obj){
  var $obj = $(obj);
	if($obj.length){
    $obj.each(function(i, obj2){
      var $obj2 = $(obj2);
			if($obj2.parent().parent().parent().parent().css('display') === 'none'){
//        $obj2.parent().parent().parent().parent().show();
			}
			var $this = $(this),
				$content = $this.find('.'+$this.data('content')),
				$altoContainer = $this.css('height'),
				$altoContent = $content.css('height');
			if($altoContent > $altoContainer){
				$this.parent().append('<div class="upDownDiv"><span class="icon upCarritoDiv">&uarr;</span><span class="icon downCarritoDiv">&darr;</span></div>');
				var $upButton = $this.parent().find('.upCarritoDiv'),
					$downButton = $this.parent().find('.downCarritoDiv'),
					$bothButton = $this.parent().find('.upDownDiv span.icon'),
					$margin = parseInt($content.css('marginTop'), 10),
					$height = -(parseInt($content.css('height'), 10) - parseInt($this.css('height'), 10));
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
				$obj2.parent().parent().parent().parent().hide();
			}
		});
	}
}

// +++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++
//     FUNCIONES AL FINALIZAR LA CARGA DEL DOM
// +++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++++++++++++++++++++++++++
function changeShippingAddress(options) {
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
}
function quitaClase(options){
	$(options.obj).each(function(){
		$(this).removeClass(options.clase);
	});
}
function uncheck(obj) {
	$(obj).each(function(){
		$(this).attr('checked', false);
	});
}