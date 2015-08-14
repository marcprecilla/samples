# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  return unless $('body#three_sixty_assessments').length == 1

  $('.screen').bind('afterShowScreen', (event) ->
    screen_index = $(this).index('.screen')
    titlebar = $(this).attr('data-title')
    $('.navbar #title').text(titlebar)

    submit_value =  $(this).find('.submit-value input').val()
    if submit_value == ''
      $(this).find('.submit-value input').val('3')

    $('body').removeClass('bluebg').removeClass('darkbluebg')
    add_body_class = $(this).attr('data-add-body-class')
    if add_body_class?
      $('body').removeClass(add_body_class).addClass(add_body_class)
  );

  $('.sms-invite input[type=text]').keypress((e) ->
    if e.which == 13
      e.preventDefault()
      e.stopPropagation()
      form_element = $(this).parents('.sms-invite')
      name = form_element.find('input[name=input-name]').val()
      number = form_element.find('input[name=input-number]').val()
      num_invites = form_element.find('.invite-list li').length
      if window.trim(name) != '' && window.trim(number) != ''
        new_html = "<li id=\"invite-" + (num_invites + 1) + "\">"
        new_html += "<input class=\"input-invite-name\" type=\"hidden\" name=\"invitees[][name]\" value=\"\" />"
        new_html += "<input class=\"input-invite-number\" type=\"hidden\" name=\"invitees[][mobile_number]\" value=\"\" />"
        new_html += "<b>" + name + "</b> " + number + "<a href=\"#\" class=\"remove-item-button\">x</a></li>";
        form_element.find('.invite-list').prepend(new_html)
        form_element.find('.invite-list li#invite-' + (num_invites + 1) + ' .input-invite-name').val(name)
        form_element.find('.invite-list li#invite-' + (num_invites + 1) + ' .input-invite-number').val(number)
        form_element.find('input[name=input-name]').val('')
        form_element.find('input[name=input-number]').val('')
        window.rebuildRemoveButtons()
      else
        alert("Please enter both a name and SMS number.")
  );

  $('.email-invite input[type=text]').keypress((e) ->
    if e.which == 13
      e.preventDefault()
      e.stopPropagation()
      form_element = $(this).parents('.email-invite')
      name = form_element.find('input[name=input-name]').val()
      email = form_element.find('input[name=input-email]').val()
      num_invites = form_element.find('.invite-list li').length
      if window.trim(name) != '' && window.trim(email) != ''
        new_html = "<li id=\"invite-" + (num_invites + 1) + "\">"
        new_html += "<input class=\"input-invite-name\" type=\"hidden\" name=\"invitees[][name]\" value=\"\" />"
        new_html += "<input class=\"input-invite-email\" type=\"hidden\" name=\"invitees[][email]\" value=\"\" />"
        new_html += "<b>" + name + "</b> " + email + "<a href=\"#\" class=\"remove-item-button\">x</a></li>";
        form_element.find('.invite-list').prepend(new_html)
        form_element.find('.invite-list li#invite-' + (num_invites + 1) + ' .input-invite-name').val(name)
        form_element.find('.invite-list li#invite-' + (num_invites + 1) + ' .input-invite-email').val(email)
        form_element.find('input[name=input-name]').val('')
        form_element.find('input[name=input-email]').val('')
        window.rebuildRemoveButtons()
      else
        alert("Please enter both a name and Email.")
  );

  $('.checkbox-switch').each ->
    related_checkbox = $(this).parent().find('input[type=checkbox]')
    if related_checkbox.prop( "checked" )
      $(this).removeClass('on').addClass('on')


  $('.image-list').each ->
    image_list_element = $(this)
    $(this).find('li').each ->
      details_html = "";
      if details_html != ''
        details_html = "<div class=\"detail-icon-row\">" + details_html + "</div>"
      $(this).append(details_html)
      $(this).find('.description-details').prepend("<span class='pointer'>^</span>").wrap('<div class="description-details-container" />')
      $(this).wrapInner('<div class="description" />')
      if $(this).attr('data-img-src')?
        $(this).append('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div></div>')

      list_item_element = $(this)
      list_item_element.wrapInner('<a href="#" />')
      related_checkbox = list_item_element.find('input[type=checkbox]')

      list_item_element.removeClass('on')
      if related_checkbox.prop( "checked" )
        list_item_element.removeClass('on').addClass('on')

      list_item_element.find('a').click (event) ->
        event.stopPropagation();
        event.preventDefault();
        if list_item_element.hasClass('on')
          list_item_element.removeClass('on')
          related_checkbox.prop("checked",0)
        else
          list_item_element.removeClass('on').addClass('on')
          related_checkbox.prop("checked",1)


    $(this).find('li').each ->
      if $(this).outerHeight() > 80
        $(this).find('.description').css({'paddingTop':15, 'paddingBottom':15})

  $('form button[type=submit]').click (event) ->
    event.stopPropagation();
    event.preventDefault();
    parent_form = $(this).parents('form')
    $.ajax({
      type: "POST",
      url: parent_form.attr("action"),
      data: parent_form.serialize(),
      success: (data) ->
        console.log('success')
        completion_screen_index = $('.screen').length - 1
        History.pushState({screen:completion_screen_index}, window.page_title, "?screen=" + completion_screen_index)
      ,
      error: (errorThrown) ->
       console.log(errorThrown)
       completion_screen_index = $('.screen').length - 1
       History.pushState({screen:completion_screen_index}, window.page_title, "?screen=" + completion_screen_index)
      dataType: "json"
    })


  window.rebuildRemoveButtons = () ->
    $('.remove-item-button').click (event) ->
      $(this).parents("li").remove()

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
        navgroup = $(this).attr('data-rel')
        $('#current-section-nav-large li.' + navgroup).addClass('complete')
        section_label = $(this).attr('data-title')
        $('#desktop-assessment-nav-subheader').text("Thank you for completing the " + section_label + " section of our assessment.");

    )

    $('.screen').bind('afterShowScreen', (event) ->
      screen_index = $(this).index('.screen')
      titlebar = $(this).attr('data-title')
      $('.navbar #title').text(titlebar)

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
      else if $(this).attr('id') == 'three-sixty-congratulations-screen'
        parent_form = $(this).parents('form')
        $.ajax({
          type: "PUT",
          url: parent_form.attr("action"),
          data: parent_form.serialize(),
          success: (data) ->
            console.log('success')
          ,
          error: (errorThrown) ->
           console.log(errorThrown)
          dataType: "json"
        })


      $(this).find('.checklist-1 li .icon').each ->
        #$(this).append($(this).height());
        if $(this).height() < 30
          $(this).css({'paddingTop':16, 'paddingBottom':16})

    )

    window.renderScreen = (screen_index) ->
      screen_selector = $('.screen')

  if $('body#three_sixty_assessments.edit').length > 0

    window.page_title = 'app - 360 Assessment'
    $('.transition-graphic').wrapInner('<div class="icon" />').wrapInner('<div class="inner" />')


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
