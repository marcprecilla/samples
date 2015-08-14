window.vb_color_list = ['red','orange','blue','purple','magenta','green']
window.page_title = $(document).attr('title')

window.scaffolding_init = () ->
  $(window).resize (event) ->
    if !$(event.target).hasClass('ui-resizable')
      window.resizeCanvas()

  if $('.screen').length <= 0
    window.populateToolTip($('.main-tool-tip'))

  ###google analytics###
  $('.ga-tracked').click (event) ->
    ga_category = $(this).attr('data-ga-category')
    ga_action = $(this).attr('data-ga-action')
    ga_label = $(this).attr('data-ga-label')
    if ga_category? && ga_action? && ga_label? && _gaq?
      _gaq.push(['_trackEvent', ga_category, ga_action, ga_label]);
      console.log(ga_label)

  ###virtual keyboard fix###
  $('input').blur (event) ->
    setTimeout(->
      $("body").css("height", "+=1").css("height", "-=1")
    , 0);

  $('.modal-default-on').modal('show')

window.resizeCanvas = () ->
   if $('body').hasClass('skip-resize-canvas')
      return

   window_height = $(window).height()
   if navigator.userAgent.match(/(iPhone|iPod)/)
    window_height += 60
   $('#sidebar-left').height(window_height)
   if $('.navbar.navbar-fixed-top:visible').length > 0
    $('#main').css({'paddingTop':46})
   else
    $('#main').css({'paddingTop':0})
   window.resetCanvas()
   window.styleCanvasBottom()
   window.styleVerticalCenter()
   if window.resizeCanvasAdditional?
     window.resizeCanvasAdditional()

   if $('.fulloverlay').length > 0
    if $(window).height() > $('#main-canvas').height()
      $('.fulloverlay').height($(window).height())
    else
      $('.fulloverlay').height($('#main-canvas').height())

window.resetCanvas = () ->
   $('#main').css({'height':'auto'})
   $('.vertical-center-outer').css('padding',0)

window.styleVerticalCenter = () ->
  $('.vertical-center:visible').each ->
    $(this).find('.vertical-center-outer').css('padding',0)
    window_height = $(window).height()
    if navigator.userAgent.match(/(iPhone|iPod)/)
      window_height += 60
    main_container_element = $('#main')
    main_padding_height = main_container_element.outerHeight() - main_container_element.height()
    canvas_height = main_container_element.height() - $('.canvas-bottom:visible').height()
    if window_height >= main_container_element.outerHeight()
     if $(this).outerHeight() < canvas_height
       content_height = $(this).find('.vertical-center-inner').outerHeight()
       padding_height = Math.round((canvas_height - content_height) / 2)
       $(this).find('.vertical-center-outer').css('paddingTop',padding_height)

window.styleCanvasBottom = () ->
  window_height = $(window).height()
  main_container_element = $('#main')
  main_padding_height = main_container_element.outerHeight() - main_container_element.height()
  if navigator.userAgent.match(/(iPhone|iPod)/)
    window_height += 60
  $('.canvas-bottom').css('position','static')
  if window_height > $('#main').outerHeight()
   if $('.navbar.navbar-fixed-top:visible').length > 0
     main_container_element.css('height',window_height - main_padding_height);
   else
     main_container_element.css('height',window_height - main_padding_height);
   $('.canvas-bottom').css({'position': 'absolute','bottom',0})



window.renderScreens = (screen_index) ->
  screen_selector = $('.screen')
  previous_screen_selector = $('.screen:visible')
  previous_screen_selector.trigger("afterLeaveScreen",[screen_index])
  screen_selector.hide()
  selected_screen_selector = screen_selector.eq(screen_index)
  selected_screen_selector.show()
  window.updateFooterProgress(screen_index)
  window.resizeCanvas()
  window.scrollToTop()
  window.populateToolTip(selected_screen_selector)
  selected_screen_selector.trigger("afterShowScreen")
  if window.renderScreen?
    window.renderScreen(screen_index)


window.toggleSideBar = () ->
    state = $('#sidebar-left').attr('app-data-state')
    slide_width = $('#sidebar-left').width()
    sidebar_element = $('#sidebar-left')
    if state == 'on'
      $('.navbar.navbar-fixed-top:visible #navbar-button-right').show()
      sidebar_element.attr('app-data-state','off')
      $('#main, .navbar, .shift-with-sidenav').animate(
        { left: 0 },
        200,
        'swing'
      );
      sidebar_element.animate(
        { left: (slide_width * -1) },
        200,
        'swing',
        ->
          sidebar_element.hide()
      );
    else
      $('.navbar.navbar-fixed-top:visible #navbar-button-right').hide()
      sidebar_element.show()
      sidebar_element.attr('app-data-state','on')
      $('#main, .navbar, .shift-with-sidenav').animate(
        { left: slide_width },
        200,
        'swing'
      );
      sidebar_element.animate(
        { left: 0 },
        200,
        'swing'
      );

