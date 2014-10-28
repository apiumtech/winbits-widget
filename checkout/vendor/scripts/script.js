(function($) {
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CAROUSELSWIPER: Iniciar carruseles on Swiper
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.carouselSwiper = function(options){
		var defaults = $.extend({
			arrow: true,
			arrowLeft: '.arrowLeft',
			arrowRight: '.arrowRight',
			slidesNum: 0,
			slideCSS: '.carrusel-slide',
			loop: false,
			optionsSwiper: {
				grabCursor: true,
				useCSS3Transforms: false
			},
			calculateHeight: false,
			onClickSlide: false,
			initialSlide: false
		}, options),
		size = 0,
		initSwiper = function(obj){
			var swiper = new Swiper (obj, defaults.optionsSwiper);
			if(!(defaults.loop)){
				swiper.addCallback('TouchEnd', function(swiper){
					removeArrows(obj, swiper, 1);
				});
			}if(defaults.initialSlide){
				initialSlide(obj, swiper);
			}
			if(defaults.arrow){
				initArrow(obj, swiper);
			}
			if(defaults.calculateHeight){
				calculateHeight(obj, swiper);
				swiper.params.onSlideChangeStart = function(swiper){calculateHeight(obj, swiper);};
			}

			if(defaults.onClickSlide){
				$(obj).find(defaults.slideCSS).on('click', function(e){
					e.stopPropagation();
					defaults.onClickSlide(swiper);
				});
			}
			swiper.params.queueStartCallbacks = true;
			swiper.params.queueEndCallbacks = true;
		},
		initArrow = function(obj, swiper){
			$(obj).siblings(defaults.arrowLeft).on('click', function(e) {
				e.stopPropagation();
				$(this).siblings(defaults.arrowRight).slideDown();
				swiper.swipePrev();
				if(!(defaults.loop)){
					removeArrows(obj, swiper);
				}
			});
			$(obj).siblings(defaults.arrowRight).on('click', function(e) {
				e.stopPropagation();
				$(this).siblings(defaults.arrowLeft).slideDown();
				swiper.swipeNext();
				if(!(defaults.loop)){
					removeArrows(obj, swiper);
				}
			});
		},
		initialSlide = function(obj, swiper){
			var index = 0;
			$(obj).find(defaults.slideCSS).each(function(i){
				if($(this).find(defaults.initialSlide).length){
					index = i;
				}
			});
			swiper.swipeTo(index);
			removeArrows(obj, swiper);
		},
		calculateHeight = function(obj, swiper){
			var altura = $(swiper.activeSlide()).outerHeight();
			$(obj).animate({
				height: altura+'px'
			});
			$(obj).siblings(defaults.arrowRight+', '+defaults.arrowLeft).css('top', altura / 2 +'px');
		},
		calculateSize = function(obj){
			size = parseInt($(obj).find(defaults.slideCSS).size(), 10);
			if(defaults.initialSlide){
				$(obj).find(defaults.slideCSS).each(function(i){
					$(this).addClass('slide'+i);
				});
			}
			if(size > defaults.slidesNum){
				initSwiper(obj);
			} else {
				$(obj).siblings(defaults.arrowLeft).hide();
				$(obj).siblings(defaults.arrowRight).hide();
			}
		},
		removeArrows = function(obj, swiper, plus){
			var active = 0,
				pointOfNoReturn = size - (defaults.slidesNum - 1),
				left = $(obj).siblings(defaults.arrowLeft),
				right = $(obj).siblings(defaults.arrowRight);
			active =+ plus;
			$(obj).find(defaults.slideCSS).each(function(i){
				if($(this).hasClass('swiper-slide-active')){
					active = i+1;
				}
			});
			if(active <= 1){
				left.slideUp();
				right.slideDown();
			} else if(active >= pointOfNoReturn){
				left.slideDown();
				right.slideUp();
			} else {
				left.slideDown();
				right.slideDown();
			}
		};
		return this.each(function(index){
			var obj = 'swiperCarrusel-'+index;
			$(this).addClass(obj);
			calculateSize(this);
		});
	};

/* **********************************************
     Begin customCheckbox.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++
//      CUSTOMCHECKBOX: Cambiar checkbox
// +++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.customCheckbox = function(options){
		var defaults = $.extend({
			checkbox: 'input[type="checkbox"]',
			selectClass: 'checkbox-checked',
			unSelectClass: 'checkbox-unchecked',
			wrapper: 'checkbox-wrapper',
			spanIcon: 'checkbox-span'
		}, options), clase,
		wrappingInput = function(obj){
			$(obj).find(defaults.checkbox).each(function(){
				checkingChecked(this);
				if($(this).next().is('label')){
					$(this).next().andSelf().wrapAll('<div class="'+ defaults.wrapper +'"/>');
				} else {
					$(this).wrap('<div class="'+ defaults.wrapper +'"/>');
				}
				$(this).parent().prepend('<span class="'+ defaults.spanIcon +' '+ clase +'"/>');
				clickingCheckbox(this);
			});
		},
		checkingChecked = function(obj){
			if($(obj).prop('checked')){
				clase = defaults.selectClass;
			} else {
				clase = defaults.unSelectClass;
			}
		},
		clickingCheckbox = function(obj){
			$(obj).parent().find('.'+ defaults.spanIcon).click(function(){
				if($(obj).prop('checked')){
					$(this).removeClass(defaults.selectClass);
					$(this).addClass(defaults.unSelectClass);
					$(obj).prop('checked', false);
				} else {
					$(this).removeClass(defaults.unSelectClass);
					$(this).addClass(defaults.selectClass);
					$(obj).prop('checked', true);
				}
			});
		};
		return this.each(function(){
			wrappingInput(this);
		});
	};

/* **********************************************
     Begin customRadio.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMRADIO: Cambiar radio buttons por input text para el género
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.customRadio = function(options){
		var defaults = $.extend({
			wrapper: 'radio-wrapper',
			spanRadio: 'radio-span',
			spanSelected: 'radio-selected',
			radio: 'input[type="radio"]',
			classColor: 'radio-color',
			tooltipClass: 'tool-tip',
			classSoldout: 'radio-soldout'
		}, options),
		wrappingInput = function(obj){
			$(obj).find(defaults.radio).each(function(){
				var $this = $(this);
				if($this.next().is('label')){
					$this.next().andSelf().wrapAll('<div class="'+ defaults.wrapper +'"/>');
				} else {
					$this.wrap('<div class="'+ defaults.wrapper +'"/>');
				}
				if($this.prop('checked')){
					$this.parent().prepend('<span class="'+ defaults.spanRadio +' '+ defaults.spanSelected +'">'+$(this).val()+'</span>');
				} else {
					$this.parent().prepend('<span class="'+ defaults.spanRadio +'">'+$(this).val()+'</span>');
				}
				if($this.data('color')){
					customColor(this);
				}
				if($this.data('soldout')){
					soldOut(this);
				}
			});
			clickingRadio(obj);
		},
		unchecRadio = function(obj){
			$(obj).find(defaults.radio).each(function(){
				$(this).prop('checked', false);
				$(this).parent().find('.'+defaults.spanRadio).removeClass(defaults.spanSelected);
			});
		},
		clickingRadio = function(obj){
			$(obj).find('.'+ defaults.spanRadio).click(function(){
				var $input = $(this).parent().find(defaults.radio);
				unchecRadio(obj);
				if(!($input.prop('checked'))){
					$input.prop('checked', true);
					if($input.length) {
						$(this).addClass(defaults.spanSelected);
					}
				}
			});
		},
		customColor = function(obj){
			$(obj).parent().find('.'+defaults.spanRadio).addClass(defaults.classColor).css('background-color', '#'+$(obj).data('color'));
			$(obj).parent().find('.'+defaults.spanRadio).toolTip({clase: defaults.tooltipClass});
		},
		soldOut = function(obj){
			$(obj).parent().find('.'+defaults.spanRadio).addClass(defaults.classSoldout);
			$(obj).remove();
		};
		return this.each(function(){
			wrappingInput(this);
		});
	};

/* **********************************************
     Begin customSelect.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSELECT: Customizar el select
// +++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.customSelect = function(options){
		var defaults = $.extend({
			selectHidden: 'select-hidden',
			divSelect: 'select-div',
			inputSelect: 'select-input',
			claseIcon: 'icon',
			claseTrigger: 'iconFont-downmenu',
			ulOptions: 'select-ul',
			claseActivo: 'select-activo',
			selectActive: 'select-active',
			onChangeSelect: false
		}, options), numberOfOptions, selectContent, styledSelect, list, listItems,
		addClass = function(obj){
			if($(obj).data('clase')){
				$(obj).parent().addClass($(obj).data('clase'));
			} else {
				$(obj).parent().addClass($(obj).parent().parent().attr('class'));
			}
		},
		addInput = function(obj){
			if($(obj).data('inputselect')) {
				selectContent = '<input type="text" class="'+ defaults.inputSelect +'">';
			} else {
				selectContent = '<span class="'+ defaults.inputSelect +'"/>';
			}
			$(obj).after(selectContent+'<span class="'+ defaults.claseTrigger +'"/>');
			addInputSelect(obj);
		},
		addInputSelect = function(obj){
			styledSelect = $(obj).siblings('.'+ defaults.inputSelect);
			var valor = $(obj).children('option').eq(0).text();
			$(obj).children('option').each(function(){
				if ($(this).attr('selected') === 'selected'){
					valor = $(this).text();
				}
			});
			if($(obj).data('inputselect')) {
				styledSelect.attr('placeholder',valor)
				.addClass($(obj).children('option').eq(0).data('icon'));
			} else {
				styledSelect.text(valor)
				.addClass($(obj).children('option').eq(0).data('icon'));
			}
			addLista(obj);
		},
		addLista = function(obj){
			list = $('<ul />', {
					'class': defaults.ulOptions
				}).insertAfter($(obj).parent().find('span.'+ defaults.claseTrigger));
			for (var i = 0; i < numberOfOptions; i++) {
				$('<li />', {
					text: $(obj).children('option').eq(i).text(),
					rel: $(obj).children('option').eq(i).val(),
					'data-class': $(obj).children('option').eq(i).data('icon')
				}).appendTo(list);
			}
			listItems = list.children('li');
			clickingTrigger(obj);
		},
		changeSelect = function(obj){
			defaults.onChangeSelect(obj);
		},
		clickingTrigger = function(obj){
			$(obj).parent().on('click', 'span.'+ defaults.claseTrigger, function(e){
				e.stopPropagation();
				$('.'+defaults.ulOptions).hide();
				$(obj).siblings('.'+ defaults.inputSelect).toggleClass(defaults.claseActivo);
				$(this).next('ul.'+ defaults.ulOptions).toggle();
			});
			clickingOption(obj);
		},
		clickingDocument = function(obj){
			$(obj).siblings('.'+ defaults.inputSelect).removeClass(defaults.claseActivo);
			$('.'+defaults.ulOptions).hide();
		},
		clickingOption = function(obj){
			$(obj).change().parent().on('click', 'ul li', function(e){
				resetSelected(obj);
				e.stopPropagation();
				styledSelect = $(obj).siblings('.'+ defaults.inputSelect);
				var $this = $(this);
				if($(obj).data('inputselect')) {
					styledSelect.val($this.text()).removeClass(defaults.claseActivo)
					.addClass(defaults.selectActive +' '+ $this.data('clase'));
				} else {
					styledSelect.text($this.text()).removeClass(defaults.claseActivo)
					.addClass(defaults.selectActive +' '+ $this.data('clase'));
				}
				$(obj).val($this.attr('rel'));
				for(var o=0, opts = $(obj).children('option'); o < opts.length; o++){
					if(opts.eq(o).val() === $this.attr('rel')) {
						opts.eq(o).attr('selected', 'selected');
					}
				}
				$(obj).siblings('ul').hide();
				$(obj).trigger('change');
			});
			$(obj).on('change', function(e){
				e.stopPropagation();
				if(defaults.onChangeSelect){
					changeSelect(obj);
				}
			});
			$(document).click(function(){
				clickingDocument(obj);
			});
		},
		resetSelected = function(obj){
			$(obj).children('option').each(function(){
				$(this).removeAttr('selected');
			});
		},
		wrappingSelect = function(obj){
			numberOfOptions = $(obj).children('option').length;
			$(obj).addClass(defaults.selectHidden);
			$(obj).wrap('<div class="'+ defaults.divSelect +'"/>');
			addClass(obj);
			addInput(obj);
		};
		return this.each(function(){
			wrappingSelect(this);
		});
	};

/* **********************************************
     Begin customSlider.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSLIDER: Deslizar el rango para cambiar valor de bits
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.customSlider = function(options){
		var defaults = $.extend({
			wrapper: 'slider-wrapper',
			holder: 'slider-holder',
			handle: 'ui-slider-handle',
			bit: 'iconBit bit13px',
			amount: 'slider-amount',
			textValue: 'slider-textValue',
			textMin: 'slider-minValue',
			textMax: 'slider-maxValue'
		}, options),
		price, priceItem, datamax, realpriceItem, realprice, percent, percentItem,
		wrappingInput = function(obj){
			asignaValues(obj);
			$(obj).wrap('<div class="'+ defaults.wrapper +'"><div class="'+ defaults.holder +'"/>');
			$(obj).parent().append('<a href="#" class="'+ defaults.handle +'"><div class="'+ defaults.bit +'"><span class="iconBG"/><span class="iconFont-bit"/></div><span class="'+ defaults.amount +'">$<em>'+$(obj).val()+'</em></span></a>');
			$(obj).parent().parent().append('<span class="'+ defaults.textValue +' '+ defaults.textMin +'">'+$(obj).data('min')+'</span><span class="'+ defaults.textValue +' '+ defaults.textMax +'">'+datamax.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'</span>');
			initSlider(obj);
		},
		asignaValues = function(obj){
			if($(obj).data('moveprice')){
				priceItem = $('.'+$(obj).data('priceitem'));
				price = parseInt($(obj).data('price'), 10);
				priceItem.text(price);
				if($(obj).data('max') > price) {
					datamax = price;
				} else {
					datamax = $(obj).data('max');
				}
			}
			if($(obj).data('realprice')){
				realpriceItem = $('.'+$(obj).data('realpriceitem'));
				realprice = parseInt($(obj).data('realprice'),10);
				realpriceItem.text(realprice);
			}
			if($(obj).data('percent') && $(obj).data('realprice')){
				percentItem = $('.'+$(obj).data('percent'));
				percent = 100 - parseInt((100 * price) / realprice, 10);
				percentItem.text(percent);
			}
			if($(obj).data('save')){
				$('.'+$(obj).data('saveitem')).text($(obj).data('save'));
			}
		},
		initSlider = function(obj){
			$(obj).parent().parent().find('.'+defaults.holder).slider({
				range: 'min',
				value: +$(obj).val(),
				min: +$(obj).data('min'),
				max: +datamax,
				slide: function(event, ui){
          $(obj).val(ui.value);
          var maxSelection, previousValue, value, $this=$(obj);
          maxSelection = parseInt($this.data('max-selection') || '0');
          value = Math.min(maxSelection, ui.value);
          previousValue = $this.val();
          $this.val(value);
          $this.parent().find(".slider-amount em").text(value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
          if (ui.value > maxSelection) {
            if (previousValue !== maxSelection) {
              $(this).slider('value', maxSelection);
            }
            return false;
          }
				},
				step: $(obj).data('step')
			});
		};
		return this.each(function(){
			wrappingInput(this);
		});
	};

/* **********************************************
     Begin changeBox.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CHANGEBOX: Cambiar div para seleccionar direccion/tarjeta
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.changeBox = function(options){
		var defaults = $.extend({
			activo: 'selected',
			items: 'div',
			inputRadio: 'input[type="radio"]'
		}, options),
		changeSelected = function(obj){
			$(obj).on('click', defaults.items, function(){
				unselectRadio(obj);
				$(obj).find(defaults.items).removeClass(defaults.activo);
				$(this).addClass(defaults.activo);
				$(this).find(defaults.inputRadio).attr('checked', true);
			});
		},
		unselectRadio = function(obj){
			$(obj).find(defaults.items).find(defaults.inputRadio).attr('checked', false);
		};
		return this.each(function(){
			changeSelected(this);
		});
	};

/* **********************************************
     Begin dropMainMenu.js
********************************************** */

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//		DROPMAINMENU: Drop menus del carrito y de mi cuenta
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.dropMainMenu = function(options){
		var defaults = $.extend({
			contenedor: '.dropMenu',
			claseActivo: 'active',
			wrapper: '.wrapper',
			closeBtn: '.miCuenta-close'
		}, options), claseObj,
		clickingTrigger = function(obj){
			$(obj).siblings(defaults.contenedor).stop(true, true).slideToggle();
			$(obj).toggleClass(defaults.claseActivo);
		},
		closeSiblings = function(obj){
			$(obj).siblings(defaults.contenedor).stop(true, true).slideUp();
			$(obj).removeClass(defaults.claseActivo);
		};
		return this.each(function(){
			var objeto = this,
			wpOb = $(objeto).next(defaults.contenedor).find(defaults.wrapper);
			claseObj = $(objeto).attr('class').split(' ')[0],
			$(objeto).on('click', function(e){
				e.stopPropagation();
				if($(objeto).siblings(defaults.contenedor).css('display') === 'none'){
					closeSiblings('.'+claseObj);
				}
				clickingTrigger(objeto);
			});
			wpOb.on('click', defaults.closeBtn, function(){
				$(objeto).trigger('click');
			});
			if($(this).data('cart')){
				wpOb = $(objeto).next(defaults.contenedor).find(defaults.wrapper).children().eq(0);
			}
			wpOb.on({
				click: function(e){
					e.stopPropagation();
				},
				mouseenter: function(){
					$(this).addClass(defaults.claseActivo);
					$(objeto).show();
				},
				mouseleave: function(){
					$(this).removeClass(defaults.claseActivo);
					$(document).click(function(){
						closeSiblings(objeto);
						$(document).unbind('click');
					});
				}
			});
		});
	};

/* **********************************************
     Begin imageError.js
********************************************** */

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      IMAGEERROR: Poner imagen de error cuando no la encuentre
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.imageError = function(options){
		var defaults = $.extend({
			src: 'images/misc/noImage.jpg',
			alt: 'No se encontró la imagen'
		}, options);
		return this.each(function(){
			$(this).error(function(){
				$(this).attr({
					src: defaults.src,
					alt: defaults.alt
				});
			});
		});
	};

/* **********************************************
     Begin fancyBox.js
********************************************** */

// ++++++++++++++++++++++++++++++++++++++
//      FANCYBOX: Modales con FancyBox
// ++++++++++++++++++++++++++++++++++++++

	jQuery.fn.fancyBox = function(){
		var optionsFancybox = {},
		defaultFancybox = function(obj){
			optionsFancybox = {
				padding: 0,
				margin: 0,
				width: $(obj).data('fancyboxwidth'),
				iframe: {
					scrolling: 'auto',
					preload: true
				},
				type: 'iframe'
			};
		},
		hrefFancybox = function(obj) {
			optionsFancybox = {
				padding: 0,
				margin: 0,
				width: $(obj).data('fancyboxwidth'),
				href: $(obj).data('fancyboxhref'),
				iframe: {
					scrolling: 'auto',
					preload: true
				},
				type: 'iframe'
			};
		},
		noCloseFancybox = function(obj){
			optionsFancybox = {
				padding: 0,
				margin: 0,
				closeBtn: false,
				width: $(obj).data('fancyboxwidth'),
				href: $(obj).data('fancyboxhref'),
				iframe: {
					scrolling: 'auto',
					preload: true
				},
				type: 'iframe'
			};
		};
		return this.each(function(){
			if ($(this).data('fancyboxhref')){
				hrefFancybox(this);
				$(this).fancybox(optionsFancybox);
			} else if ($(this).data('fancybox-noclosebtn')){
				noCloseFancybox(this);
				$(this).fancybox(optionsFancybox);
			} else {
				defaultFancybox(this);
				$(this).fancybox(optionsFancybox);
			}
		});
	};

/* **********************************************
     Begin mailingMenuCheckboxs.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      MAILINGMENUCHECKBOXS: Eventos / efectos para los checkboxes y radios del menú
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    jQuery.fn.mailingMenuCheckboxs = function(options){
        var defaults = $.extend({
                checkboxSpan: '.checkbox-span',
                checkboxUnchecked: 'checkbox-unchecked',
                checkboxChecked: 'checkbox-checked',
                checkboxAll: '.checkall',
                overlay: 'mailingOverlay',
                radio: 'input[type="radio"]',
                spanRadio: 'radio-span',
                spanSelected: 'radio-selected'
            }, options), overlay = 0,
            checkAll = function(obj){
                $(obj).find(defaults.checkboxAll).siblings(defaults.checkboxSpan).click(function(){
                    var checkUnchec = $(this).attr('class').split(' ')[1];
                    $(this).parent().siblings().each(function(){
                        if(!$(this).find(defaults.checkboxSpan).hasClass(checkUnchec)){
                            $(this).find(defaults.checkboxSpan).trigger('click');
                        }
                    });
                });
            },
            checkEach = function(obj){
                $(obj).find(defaults.checkboxSpan).each(function(){
                    checkCheckbox(this, obj, 1);
                }).click(function(){
                        checkCheckbox(this, obj);
                    });
            },
            checkCheckbox = function(item, obj, init){
                if($(item).hasClass(defaults.checkboxChecked)) {
                    overlay = overlay + 1;
                } else {
                    if (!init){
                        overlay = overlay - 1;
                    }
                }
                if(overlay <= 0){
                    appendOverlay(obj);
                    overlay = 0;
                } else {
                    removeOverlay(obj);
                }
            },
            appendOverlay = function(obj){
                if(!$(obj).find('.' + defaults.overlay).length) {
                    $(obj).append('<div class="'+ defaults.overlay + '"/>');
                    uncheckRadio(obj);
                }
            },
            removeOverlay = function(obj){
                if($(obj).find('.' + defaults.overlay).length) {
                    $(obj).find('.' + defaults.overlay).remove();
                }
            },
            uncheckRadio = function(obj){
                $(obj).find(defaults.radio).each(function(){
                    $(this).attr('checked', false);
                    $(this).parent().find('.'+defaults.spanRadio).removeClass(defaults.spanSelected);
                });
            };
        return this.each(function(){
            checkAll(this);
            checkEach(this);
        });
    };




    // var unchecked = 0;
    // $('#wb-micuenta-mailing .checkbox-span').each(function(i){
    //     if($(this).hasClass('checkbox-unchecked')) {
    //         unchecked = unchecked + 1;
    //     }
    //     console.log(unchecked+' '+$('#wb-micuenta-mailing .checkbox-span').size());
    // });

/* **********************************************
     Begin requiredField.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++
//      REQUIREDFIELD: Campos requeridos
//		Dependencias: toolTip.js
// +++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.requiredField = function (options) {
		var defaults = $.extend({
			wrapper: 'required-wrapper',
			icon: 'iconFont-star'
		}, options),
		wrappingInput = function(obj){
			$(obj).wrap('<div class="'+ defaults.wrapper +'"/>');
			$(obj).parent().append('<span class="'+ defaults.icon +'" data-tooltip="'+ $(obj).data('requiredfield')+'"/>');
			$(obj).siblings('.'+defaults.icon).toolTip();
		};
		return this.each(function(){
			wrappingInput(this);
		});
	};

/* **********************************************
     Begin scrollpane.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      SCROLLPANE: Scroll que aparece / desaparece
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.scrollpane = function (options) {
		var defaults= $.extend({
			parent: '.scrollpane',
			horizontalDragMinWidth: 40,
			horizontalDragMaxWidth: 40
		}, options);
		return this.each(function(){
			if(defaults.parent) {
				if($(defaults.parent).css('display') === 'none') {
					$(defaults.parent).css('display', 'block');
					$(this).jScrollPane({
						horizontalDragMinWidth: defaults.horizontalDragMinWidth,
						horizontalDragMaxWidth: defaults.horizontalDragMaxWidth
					});
				$(defaults.parent).css('display', 'none');
				} else {
					$(this).jScrollPane({
						horizontalDragMinWidth: defaults.horizontalDragMinWidth,
						horizontalDragMaxWidth: defaults.horizontalDragMaxWidth
					});
				}
			}
		});
	};

/* **********************************************
     Begin showHideDiv.js
********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      SHOWHIDEDIV: Abrir el DIV superior del encabezado
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	jQuery.fn.showHideDiv = function (){
		return this.each(function(){
			$(this).on('click', function(){
				if($(this).data('claseactivo')){
					if($(this).data('showdiv')){
						$($(this).data('showdiv')).addClass($(this).data('claseactivo'));
					}
					$($(this).data('hidediv')).removeClass($(this).data('claseactivo'));
				} else {
					if ($(this).data('showdiv')){
						$($(this).data('showdiv')).slideDown();
					}
					$($(this).data('hidediv')).slideUp($);
				}
			});
		});
	};

/* **********************************************
     Begin tabs.js
********************************************** */

// +++++++++++++++++++++++++++++++++++
//      TABS: Pestañas
// ++++++++++++++++++++++++++++++++++++

	jQuery.fn.tabs = function (options) {
		var defaults = $.extend({
			tabClass: 'tabClass',
			item: 'li',
			tabSelected: 'tabSelected'
		}, options);
		return this.each(function(){
			$(defaults.tabClass).hide().eq(0).show();
			$(this).find(defaults.item).click(function(e){
				e.preventDefault();
				$(defaults.tabClass).hide();
				var id = $(this).find('a').attr('href');
				$(id).fadeToggle();
				$(this).addClass(defaults.tabSelected).siblings().removeClass(defaults.tabSelected);
			});
		});
	};

/* **********************************************
     Begin toolTip.js
********************************************** */

// ++++++++++++++++++++++++++++++++++++
//		TOOLTIP: Tooltips en objetos
// ++++++++++++++++++++++++++++++++++++

	jQuery.fn.toolTip = function(options){
		var defaults = $.extend({
			clase: 'tooltip'
		}, options),
		asignaValor = function(obj){
			var $this = $(obj), valor;
			if ($this.text() !== '') {
				valor = $this.text();
			} else if($this.val()){
				valor = $this.val();
			} else if ($this.data('tooltip')){
				valor = $this.data('tooltip');
			} else if($this.attr('title')){
				valor = $this.attr('title');
			} else if($this.attr('alt')){
				valor = $this.attr('alt');
			} else {
				valor = '';
			}
			return valor;
		},
		appendHTML = function(valor, obj){
			$('body').append('<div class="'+ defaults.clase +'">' + valor + '</div>');
			$(obj).attr('title', '');
		},
		mueveTooltip = function(e){
			if ($('.msie').length){
				$('.'+defaults.clase).css({
					top: e.clientY + 5,
					left: e.clientX + 5
				});
			} else {
				$('.'+defaults.clase).css({
					top: e.pageY + 5,
					left: e.pageX + 5
				});
			}
		},
		remueveHTML = function(valor, obj){
			$('body').find('.'+defaults.clase).remove();
			$(obj).attr('title', valor);
		};
		return this.each(function(){
			var val = asignaValor(this);
			if (val !== ''){
				$(this).on({
					mouseenter: function(){appendHTML(val, this);},
					mousemove: mueveTooltip,
					mouseleave: function(){remueveHTML(val, this);}
				});
			}
		});
	};

        jQuery.fn.fixedFooter = function(options){
            var defaults = $.extend({
                    clase: 'footer-fixed',
                    minHeigth: 500
            }, options),

            addRemoveClass = function(obj){

                if($('html').height() < $(window).height()) {
                    $(obj).addClass(defaults.clase);
                } else {
                    $(obj).removeClass(defaults.clase);
                }
            };
            return this.each(function(){
                var $this = this;
                addRemoveClass($this);
                $(window).resize(function(){
                    addRemoveClass($this);
                });
            });
        };


        /*  @codekit-prepend  "js/scripts/carouselSwiper.js";
         *      @codekit-prepend  "js/scripts/customCheckbox.js";
         *          @codekit-prepend  "js/scripts/customRadio.js";
         *              @codekit-prepend  "js/scripts/customSelect.js";
         *                  @codekit-prepend  "js/scripts/customSlider3.js";
         *                      @codekit-prepend  "js/scripts/closeVideoHome.js";
         *                          @codekit-prepend  "js/scripts/changeBox.js";
         *                              @codekit-prepend  "js/scripts/dropMainMenu.js";
         *                                  @codekit-prepend  "js/scripts/imageError.js";
         *                                      @codekit-prepend  "js/scripts/fancyBox.js";
         *                                          @codekit-prepend  "js/scripts/fixedFooter.js";
         *                                              @codekit-prepend  "js/scripts/mailingMenuCheckboxs.js";
         *                                                  @codekit-prepend  "js/scripts/requiredField.js";
         *                                                      @codekit-prepend  "js/scripts/scrollpane.js";
         *                                                          @codekit-prepend  "js/scripts/showHideDiv.js";
         *                                                              @codekit-prepend  "js/scripts/tabs.js";
         *                                                                  @codekit-prepend  "js/scripts/toolTip.js"; */
        jQuery.fn.fixedObj = function(options){
            var defaults = $.extend({
                    minScroll: 50,
                    scrollClass: 'fixedObj'
            }, options);
            return this.each(function(){
                var $this = $(this);
                $(window).scroll(function() {
                    var windowsScroll = $(window).scrollTop();
                    if(defaults.minScroll < windowsScroll){
                        $this.addClass(defaults.scrollClass);
                    } else {
                        $this.removeClass(defaults.scrollClass);
                    }
                });

            });
        };

})(window.jQuery);
