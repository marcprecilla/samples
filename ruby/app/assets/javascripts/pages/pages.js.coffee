# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  return unless $('body#pages').length == 1


  form_slider_1 = $('#form-slider-1')
  form_slider_2 = $('#form-slider-2')

  $('.paywall-flexslider').each ->
    flexslider_element = $(this)

    flexslider_element.flexslider({
      animation: "slide",
      animationLoop: false,
      slideshow: false,
      start: ->
        flexslider_element.attr('height',flexslider_element.height())
        flexslider_element.css({'height':0})
    });

    flexslider_element.find('a.slider-next').click (event) ->
      event.preventDefault()
      event.stopPropagation()
      flexslider_element.flexslider('next')
    flexslider_element.find('a.slider-prev').click (event) ->
      event.preventDefault()
      event.stopPropagation()
      flexslider_element.flexslider('prev')

  $('#form-1-plan-selector').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    $(this).removeClass('bluetext').removeClass('green').addClass('green')
    form_slider_1.animate({
      height: form_slider_1.attr('height')
    }, 500,'swing')
    $('#form-2-plan-selector').removeClass('bluetext').removeClass('green').addClass('bluetext')
    form_slider_2.animate({
      height: 0
    }, 500,'swing')

  $('#form-2-plan-selector').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    $(this).removeClass('bluetext').removeClass('green').addClass('green')
    form_slider_2.stop().animate({
      height: form_slider_2.attr('height')
    }, 500,'swing')
    $('#form-1-plan-selector').removeClass('bluetext').removeClass('green').addClass('bluetext')
    form_slider_1.animate({
      height: 0
    }, 500,'swing')