window.togglePopunder = () ->
    state = $('#popunder').attr('app-data-state')
    if state == 'on'
      $('#popunder').attr('app-data-state','off')
      $('#popunder').animate(
        { bottom: -300 },
        200,
        'swing',
        ->
          $('#popunder').css('display','none')
      );
    else
      $('#popunder').css('display','block')
      $('#popunder').attr('app-data-state','on')
      $('#popunder').animate(
        { bottom: 0 },
        200,
        'swing'
      );

$ ->
  $('.navbar-button').click  (event) ->
    event.preventDefault()
    event.stopPropagation()

    section_selector = '#' + $(this).attr('href')

    if $(this).attr('href').indexOf("/") != -1
      self.location = $(this).attr('href')
    else if $(this).attr('href').indexOf("action:") != -1
      switch($(this).attr('href'))
        when "action:submitPam"
          $('#pam-assessment form').submit()
          $('.navbar-button.right').removeClass($('.navbar-button.right').attr('app-data-state')).addClass('none');
          $('.navbar-button.right').attr('app-data-state','none');
          $('.navbar-button.right').attr('href','');
        when "action:submitPamQuestion"
          window.submitPamQuestion()
        when "action:toggleSideBar"
          window.toggleSideBar()
        when "action:previousQuestion"
          window.previousAssessmentQuestion()
        when "action:previousOnboardQuestion"
          window.previousOnboardQuestion()
        when "action:toggleToolTip"
          window.toggleToolTip()
        when "action:previousState"
          History.back()


window.drawSVGElements = () ->
  window.drawCircle()

window.circleAnimationTimer = ''
window.circleAnimationDeltaTimer = ''

window.drawCircle = () ->
  $('.progress-graph-circle-container.do-animation').each ->
    if $(this).find("#arc-path").length > 0
      circle = $(this).find("#arc-path")
      label = $(this).find('.value')
      angle = 0;
      radius = parseInt(circle.attr('app-data-radius'))
      value_percentage = parseInt(circle.attr('app-data-percentage'))
      value_description = 'Peak'
      if value_percentage == 0
        value_description = ''
      else if value_percentage <= 30
        value_description = 'Low'
      else if value_percentage <= 50
        value_description = 'Medium'
      else if value_percentage <= 80
        value_description = 'High'
      label.html(value_percentage + '<label>' + value_description + '</label>')
      circle.attr("d", "M" + radius + "," + radius + " L" + radius + ",0 A" + radius + "," + radius + " 0 1,1 " + radius + ",0z";)
      window.circleAnimationTimer = window.setInterval( ->
        angle +=2;
        radians= (angle/180) * Math.PI;
        x1 = radius + Math.sin(Math.PI) * radius;
        y1 = radius + Math.cos(Math.PI) * radius;

        x2 = radius + Math.sin(Math.PI - radians) * radius;
        y2 = radius + Math.cos(Math.PI - radians) * radius;

        x3 = radius + Math.sin(Math.PI - (359/180) * Math.PI) * radius;
        y3 = radius + Math.cos(Math.PI - (359/180) * Math.PI) * radius;

        if angle > 357
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 1,1 " + x3 + "," + y3 + "z";
        else if angle > 180
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 1,1 " + x2 + "," + y2 + "z";
        else
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 0,1 " + x2 + "," + y2 + "z";
        circle.attr("d", d);

        if angle >= (value_percentage * 3.6)
          window.clearInterval(window.circleAnimationTimer)
          inner_radius = radius - 15
          label_x = (radius + Math.sin(Math.PI - radians) * inner_radius) - (label.outerWidth() / 2)
          label_y = (radius + Math.cos(Math.PI - radians) * inner_radius) - (label.outerHeight() / 2)
          label.css({'position':'absolute','top':label_y,'left':label_x,'opacity': 1.0})
      ,10)

    if $(this).find("#arc-delta").length > 0
      delta_circle = $(this).find("#arc-delta")
      delta_label = $(this).find('.delta-value')
      angle = 0;
      radius = parseInt(delta_circle.attr('app-data-radius'))
      delta_value_percentage = parseInt(delta_circle.attr('app-data-percentage'))
      delta_label.html(delta_value_percentage)
      delta_circle.attr("d", "M" + radius + "," + radius + " L" + radius + ",0 A" + radius + "," + radius + " 0 1,1 " + radius + ",0z";)
      window.circleAnimationDeltaTimer = window.setInterval( ->
        angle +=2;
        radians= (angle/180) * Math.PI;
        x1 = radius + Math.sin(Math.PI) * radius;
        y1 = radius + Math.cos(Math.PI) * radius;

        x2 = radius + Math.sin(Math.PI - radians) * radius;
        y2 = radius + Math.cos(Math.PI - radians) * radius;

        x3 = radius + Math.sin(Math.PI - (359/180) * Math.PI) * radius;
        y3 = radius + Math.cos(Math.PI - (359/180) * Math.PI) * radius;

        if angle > 357
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 1,1 " + x3 + "," + y3 + "z";
        else if angle > 180
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 1,1 " + x2 + "," + y2 + "z";
        else
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 0,1 " + x2 + "," + y2 + "z";
        delta_circle.attr("d", d);

        if angle >= (delta_value_percentage * 3.6)
          window.clearInterval(window.circleAnimationDeltaTimer)
          inner_radius = radius - 15
          label_x = (radius + Math.sin(Math.PI - radians) * inner_radius) - (delta_label.outerWidth() / 2)
          label_y = (radius + Math.cos(Math.PI - radians) * inner_radius) - (delta_label.outerHeight() / 2)
          delta_label.css({'position':'absolute','top':label_y,'left':label_x,'opacity': 1.0})
      ,10)

