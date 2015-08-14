# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  return unless $('body#baseline_assessments').length == 1

  window.page_title = 'app - Personality Assessment'

  $('.transition-graphic').wrapInner('<div class="icon" />').wrapInner('<div class="inner" />')

  $('#baseline_assessments').find('.pam-grid').on('click','li',(event) ->
    event.preventDefault()
    $('.pam-grid li').removeClass('active')
    $(this).addClass('active')
    $('#pam_mood').val($(this).attr('app-data-id'))
    $('#pam_assessment_mood').val($(this).attr('app-data-id'))
    $('#navbar-button-left').removeClass().addClass('navbar-button').addClass('back').attr('app-data-state','back').attr('href','action:previousState');
  )

  $('form .btn-group').each ->
    group_container = $(this)
    group_container.find('.btn').click (e) ->
      e.preventDefault()
      value = $(this).val()
      group_container.parent().find('input[type=hidden]').val(value)

  $('.single-select-question').each ->
    question_container_element = $(this)
    $(this).find('.btn.next').click  (event) ->
      event.preventDefault()
      if question_container_element.hasClass('last')
        $(this).removeClass('disabled').addClass('disabled')
        setTimeout(->
          if $('body').hasClass('mini-baseline')
            if mixpanel?
              mixpanel.track("Finished Mini Baseline Assessment", {})
          $('#pam-question-form').submit()
        ,700)

  $('#congratulations-screen .btn').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    $('#pam-question-form').submit()

  $('#name-screen .btn').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    container_element = $(this).parents('#name-screen')
    name = container_element.find('input[name=name]').val()
    if name != ''
      screen_index = $(this).parents('.screen').index('.screen') + 1
      History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)
    else
      container_element.find('.error-container').text('Please enter your name.')


  $('.assessment-questions .multi-select-question').each ->
    question_container_element = $(this)
    container_elements = $(this).find('li')

    container_elements.each ->
      input_element = $(this).find('input[type=checkbox]')
      button_element = $(this).find('.btn')
      if input_element.is(":checked")
        button_element.addClass('active')
      button_element.click (event) ->
        event.preventDefault()
        input_element.click()

  if $('body#baseline_assessments.show').length > 0
    $('#navbar-button-left.back').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $('.page-flexslider').flexslider("previous")

    $('.page-flexslider ul.slides li').bind('onBeforeEnterFlexSlide', (event) ->
      add_body_class = $(this).attr('data-add-body-class')
      $('body').removeClass('bluebg').removeClass('darkbluebg')
      if add_body_class?
        $('body').removeClass(add_body_class).addClass(add_body_class)
    )
    $('.page-flexslider ul.slides li').bind('onEnterFlexSlide', (event) ->
      titlebar = $(this).attr('data-title')
      markerclass = 'marker-' + $(this).attr('data-marker-rel')
      markerdescription = $(this).attr('data-marker-description')
      slider_index = $(this).index('li.results-page')
      if titlebar?
        $('.navbar #title').html(titlebar)
      if $(this).is(':last-child')
        $('#results-submit-modal').modal('show');
      if markerclass?
        $('.results-progress-indicator li').removeClass('active')
        $('.results-progress-indicator li.' + markerclass).addClass('active')
      if markerdescription?
        $('.desktop-results-header .desktop-results-description').html(markerdescription)
      if slider_index >= 0
        $('.results-progress-indicator li .flex-nav-container a').removeClass('active')
        for i in [0..slider_index] by 1
          $('.results-progress-indicator li .flex-nav-container a').eq(i).addClass('active')
    )
    $('.desktop-results-header .flex-nav-container a').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      nav_index = parseInt($(this).attr('data-flex-rel'))
      $('.page-flexslider').flexslider(nav_index)

    $('#results-submit-modal .button-container .btn').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      form_element = $('#results-submit-modal form');
      input_valid = 1

      email = form_element.find('input[name=email]').val()
      #alert(email + ':' + window.checkEmail(email))
      if window.checkEmail(email)
        if _gaq?
          _gaq.push(['_trackEvent', 'buttons', 'submit', 'Lead Captured']);
        $.ajax({
          type: "PUT",
          url: form_element.attr("action"),
          data: form_element.serialize(), success: (data) ->
            console.log('success')
          , dataType: "json"
        })

      else
        form_element.find('.error-container').text('The email you have entered is invalid.')
        input_valid = 0

      if input_valid
        $('#results-submit-modal').modal('hide');


  $('body#baseline_assessments.show .btn.flex-next').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    input_valid = 1

    if $(this).parents('.email-page').length > 0
      form_element = $(this).parents('.email-page').find('form')
      email = form_element.find('input[name=email]').val()
      if window.checkEmail(email)
        if _gaq?
          _gaq.push(['_trackEvent', 'buttons', 'submit', 'Lead Captured']);
        $.ajax({
          type: "PUT",
          url: form_element.attr("action"),
          data: form_element.serialize(), success: (data) ->
            console.log('success')
          , dataType: "json"
        })
      else
        form_element.find('.error-container').text('The email you have entered is invalid.')
        input_valid = 0

    if input_valid
      $('.page-flexslider').flexslider("next")


  $('body#baseline_assessments.show .core-skills li').each ->
    curr_percentage = parseInt($(this).attr('data-percentage'))
    $(this).find('.active-img').css({'paddingTop':curr_percentage})

  if $('form.assessment-questions').length > 0 && !window.renderScreen?

    $('.screen').bind('afterLeaveScreen', (event, destination_index) ->
      visible_screen = $(this)
      group_name = visible_screen.attr('data-rel')
      related_screen_class = 'group-' + group_name
      current_index = $(this).prevAll('.screen').length
      current_group_index = $(this).prevAll('.' + related_screen_class).length
      if destination_index > current_index
        group_arc_path = group_name + '-arc-path'
        group_arc_path_large = group_name + '-arc-path-large'
        percentage = Math.ceil((current_group_index + 1) / $('.' + related_screen_class).length * 100)
        if $('#main-assessment-navigation:visible').length > 0
          window.drawAssessmentNav(group_arc_path,percentage)
        else if $('#main-assessment-navigation-large:visible').length > 0
          window.drawAssessmentNav(group_arc_path_large,percentage)

      destination_screen_selector = $('.screen').eq(destination_index)
      if destination_screen_selector.hasClass('transition-screen')
        if mixpanel?
          mixpanel.track("Passed Baseline Assessment Interstitial", {})
        navgroup = $(this).attr('data-rel')
        $('#current-section-nav-large li.' + navgroup).addClass('complete')
        section_label = $(this).attr('data-title')
        $('#desktop-assessment-nav-subheader').text("Thank you for completing the " + section_label + " section of our assessment.");

      if $(this).attr('id') == 'start-screen' && $('body').hasClass('mini-baseline')
        if mixpanel?
          mixpanel.track("Started Mini Baseline Assessment", {})

    )

    $('.screen').bind('afterShowScreen', (event) ->
      screen_index = $(this).index('.screen')
      titlebar = $(this).attr('data-title')
      $('.navbar #title').text(titlebar)

      submit_value =  $(this).find('.submit-value input').val()
      if submit_value == ''
        $(this).find('.submit-value input').val('3')

      nav_question_index = $(this).attr('data-question-index')
      if nav_question_index?
        $('#nav-question-index').text(nav_question_index);

      $('body').removeClass('bluebg').removeClass('darkbluebg')
      add_body_class = $(this).attr('data-add-body-class')
      if add_body_class?
        $('body').removeClass(add_body_class).addClass(add_body_class)
        if add_body_class == 'bluebg'
          $('#main-assessment-navigation').hide()
          $('#main-assessment-navigation-large').hide()
        else
          $('#main-assessment-navigation').show()
          $('#main-assessment-navigation-large').show()

      if screen_index == 2 && $('input#name').val()?
        $('.dynamic-name').text($('input#name').val().split(" ")[0])

      if $(this).hasClass('transition-screen')
        navgroup = $(this).attr('data-rel')
        if navgroup?
          $('#current-section-nav li').removeClass('active')
          $('#current-section-nav li.' + navgroup).addClass('active')
          $('#current-section-nav-large li').removeClass('active')
          $('#current-section-nav-large li.' + navgroup).addClass('active')
      else if $(this).hasClass('multi-select-question') || $(this).hasClass('single-select-question')
        directions = $(this).attr('data-directions')
        $('#desktop-assessment-nav-subheader').html(directions);


      $(this).find('.checklist-1 li .icon').each ->
        #$(this).append($(this).height());
        if $(this).height() < 30
          $(this).css({'paddingTop':16, 'paddingBottom':16})

    )

    window.renderScreen = (screen_index) ->
      screen_selector = $('.screen')

  if $('body#baseline_assessments.new').length > 0

    $('.finish-later').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $('#pam-question-form').submit()


    window.drawAssessmentNav = (circle_element_id, value_percentage) ->
      circle = $('#' + circle_element_id)
      angle = parseInt(circle.attr('app-data-percentage')) * 3.6
      radius = parseInt(circle.attr('app-data-radius'))
      window.circleAnimationTimer = window.setInterval( ->
        angle +=2;
        radians= (angle/180) * Math.PI;
        x1 = radius + Math.sin(Math.PI) * radius;
        y1 = radius + Math.cos(Math.PI) * radius;

        x2 = radius + Math.sin(Math.PI - radians) * radius;
        y2 = radius + Math.cos(Math.PI - radians) * radius;

        x3 = radius + Math.sin(Math.PI - (359.99/180) * Math.PI) * radius;
        y3 = radius + Math.cos(Math.PI - (359.99/180) * Math.PI) * radius;

        if angle > 357
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 1,1 " + x3 + "," + y3 + "z";
        else if angle > 180
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 1,1 " + x2 + "," + y2 + "z";
        else
          d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 0,1 " + x2 + "," + y2 + "z";
        circle.attr("d", d);

        if angle >= (value_percentage * 3.6)
          window.clearInterval(window.circleAnimationTimer)
          circle.attr('app-data-percentage',value_percentage)
      ,10)

  $('.marker-icon').each ->
    if $(this).hasClass('glowing')
      $(this).wrapInner('<div class="shine" />').wrapInner('<div class="image" />').wrapInner('<div class="inner" />').wrapInner('<div class="outer-0" />').wrapInner('<div class="outer-1" />').wrapInner('<div class="outer-2" />').wrapInner('<div class="outer-3" />')
    else
      $(this).wrapInner('<div class="shine" />').wrapInner('<div class="image" />').wrapInner('<div class="inner" />').wrapInner('<div class="outer-0" />').wrapInner('<div class="outer-1" />')





  window.resizeCanvas()
