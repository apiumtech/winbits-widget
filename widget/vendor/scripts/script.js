(function($) {
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CAROUSELSWIPER: Iniciar carruseles on Swiper
//		Dependencias: Librería Swiper de idangerous (2.4.3) http://www.idangero.us/sliders/swiper
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

jQuery.fn.carouselSwiper = function(options){
  var defaults = $.extend({
        arrow: true, // Si van a existir flechas
        arrowLeft: '.arrowLeft', // Flecha izquierda/anterior/prev
        arrowRight: '.arrowRight', // Flecha derecha/siguiente/next
        slidesNum: 0, // Número de slides que muestra. Por default es 0 que significa que sólo se muestra 1
        slideCSS: '.carrusel-slide', // Clase del slide
        loop: false, // Si se repite el carrusel
        optionsSwiper: { // Opciones del carrusel
          grabCursor: true,
          useCSS3Transforms: false
        },
        calculateHeight: false, // Calcular el alto, por default no lo hace
        onClickSlide: false, // Para agregar aquí lo que se ejecutará cuando le das click a un slide. Por default no hace nada
        initialSlide: false, // Si el slide inicial es diferente a la primera. Aqui se pone el número del slide donde se iniciará. NOTA: Tomar en cuenta que en carruseles cíclicos, se duplica el primer y el último slide.
        carruselNum: 'swiperCarrusel-' // Para asignar un número al carrusel. Útil cuando son más de uno.
      }, options),
      size = 0, // Variable que servirá para escribir el número de slides que tiene el carrusel
  // 1. Método que calcula cuántos slides tiene el carrusel
      calculateSize = function(obj){
        // Asignar a la variable global size el número de slides, contándolos
        size = parseInt($(obj).find(defaults.slideCSS).size(), 10);
        // Si el slide inicial no es el primero
        if(defaults.initialSlide){
          // A cada uno de los slides se le agrega un índice
          $(obj).find(defaults.slideCSS).each(function(i){
            $(this).addClass('slide'+i);
          });
        }
        // Si queremos mostrar más de un slide en cada vista
        if(defaults.slidesNum){
          // Si la cantidad de slides es mayor al número de slides que se quiere mostrar en cada vista
          if(size > defaults.slidesNum){
            // Llamar método que inicializa el carrusel
            initSwiper(obj);
            // Si el número de slides es menor al número de slides por vista
          } else {
            // Oculta las flechas derecha e izquierda
            $(obj).siblings(defaults.arrowLeft).hide();
            $(obj).siblings(defaults.arrowRight).hide();
          }
          // Si el número de slides a mostrar por vista es el default ( o sea 1)
        } else {
          // Si la cantidad de slides es mayor a 2
          if(size > 2){
            // Inicializa el carrusel
            initSwiper(obj);
            // Si la cantidad de slides es 1 o 0
          } else {
            // Oculta las flechas izquierda y derecha
            $(obj).siblings(defaults.arrowLeft).hide();
            $(obj).siblings(defaults.arrowRight).hide();
          }
        }
      },
  // 2. Método para inicializar el carrusel
      initSwiper = function(obj){
        // Objeto que contendrá el carrusel
        var swiper = new Swiper (obj, defaults.optionsSwiper);
        // Si no se necesita repetir el carrusel
        if(!(defaults.loop)){
          // Agrega al objeto del carrusel el callback Touch End
          swiper.addCallback('TouchEnd', function(){
            // Cuando se ejecute el callback, verifica el estado de las flechas con removeArrows
            $(obj).removeArrows({
              addCallback: 1, // Cambia el valor default de addCallback de 0 a 1
              arrowLeft: defaults.arrowLeft, // Flecha izquierda/anterior/prev
              arrowRight: defaults.arrowRight, // Flecha derecha/siguiente/next
              slidesNum: defaults.slidesNum, // Número de slides por vista
              slideCSS: defaults.slideCSS // Clase del slide del carrusel
            });
          });
        }
        // Si el slide inicial es diferente al primero
        if(defaults.initialSlide){
          // Cambia la posición del carrusel
          initialSlide(obj, swiper);
        }
        // Si existen flechas
        if(defaults.arrow){
          // Inicializa las flechas
          initArrow(obj, swiper);
        }
        // Si se tiene que calcular el alto del carrusel
        if(defaults.calculateHeight){
          // Calcula el alto del carrusel
          calculateHeight(obj, swiper);
          // Agrega al objeto carrusel onSlideChangeStart(que es del swiper) que recalcule el alto cada vez que se cambie un slide
          swiper.params.onSlideChangeStart = function(swiper){calculateHeight(obj, swiper);};
        }
        // Si se necesita agragar funcionalidad después de que le den click al slide
        if(defaults.onClickSlide){
          $(obj).find(defaults.slideCSS).on('click', function(e){
            // Deten la propagación de eventos
            e.stopPropagation();
            // Ejecuta la función que venga en onClickSlide al carrusel
            defaults.onClickSlide(swiper);
          });
        }
        // Agregar al carrusel que los callbacks se ejecuten sólo una vez en múltiples al inicio de los cambios de slide (como cuando un usuario le pica repetidamente a las flechas)
        swiper.params.queueStartCallbacks = true;
        // Agregar al carrusel que los callbacks se ejecuten sólo una vez en múltiples al final de los cambios de slide (como cuando un usuario le pica repetidamente a las flechas)
        swiper.params.queueEndCallbacks = true;
      },
  // 3. Método para cambiar la posición del slide
      initialSlide = function(obj, swiper){
        // Variable donde se deposita el slide inicial
        var index = 0;
        // Recorre todos los slides
        $(obj).find(defaults.slideCSS).each(function(i){
          // Si encuentras en el slide la clase del slide inicial
          if(($(this).find(defaults.initialSlide).length) || ($(this).hasClass(defaults.initialSlide))){
            // Agregale el valor del índice a la variable index
            index = i;
          }
        });
        // Mueve el carrusel al valor que trae index
        swiper.swipeTo(index);
        // Si es necesario que se repita el carrusel
        if(!(defaults.loop)){
          // Verificar posición de las flechas (si se deben mostrar o no)
          prepareArrow(obj);
        }
      },
  // 4. Inicializa las flechas
      initArrow = function(obj, swiper){
        // Verificar posición de las flechas (si se deben mostrar o no)
        prepareArrow(obj);
        // Busca en los hermanos del objeto la flecha izquierda/anterior/prev y en el click
        $(obj).siblings(defaults.arrowLeft).on('click', function(e) {
          // Deten la propagación de eventos
          e.stopPropagation();
          // Si no se tiene que repetir el carrusel
          if(!(defaults.loop)){
            // Verificar posición de las flechas (si se deben mostrar o no)
            prepareArrow(obj);
          }
          // Cambia el carrusel al anterior slide
          swiper.swipePrev();
        });
        // Busca en los hermanos del objeto la flecha derecha/siguiente/next y en el click
        $(obj).siblings(defaults.arrowRight).on('click', function(e) {
          // Deten la propagación de eventos
          e.stopPropagation();
          // Si no se tiene que repetir el carrusel
          if(!(defaults.loop)){
            // Verificar posición de las flechas (si se deben mostrar o no)
            prepareArrow(obj);
          }
          // Cambia el carrusel al siguiente slide
          swiper.swipeNext();
        });
      },
  // 5. Método que calcula el alto de carrusel
      calculateHeight = function(obj, swiper){
        // Variable que escribe la altura del slide activo
        var altura = $(swiper.activeSlide()).outerHeight();
        // Recalcula el alto del carrusel de forma animada
        $(obj).animate({
          height: altura+'px'
        });
        // Busca en los hermanos del carrusel la flecha izquierda y derecha y cambia el valor top para que se pongan en el centro del carrusel
        $(obj).siblings(defaults.arrowRight+', '+defaults.arrowLeft).css('top', altura / 2 +'px');
      },
  // Método que verifica posición de las flechas (si se deben mostrar o no)
      prepareArrow = function(obj){
        // Llama a removeArrow
        $(obj).removeArrows({
          arrowLeft: defaults.arrowLeft, // Flecha izquierda/anterior/prev
          arrowRight: defaults.arrowRight, // Flecha derecha/siguiente/next
          slidesNum: defaults.slidesNum, // Número de slides por vista
          slideCSS: defaults.slideCSS // Clase del slide del carrusel
        });
      };
  // 0. INICIO
  return this.each(function(index){
    // Clase única para identificar el carrusel. Útil cuando son más de uno
    var obj = defaults.carruselNum+index;
    // Agregar la clase única al carrusel
    $(this).addClass(obj);
    // Llamar al método que calcula cuántos slides tiene el carrusel
    calculateSize(this);
  });
};

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//		Dependencias: carouselSwiper.js
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

jQuery.fn.removeArrows = function(options){
  var defaults = $.extend({
        slideCSS: '.carrusel-slide', // Clase de slides
        slidesNum: 0, // Número de slides a mostrar en cada vista. Default es 0 (que equivale a 1)
        arrowLeft: '.arrowLeft', // Flecha izquierda/anterior/prev
        arrowRight: '.arrowRight', // Flecha derecha/siguiente/next
        slideActive: 'swiper-slide-active', // Clase de slide activa
        addCallback: 0 // Callback. Default 0
      }, options),
  // Variable que contendrá el valor activo
      active = 0;
  // INICIO
  return this.each(function(){
    // Cantidad de slides del carrusel
    var size = $(this).find(defaults.slideCSS).size(),
    // Flecha izquierda
        left = $(this).siblings(defaults.arrowLeft),
    // Flecha derecha
        right = $(this).siblings(defaults.arrowRight),
    // Penúltima slide
        pointOfNoReturn = size - 1;
    // Si el número de slides a mostrar por vista es diferente al default
    if (defaults.slidesNum){
      // Asignale el penúltimo slide
      pointOfNoReturn = size - (defaults.slidesNum - 1);
    }
    // Si la cantidad de slides es mayor al número de slides a mostrar por vista
    if(size > defaults.slidesNum){
      // El valor activo cambiará al valor callback
      active =+ defaults.addCallback;
      // Busca en cada uno de los slides
      $(this).find(defaults.slideCSS).each(function(i){
        // Si encuentras que tiene la clase slideActive
        if($(this).hasClass(defaults.slideActive)){
          // El valor activo cambia al valor del ínidice mas uno
          active = i+1;
        }
      });
      // Si el valor activo es mayor o igual a 1
      if(active <= 1){
        // Oculta la flecha izquierda
        left.slideUp();
        // Muestra la flecha derecha
        right.slideDown();
        // Si el valor activo es menor o igual al penúltimo slide
      } else if(active >= pointOfNoReturn){
        // Muestra la flecha izquierda
        left.slideDown();
        // Oculta la flecha derecha
        right.slideUp();
        // Si el valor activo es el default, o sea 0
      } else {
        // Oculta las flechas derecha e izquierda
        left.slideDown();
        right.slideDown();
      }
      // Si la cantidad de slides es menor al número de slides a mostrar por vista
    } else {
      // Oculta las flechas derecha e izquierda
      left.hide();
      right.hide();
    }
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
        spanIcon: 'checkbox-span',
        onClickCall: false
      }, options), clase,
      wrappingInput = function(obj){
        $(obj).find(defaults.checkbox).each(function(){
          var $this = this;
          checkingChecked($this);
          if($($this).next().is('label')){
            $($this).next().andSelf().wrapAll('<div class="'+ defaults.wrapper +'"/>');
            $($this).next().click(function(e){
              e.preventDefault();
            });
            $($this).appendTo($(this).next());
          } else {
            $($this).wrap('<div class="' + defaults.wrapper + '"/>');
          }
          $($this).parents('.'+defaults.wrapper).prepend('<span class="'+ defaults.spanIcon +' '+ clase +'"/>');
          $($this).parents('.'+defaults.wrapper).click(function(){
            clickingCheckbox($this, $($this).parents('.'+defaults.wrapper).children('.' + defaults.spanIcon));
          });
        });
      },
      checkingChecked = function(obj){
        if($(obj).prop('checked')){
          clase = defaults.selectClass;
        } else {
          clase = defaults.unSelectClass;
        }
      },
      clickingCheckbox = function(obj, trigger){
        if($(obj).prop('checked')){
          $(trigger).removeClass(defaults.selectClass).addClass(defaults.unSelectClass);
          $(obj).prop('checked', false);
        } else {
          $(trigger).removeClass(defaults.unSelectClass).addClass(defaults.selectClass);
          $(obj).prop('checked', true);
        }
        if(defaults.onClickCall){
          onClickCallback(obj, $(obj).parents('.'+defaults.wrapper));
        }
      },
      onClickCallback = function(obj, parent){
        defaults.onClickCall(obj, parent);
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
        classSoldout: 'radio-soldout',
        justClick: false
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
          $this.appendTo($this.next());
        });
        clickingRadio(obj);
        $(obj).find('label').click(function(){
          $(this).parent().find('.' + defaults.spanRadio).trigger('click');
        });
      },
      unchecRadio = function(obj){
        $(obj).find(defaults.radio).each(function(){
          $(this).prop('checked', false);
          $(this).parent().parent().find('.'+defaults.spanRadio).removeClass(defaults.spanSelected);
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
    if(!defaults.justClick) {
      wrappingInput(this);
    } else {
      clickingRadio(this);
      $(this).find('label').click(function(){
        $(this).parent().find('.' + defaults.spanRadio).trigger('click');
      });
    }
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
        onChangeSelect: false,
        disabledInput: 'select-disabled'
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
        if($(obj).attr('disabled')){
          if($(obj).data('inputselect')){
            styledSelect.attr('disabled', 'disabled');
          }
          styledSelect.addClass(defaults.disabledInput).siblings('.'+defaults.claseTrigger).addClass(defaults.disabledInput);
        }
        var valor = $(obj).children('option').eq(0).text(),
            classOption = '', inputValue;
        $(obj).children('option').each(function(i){
          if ($(this).attr('selected')){
            valor = $(this).text();
            if(i !== 0) {
              classOption = defaults.selectActive;
              inputValue = true;
            }
          }
        });
        if($(obj).children('option').eq(0).data('icon')) {
          classOption = classOption + ' ' + $(obj).children('option').eq(0).data('icon');
        }
        if($(obj).data('inputselect')) {
          styledSelect.attr('placeholder',$(obj).children('option').eq(0).text());
          if(inputValue){
            styledSelect.val(valor);
          }
        } else {
          styledSelect.text(valor);
        }
        styledSelect.addClass(classOption);
        addLista(obj);
      },
      addLista = function(obj){
        list = $('<ul />', {
          'class': defaults.ulOptions
        }).insertAfter($(obj).parent().find('span.'+ defaults.claseTrigger));
        for (var i = 0; i < numberOfOptions; i++) {
          var $opLi = $(obj).children('option').eq(i);
          $('<li />', {
            text: $opLi.text(),
            rel: $opLi.val(),
            'data-icon': $opLi.data('icon')
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
          if(!$(this).hasClass(defaults.disabledInput)){
            e.stopPropagation();
            $('.'+defaults.ulOptions).hide();
            $(obj).siblings('.'+ defaults.inputSelect).toggleClass(defaults.claseActivo);
            $(this).next('ul.'+ defaults.ulOptions).toggle();
          }
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
            styledSelect.val($this.text());
          } else {
            styledSelect.text($this.text());
          }
          styledSelect.removeClass(defaults.claseActivo)
              .addClass(defaults.selectActive);
          $(obj).val($this.attr('rel'));
          for(var o=0, opts = $(obj).children('option'); o < opts.length; o++){
            if(opts.eq(o).val() === $this.attr('rel')) {
              opts.eq(o).attr('selected', 'selected');
              if(o === 0){
                styledSelect.val('');
                styledSelect.removeClass(defaults.selectActive);
              }
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
 Begin customSlider3.js
 ********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CUSTOMSLIDER: Deslizar el rango para cambiar valor de bits
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  jQuery.fn.customSlider = function(options){
    var defaults = $.extend({
          wrapper: 'slider-wrapper',
          holder: 'slider-holder',
          handle: 'ui-slider-handle',
          bit: 'iconBit bit18px',
          amount: 'slider-amount',
          textValue: 'slider-textValue',
          textMin: 'slider-minValue',
          textMax: 'slider-maxValue',
          sliderBG: 'iconFont-slideBG',
        }, options),
        price, priceItem, datamax, realpriceItem, realprice, percent, percentItem,
        wrappingInput = function(obj){
          asignaValues(obj);
          $(obj).wrap('<div class="'+ defaults.wrapper +'"><div class="'+ defaults.holder +'"/>');
          $(obj).parent().append('<div class="' + defaults.sliderBG + '"></div><a href="#" class="' +  defaults.handle +'"><div class="'+ defaults.bit +'"><span class="iconBG"/><span class="iconFont-bit"/></div><span class="'+ defaults.amount +'">$<em>'+$(obj).val()+'</em></span></a>');
          $(obj).parent().parent().append('<span class="'+ defaults.textValue +' '+ defaults.textMin +'">'+$(obj).data('min')+'</span><span class="'+ defaults.textValue +' '+ defaults.textMax +'">'+datamax.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+'</span>');
          initSlider(obj);
        },
        asignaValues = function(obj){
          if($(obj).data('moveprice')){
            if($(obj).data('max') > price) {
              datamax = price;
            } else {
              datamax = $(obj).data('max');
            }
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
   Begin closeVideoHome.js
   ********************************************** */

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      CLOSEVIDEOHOME: Abre / Cierra div con el video y lo reinicia
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

jQuery.fn.closeVideoHome = function(options){
  var defaults = $.extend({
        videoOverlay : '.video-overlay',
        closeBtn: '.iconFont-close',
        video: '.video-frame',
        father: '.knowMoreMax',
        videoClass: 'video-toggle'
      }, options), src,
      clickingTrigger = function(obj, show){
        $(obj).click(function(){
          $(defaults.father).find(defaults.videoOverlay).toggleClass(defaults.videoClass);
          $(defaults.video).attr('src', show);
        });
      };
  return this.each(function(){
    src = $(defaults.video).attr('src');
    $(defaults.video).attr('src', '');
    clickingTrigger(this, src);
    clickingTrigger($(defaults.father).find(defaults.videoOverlay).find(defaults.closeBtn), '');
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
          closeBtn: '.miCuenta-close',
          beforeOpen: $.noop
        }, options), claseObj,
        clickingTrigger = function(obj){
          if (!$(obj).is(defaults.claseActivo) && defaults.beforeOpen() === false) {
            return;
          }
          $(obj).siblings(defaults.contenedor).stop(true, true).slideToggle($.noop,
          function(){
            if($('#wbi-cart-no-data').is(':visible')){
              window.setTimeout(function(){$('#wbi-cart-info').trigger('click');}, 3000);
            }
          }
          );
          $(obj).toggleClass(defaults.claseActivo);
        },
        closeSiblings = function(obj){
          $(obj).siblings(defaults.contenedor).stop(true, true).slideUp();
          $(obj).removeClass(defaults.claseActivo);
        };
    return this.each(function(){
      var objeto = this;
      var wpOb = $(objeto).next(defaults.contenedor).find(defaults.wrapper);
        claseObj = $(objeto).attr('class').split(' ')[0];
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
        $(obj).find(defaults.checkboxAll).parent().siblings(defaults.checkboxSpan).click(function(){
          var checkUnchec = $(this).attr('class').split(' ')[1];
          $(this).parent().siblings().each(function(){
            if(!$(this).find(defaults.checkboxSpan).hasClass(checkUnchec)){
              $(this).find(defaults.checkboxSpan).trigger('click');
            }
          });
        });
      },
      checkEach = function(obj){
        $(obj).parent().find(defaults.checkboxSpan).each(function(){
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
          $(this).prop('checked', false);
          $(this).parent().parent().find('.'+defaults.spanRadio).removeClass(defaults.spanSelected);
        });
      };
  return this.each(function(){
    checkAll(this);
    checkEach(this);
  });
};

/* **********************************************
 Begin requiredField.js
 ********************************************** */

// +++++++++++++++++++++++++++++++++++++++++
//      REQUIREDFIELD: Campos requeridos
//		Dependencias: toolTip.js
// +++++++++++++++++++++++++++++++++++++++++

//jQuery.fn.requiredField = function (options) {
//  var defaults = $.extend({
//        wrapper: 'required-wrapper',
//        icon: 'iconFont-star'
//      }, options),
//      wrappingInput = function(obj){
//        $(obj).wrap('<div class="'+ defaults.wrapper +'"/>');
//        $(obj).parent().append('<span class="'+ defaults.icon +'" data-tooltip="'+ $(obj).data('requiredfield')+'"/>');
//        $(obj).siblings('.'+defaults.icon).toolTip();
//      };
//  return this.each(function(){
//    wrappingInput(this);
//  });
//};

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      SCROLLPANE: Scroll que aparece / desaparece
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  jQuery.fn.scrollpane = function (options) {
    var defaults= $.extend({
          parent: '.scrollpane',
          horizontalDragMinWidth: 40,
          horizontalDragMaxWidth: 40,
          reinitialize: false,
          delay: 500
        }, options),
        initializeScrollPane = function(obj){
          $(obj).jScrollPane({
            horizontalDragMinWidth: defaults.horizontalDragMinWidth,
            horizontalDragMaxWidth: defaults.horizontalDragMaxWidth,
            autoReinitialise: defaults.reinitialize,
            autoReinitialiseDelay: defaults.delay
          });
        };
    return this.each(function(){
      if(defaults.parent) {
        if($(defaults.parent).css('display') === 'none') {
          $(defaults.parent).css('display', 'block');
          initializeScrollPane(this);
          $(defaults.parent).css('display', 'none');
        } else {
          initializeScrollPane(this);
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
})(window.jQuery);