window.populateToolTip = (container_element) ->
  if container_element.find('.tip-container-content').length > 0
    header = container_element.find('.tip-container-header-content').html()
    body = container_element.find('.tip-container-body-content').html()
    ga_label = container_element.find('.tip-container-header-content').attr('data-ga-label')
    $('#tip-container-header').html(header)
    $('#tip-container-body').html(body)
    if ga_label?
      $('#tip-container-header').attr('data-ga-label',ga_label);
    $('#navbar-button-right').removeClass().addClass('navbar-button').addClass('brain-on');
    $('#navbar-button-right').attr('app-data-state','brain');
    $('#navbar-button-right').attr('href','action:toggleToolTip');
    $('.tip-container .icon a').click  (event) ->
      event.preventDefault()
      event.stopPropagation()
      window.toggleToolTip()
    $('.tip-container a.close-button').click  (event) ->
      event.preventDefault()
      event.stopPropagation()
      window.hideToolTip()

  else
    if $('#navbar-button-right').hasClass('brain-on')
      $('#navbar-button-right').removeClass('brain-on').addClass('none')

window.submitActivityForm = (container_obj, form_obj) ->
  form_obj.submit()

window.submitActivityFormAndForward = (container_obj, form_obj, url) ->
  window.submitActivityForm(container_obj, form_obj)

window.renderBootstrapTooltips = (container_obj) ->
  ###bootstrap tooltips###
  container_obj.find(".popover-trigger").popover({
    placement: (tip, element) ->
      isWithinBounds = (elementPosition) ->
        return boundTop < elementPosition.top && boundLeft < elementPosition.left && boundRight > (elementPosition.left + actualWidth) && boundBottom > (elementPosition.top + actualHeight);

      $element = $(element);
      pos = $.extend({}, $element.offset(), {
        width: element.offsetWidth,
        height: element.offsetHeight
      });
      actualWidth = 283;
      actualHeight = 117;
      boundTop = $(document).scrollTop();
      boundLeft = $(document).scrollLeft();
      boundRight = boundLeft + $(window).width();
      boundBottom = boundTop + $(window).height();
      elementAbove = {
        top: pos.top - actualHeight,
        left: pos.left + pos.width / 2 - actualWidth / 2
      };
      elementBelow = {
        top: pos.top + pos.height,
        left: pos.left + pos.width / 2 - actualWidth / 2
      };
      elementLeft = {
        top: pos.top + pos.height / 2 - actualHeight / 2,
        left: pos.left - actualWidth
      };
      elementRight = {
        top: pos.top + pos.height / 2 - actualHeight / 2,
        left: pos.left + pos.width
      };
      above = isWithinBounds(elementAbove);
      below = isWithinBounds(elementBelow);
      left = isWithinBounds(elementLeft);
      right = isWithinBounds(elementRight);
      if above
        return "top";
      else
        if below
          return "bottom"
        else
          if left
            return "left";
          else
            if right
              return "right";
            else
              return "right";





  })
