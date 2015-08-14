# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  return unless $('body#action_plan').length == 1

  if $('body#action_plan.desktop_scaffolding').length > 0

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
        #$('.activity-screens .action-plan-message').css({'display':'block'}).show()
        $('.activity-screens .meter-container-outer').show()
        $('.week-navigation').removeClass('disabled')
        window.renderActionPlanNavigation()
      else
        $('.activity-screens .week-header').hide()
        $('.activity-screens .action-plan-message').hide()
        $('.activity-screens .meter-container-outer').hide()
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
          img_html = ('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + graphic_element.attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div><span class="check">x</span></div>')
        else
          img_html = ('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + graphic_element.attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div></div>')
        graphic_element.empty()
        graphic_element.html(img_html)
        graphic_element.removeClass('has-img').addClass('has-img')
      else
        img_html = ''
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

    setTimeout(->
      window.alignHeights('.set-2 .module-header')
      window.alignHeights('.set-2 .description')
      window.alignHeights('.set-2 .button-container')
      window.alignHeights('.profile-info-content .no-data-container .no-data-description')
      window.alignHeights('.profile-info-content .my-personality label')
    , 100);

    $('.barchart-container').barChart({})
    $('.progress-bar').each ->
      $(this).wrapInner('<div class="progress-marker" />').wrapInner('<div class="inner" />')

    window.resizeProgress = () ->
      $('.progress-viewport').css({'width':$(this).width()})
      timeline_width = 18;
      $('.progress-activity-day-list .day-activity-container').each ->
        timeline_width += ($(this).outerWidth() + 0);
      $('.progress-activity-day-list .day-label').each ->
        if window.trim($(this).text()) != ''
          timeline_width += ($(this).outerWidth() + 12);

      $('.progress-activity-day-list').css({'width':timeline_width});

    window.animateCurrentBar = () ->
      target_height = parseInt($('.barchart-container .current-bar').attr('data-target-height'))
      if $('.barchart-container .current-bar').height() <= 0
        $('.barchart-container .current-bar').css({'height':target_height})

    window.updateDayIndicator = () ->
      if $('.day-label').length > 0
        selected_day = $('.day-label:in-viewport').last()

        #rel_class = selected_day.parent().attr('data-rel-day').toLowerCase()
        #rel_score = selected_day.parent().attr('data-rel-score').toLowerCase()
        #list_item = $('.days-week-list li.' + rel_class)
        #$('.days-week-list li').removeClass('active')
        #list_item.removeClass('active').addClass('active')

        rel_bar_class = 'bar-' + selected_day.parent().attr('data-rel-timestamp')
        bar_item = $('.bars-container .bar-group.' + rel_bar_class)
        $('.bars-container .bar-group').removeClass('active')
        bar_item.removeClass('active').addClass('active')
        window.animateCurrentBar()

    window.resizeProgress()
    window.updateDayIndicator()
    $('.timeline-viewport').scrollLeft($('.progress-activity-day-list').width())

    $('.personality-traits-list li').each ->
      #li_value = $(this).text()
      #icon_html = "<div class=\"marker-icon\"><div class=\"outer\"><div class=\"inner\"><div class=\"image\">" + li_value + "</div></div></div></div>";
      #$(this).prepend(icon_html)

    $('.profile-info-content .analysis li').each ->
      if $(this).attr('data-img-src')?
        img_html = ('<div class="img-padding"><div class="img" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div>')
        $(this).prepend(img_html)

    window.enableButtonsWithoutHistory($('#activity-screens'))

    $('.visionboard-screen-container').each ->
      container_obj = $(this)
      container_obj.find('.random-color').each (index)->
        random_color = window.vb_color_list[Math.floor(Math.random()*window.vb_color_list.length)]
        container_obj.find(this).removeClass(random_color).addClass(random_color)
      container_obj.find('.vb-row.thank-row').scrollLeft(container_obj.width())
      #container_obj.find('.visionboard-container .two-row ul li').width(Math.floor($(window).width() / 2) - 16)

    $(".drag-scrollable").each ->
      $(this).dragscrollable({dragSelector: '.dragger', acceptPropagatedEvent: true});

    $("a[href='#video-modal-tedx']").click (event) ->
      if mixpanel?
        mixpanel.track("View Paul TEDX Video", {})

    $("a[href='#video-modal']").click (event) ->
      if mixpanel?
        mixpanel.track("View Walkthrough Video", {})

