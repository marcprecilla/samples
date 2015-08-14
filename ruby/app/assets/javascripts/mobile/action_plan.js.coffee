# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  return unless $('body#action_plan').length == 1

  if $('body#action_plan.index').length > 0

    $('#modules-screen').each () ->
      num_modules = $(this).find('.activity-module').length
      $(this).removeClass('set-' + num_modules).addClass('set-' + num_modules)
      $(this).find('.activity-module').each (index) ->
        $(this).removeClass('pos-' + index).addClass('pos-' + index)
      switch(num_modules)
        when 1
          $(this).find('.btn').removeClass('size-minus-1').addClass('size-minus-1')
        when 2
          $(this).find('.btn').removeClass('size-minus-1').addClass('size-minus-1')
        when 3
          $(this).find('.pos-0 .btn').removeClass('size-minus-1').addClass('size-minus-1')
          $(this).find('.pos-1 .btn').removeClass('size-minus-2').addClass('size-minus-2')
          $(this).find('.pos-2 .btn').removeClass('size-minus-2').addClass('size-minus-2')
          $(this).find('.pos-1 .graphic').removeClass('small').addClass('small')
          $(this).find('.pos-2 .graphic').removeClass('small').addClass('small')

    window.renderActionPlanNavigation()

    window.adjustInterventionWeekNavigation = () ->
      week_list = $('.week-navigation')
      week_list_viewport = $('.mid-content')
      week_list_width = week_list.width()
      if $(window).width() < week_list_width
        week_list_viewport.width($(window).width())
      else
        week_list_viewport.width(week_list_width)

    window.adjustInterventionWeekNavigation()
    window.resizeCanvasAdditional = ->
      window.adjustInterventionWeekNavigation()
      $('#slide-1 .slide-content').height($(window).height() - 140)
      window.alignHeights('.intervention-title')


    window.updateActionPlanElements = (jq_obj) ->
      if !jq_obj.hasClass('cover-screen')
        $('.activity-screens .week-header').show()
        $('.activity-screens .meter-container-outer').show()
        $('.activity-screens .action-plan-message').css({'display':'block'}).show()
        $('.week-navigation').removeClass('disabled')
        window.renderActionPlanNavigation()
      else
        $('.activity-screens .week-header').hide()
        $('.activity-screens .meter-container-outer').hide()
        $('.activity-screens .action-plan-message').hide()
        $('.week-navigation').removeClass('disabled').addClass('disabled')
        window.renderActionPlanNavigation()


    $('.screen').bind('afterShowScreen', (event) ->
      screen_index = $(this).index('.screen')
      selected_btn = $('.week-navigation li label').eq(screen_index - 1)
      #$('.week-navigation li').removeClass('current')
      #selected_btn.parents('li').removeClass('current').addClass('current')
      window.updateActionPlanElements($(this))

      window.alignHeights('.set-2 .module-header')
      window.alignHeights('.set-2 .description')
      window.alignHeights('.set-2 .button-container')
    )

    window.updateActionPlanElements($('.screen:visible'))

    $('.activity-module').each ->
      graphic_element = $(this).find('.graphic')
      if graphic_element.attr('data-img-src')?
        img_html = ''
        if $(this).hasClass('complete')
          img_html = ('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + graphic_element.attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div><span class="graphic-check">x</span></div>')
        else
          img_html = ('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + graphic_element.attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div></div>')
        graphic_element.empty()
        graphic_element.html(img_html)
        graphic_element.removeClass('has-img').addClass('has-img')
      else
        graphic_element.removeClass('has-img')
        if $(this).hasClass('complete')
          img_html = ('<div class="img-container"><div class="img-padding"><div class="img">x</div></div><span class="graphic-check">x</span></div>')
        else
          img_html = ('<div class="img-container"><div class="img-padding"><div class="img">x</div></div></div>')
        graphic_element.empty()
        graphic_element.html(img_html)


    $('body#action_plan.index').find('a.walkthrough-nav-button').click (event) ->
      event.preventDefault()
      event.stopPropagation()
      screen_index = $(this).attr('href')
      walkthrough_container_selector = $('.walkthrough-container')
      navbar_button_left_element = $('#navbar-button-left')
      navbar_button_right_element = $('#navbar-button-right')
      walkthrough_container_selector.hide();
      $('.walkthrough-container[app-data-screen-index=' + screen_index + ']').show()
      if parseInt(screen_index) == 1
        History.pushState({screen:0}, "Stress Less", "?screen=0")
        $('.screen').eq(0).trigger('onURLScreenLoad')
      if parseInt(screen_index) == 2
        History.pushState({screen:1}, "Stress Less", "?screen=1")
        $('.screen').eq(1).trigger('onURLScreenLoad')
      else if parseInt(screen_index) == 3
        navbar_button_left_element.removeClass().addClass('navbar-button').addClass('menu')

    $('body#action_plan.index a.walkthrough-close-button').click (event) ->
      event.preventDefault()
      event.stopPropagation()
      navbar_button_left_element = $('#navbar-button-left')
      navbar_button_right_element = $('#navbar-button-right')
      navbar_button_left_element.removeClass().addClass('navbar-button').addClass('menu').attr('href','action:toggleSideBar')
      navbar_button_right_element.removeClass().addClass('navbar-button');
      $('.walkthrough-container').hide()
      History.pushState({screen:0}, "Stress Less", "?screen=0")
      $('.screen').eq(0).trigger('onURLScreenLoad')

    $('body#action_plan.index .flex-next').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $('.page-flexslider').flexslider("next")

    $('body#action_plan.index .flex-previous').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $('.page-flexslider').flexslider("previous")

    $('body#action_plan.index .btn.flex-close').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $('.action-plan-walkthrough').hide()

    $('.page-flexslider ul.slides li').bind('onEnterFlexSlide', (event) ->
      slider_index = $(this).index('li.walkthrough-slide')
      if slider_index == ($('.page-flexslider ul.slides li').length - 1)
        $('.close-button').hide()
      else
        $('.close-button').show()
    )

    window.loadLessonsRSS();

    setTimeout(->
      window.alignHeights('.set-2 .module-header')
      window.alignHeights('.set-2 .description')
      window.alignHeights('.set-2 .button-container')
    , 100);

