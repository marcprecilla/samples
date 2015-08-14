window.buildComponents = (container_obj) ->

  container_obj.find('.vertical-center').wrapInner('<div class="vertical-center-inner" />').wrapInner('<div class="vertical-center-outer" />')
  container_obj.find('.btn-group.btn-group-radio').each ->
    container_element = $(this)
    $(this).addClass('btn-group-' + $(this).find('button').length)

  container_obj.find('.btn-group.btn-group-circle').each ->
    container_element = $(this)
    container_element.find('button').each ->
      $(this).removeClass('btn-circle').addClass('btn-circle')
      inherited_classes = ['fullimg','size-plus-1']
      for inherited_class, i in inherited_classes
        if container_element.hasClass(inherited_class)
          $(this).removeClass(inherited_class).addClass(inherited_class)
    if container_element.hasClass('layout-pyramid-up')
      container_element.find('button').each ->
        $(this).wrap('<div class="button-container">')
      container_element.find('.button-container:eq(1)').css({'clear':'both'})
      container_element.find('.button-container:eq(1)').css({'display':'inline-block','float':'left','margin-right':15,'position':'relative','top':-20})
      container_element.find('.button-container:eq(2)').css({'display':'inline-block','float':'right','margin-left':15,'position':'relative','top':-20})
    else if container_element.hasClass('layout-pyramid-down')
      container_element.find('button').each ->
        $(this).wrap('<div class="button-container">')
      container_element.find('.button-container:eq(0)').css({'display':'inline-block','float':'left','margin-right':15})
      container_element.find('.button-container:eq(1)').css({'display':'inline-block','float':'right','margin-left':15})
      container_element.find('.button-container:eq(2)').css({'position':'relative','top':-20, 'clear':'both'})

  container_obj.find('.btn-group.btn-group-circle-simple').each ->
    container_element = $(this)
    container_element.find('button').each ->
      $(this).removeClass('btn-circle').addClass('btn-circle-simple')
      position_class = 'pos-' + $(this).index()
      $(this).removeClass(position_class).addClass(position_class)
      inherited_classes = ['size-minus-1','with-label']
      for inherited_class, i in inherited_classes
        if container_element.hasClass(inherited_class)
          $(this).removeClass(inherited_class).addClass(inherited_class)

  container_obj.find('.btn-group.btn-group-square-simple').each ->
    container_element = $(this)
    $(this).removeClass('btn-group-' + $(this).find('button').length)
    container_element.find('.btn').each ->
      $(this).removeClass('btn-square-simple').addClass('btn-square-simple')
      position_class = 'pos-' + $(this).index()
      $(this).removeClass(position_class).addClass(position_class)
      inherited_classes = ['size-minus-1']
      for inherited_class, i in inherited_classes
        if container_element.hasClass(inherited_class)
          $(this).removeClass(inherited_class).addClass(inherited_class)


  container_obj.find('.btn.btn-border').wrapInner('<div class="icon" />').wrapInner('<div class="inner" />').wrapInner('<div class="inner-border" />').wrapInner('<div class="outer" />')
  container_obj.find('.btn.btn-border-simple').wrapInner('<div class="icon" />').wrapInner('<div class="inner" />').wrapInner('<div class="inner-border" />')

  container_obj.find('.btn.btn-circle').each ->
    text_value = $(this).text()
    $(this).html('<div class="outer"><div class="inner"><div class="image"></div></div></div><div class="label">' + text_value + '</div></div>')

  container_obj.find('.btn.btn-circle-simple').each ->
    text_value = $(this).text()
    html_value = ""
    if $(this).attr('data-mask-url')?
      html_value = '<div class="outer"><div class="image" style="mask: url(\'#' + $(this).attr('data-mask-url') + '\');">' + text_value + '</div></div>'
    else
      html_value = '<div class="outer"><div class="image">' + text_value + '</div></div>'
    if text_value != '' && $(this).hasClass('with-label')
      html_value += '<div class="label">' + text_value + '</div>'
    $(this).html(html_value)

  container_obj.find('.btn.btn-square').each ->
    text_value = $(this).text()
    data_img_src = ''
    if $(this).attr('data-img-src')?
      data_img_src = $(this).attr('data-img-src')
    if $(this).hasClass('smallimg')
      if data_img_src != ''
        $(this).html('<div class="outer"><div class="inner"><div class="image" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;"></div><div class="label">' + text_value + '</div></div></div>')
      else
        $(this).html('<div class="outer"><div class="inner"><div class="image"></div><div class="label">' + text_value + '</div></div></div>')
    else
      if data_img_src != ''
        $(this).html('<div class="outer"><div class="inner"><div class="image" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;"></div></div></div><div class="label">' + text_value + '</div>')
      else
        $(this).html('<div class="outer"><div class="inner"><div class="image"></div></div></div><div class="label">' + text_value + '</div>')


  container_obj.find('.btn.btn-square-simple').each ->
    text_value = $(this).html()
    data_img_src = ''
    if $(this).attr('data-img-src')?
      data_img_src = $(this).attr('data-img-src')
    if data_img_src != ''
      $(this).html('<div class="inner" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;"><div class=\"btn-content\">' + text_value + '</div></div>')
    else
      $(this).html('<div class="inner"><div class=\"btn-content\">' + text_value + '</div></div>')

    content_element = $(this).find('.btn-content')
    content_container_element = $(this).find('.inner')
    content_element.css({'height':content_container_element.innerHeight(),'width':content_container_element.innerWidth()})



  container_obj.find('.header-circle').each ->
    text_value = $(this).html()
    if $(this).attr('data-img-src')?
      $(this).html('<div class="outer"><div class="inner"><div class="image" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;"></div></div></div><div class="label-container"><div class="label">' + text_value + '</div></div></div>')
    else
      $(this).html('<div class="outer"><div class="inner"><div class="image"></div></div></div><div class="label-container"><div class="label">' + text_value + '</div></div></div>')

  container_obj.find('.animated-meter').each ->
    text_value = $(this).text()
    percentage_value = $(this).attr('data-percentage')
    $(this).html('<label>' + text_value + '</label><div class="meter"><div class="view-container"><div class="outer"><div class="inner">' + percentage_value + '%</div></div></div></div>')
    .bind('afterShow', ->
      $(this).find('.view-container').animate(
        { width: percentage_value + '%' },
        600,
        'swing'
        );
      )
    if !$(this).hasClass('wait-for-trigger')
      $(this).trigger('afterShow')


  ###char counter###
  container_obj.find('.use-char-counter').each ->

    charCountHolder = $(this).parent().find('.char-counter');
    if $(this).attr('maxlength')? && charCountHolder.length > 0
      maxlength = parseInt($(this).attr('maxlength'));
      container_element = $(this);
      charCountHolder.html(maxlength - container_element.val().length)
      container_element.keyup((event) ->
        char_count = container_element.val().length;
        char_left = maxlength - char_count;
        if char_count <= maxlength
          charCountHolder.html(char_left)
        else
          event.preventDefault();
      )


  container_obj.find(':not(#main-canvas)').on('click', (e) ->
      $('.popover-trigger').each ->
          if !$(this).is(e.target) && $(this).has(e.target).length is 0 && $('.popover').has(e.target).length is 0
              $(this).popover('hide');
              return;
  )

  container_obj.find('#tooltip-modal .modal-close-button').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    container_obj.find('#tooltip-modal').modal('hide')

  container_obj.find('.content-modal .modal-close-button').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    $(this).parents('.content-modal').modal('hide')



  container_obj.find('.tooltip-modal-trigger').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    tooltip_modal_element = container_obj.find('#tooltip-modal')
    tooltip_modal_element.find('.modal-header-content').html($(this).attr('data-original-title'));
    tooltip_modal_element.find('.modal-body-content').html($(this).attr('data-content'));
    container_obj.find('#tooltip-modal').modal('show');

  ###
  question slider
  ###
  container_obj.find( ".question-slider").bootstrap_slider({
   value:3,
   min: 1,
   max: 5,
   step: 1,
   tooltip: 'hide',
   selection: 'none'
  }).on('slideStop',(ev) ->
     handle_parent_element = $(this).parents('.single-select-question')
     slider_handle_element = handle_parent_element.find('.slider-handle')
     position = slider_handle_element.position()
     track_width = handle_parent_element.find('.slider-track').width() + 20
     value = Math.floor(position.left / track_width * 5) + 1
     #value = handle_parent_element.find('.tooltip-inner').text()

     handle_parent_element.find('.submit-value input').val(value)
     answer_label = handle_parent_element.find('.answer-list li.answer-' + value).text()
     handle_parent_element.find('.answer-label').text(answer_label)
  );

  ###
  question ranking
  ###
  container_obj.find(".question-ranking").each ->
    $(this).find(".rank-list").sortable({
      stop: (event,ui) ->
        parent_element = ui.item.parents('.question-ranking')
        value_element = parent_element.find('.submit-value input')
        rank_value = ""
        parent_element.find('.rank-list li').each ->
          if $(this).attr('data-value')?
            rank_value += $(this).attr('data-value') + ' '
        value_element.val(rank_value)
    })


  ###
  flexslider
  ###
  container_obj.find('.page-flexslider').each ->
    flexslider_element = $(this)

    use_touch = true
    if $(this).hasClass('no-swipe')
      use_touch = false

    flexslider_element.flexslider({
      animation: "slide",
      animationLoop: false,
      slideshow: false,
      useCSS: false,
      keyboard: false,
      touch: use_touch,
      start: ->
        window.resizeCanvas()
      after: (slider) ->
        thisSlide = slider.slides.eq(slider.currentSlide);
        $(thisSlide).trigger('onEnterFlexSlide')
      before: (slider) ->
        animateSlide = slider.slides.eq(slider.animatingTo);
        $(animateSlide).trigger('onBeforeEnterFlexSlide')
    });

  ##panels##
  container_obj.find('.panels-container').each ->
    matching_screens_selector = '#' + $(this).attr('id') + ' li'
    current_panel_index = $(this).find('li.active').index(matching_screens_selector) + 1
    $(this).find('.panel-navigation span').text(current_panel_index + ' of ' + $(this).find('li').length)
    if $(this).find('li').length == 1
      $(this).find('.panel-navigation .button-left').removeClass('disabled').addClass('disabled')
      $(this).find('.panel-navigation .button-right').removeClass('disabled').addClass('disabled')

    $(this).find('.button-left').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      panels_container_element = $(this).parents('.panels-container')
      matching_screens_selector = '#' + panels_container_element.attr('id') + ' li'
      current_panel_index = panels_container_element.find('li.active').index(matching_screens_selector)
      previous_panel_index = current_panel_index - 1
      num_panels = panels_container_element.find('li').length
      if previous_panel_index < 0
        previous_panel_index = num_panels - 1
      panels_container_element.find('li').removeClass('active')
      panels_container_element.find('li').eq(previous_panel_index).addClass('active')
      panels_container_element.find('.panel-navigation span').text((previous_panel_index + 1) + ' of ' + num_panels)

    $(this).find('.button-right').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      panels_container_element = $(this).parents('.panels-container')
      matching_screens_selector = '#' + panels_container_element.attr('id') + ' li'
      current_panel_index = panels_container_element.find('li.active').index(matching_screens_selector)
      next_panel_index = current_panel_index + 1
      num_panels = panels_container_element.find('li').length
      if next_panel_index >= num_panels
        next_panel_index = 0
      panels_container_element.find('li').removeClass('active')
      panels_container_element.find('li').eq(next_panel_index).addClass('active')
      panels_container_element.find('.panel-navigation span').text((next_panel_index + 1) + ' of ' + num_panels)

  container_obj.find('.fulloverlay').each ->
    overlay_element = $(this)
    $(this).find('.close-overlay-button').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      overlay_element.hide()

    $(this).find('.close-button').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      overlay_element.hide()

  window.enableScreens(container_obj)
  window.renderBootstrapTooltips(container_obj)

  ##word overflow##
  window.wordBreak(container_obj.find('.word-break'))
  window.wordOverflowShrink(container_obj.find('.word-overflow-shrink'))

  ##disable enter submit##
  container_obj.find('.disable-enterkey-submit').keydown (event) ->
    if event.keyCode == 13
        event.preventDefault();
        return false;

  ##vertically center##
  container_obj.find('.vertically-center').each ->
    parent_element = $(this).parent()
    toppadding = Math.round((parent_element.height() - $(this).height()) / 2)
    $(this).css({'paddingTop':toppadding})


  ###
  Events
  ###

  container_obj.find('.back-link').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    History.back()

  if container_obj.find('.invite-email').length > 0
    container_obj.find('.invite-email').click (e) ->
      # e.preventDefault();
      # e.stopPropagation();
      if mixpanel?
        mixpanel.track("Invite by Email", {})

  if container_obj.find('.invite-facebook').length > 0
    container_obj.find('.invite-facebook').click (e) ->
      # e.preventDefault();
      # e.stopPropagation();
      if mixpanel?
        mixpanel.track("Invite on Facebook", {})

  if container_obj.find('.email_share_link').length > 0
    container_obj.find('.email_share_link').click (e) ->
      # e.preventDefault();
      # e.stopPropagation();
      if mixpanel?
        mixpanel.track("Share Activity by Email", {})


  if container_obj.find('.fb_js_sdk_share_link').length > 0
    container_obj.find('.fb_js_sdk_share_link').click (e) ->
      e.preventDefault();
      e.stopPropagation();
      try
        obj = {method: 'feed',link: $(this).attr('href'),picture: $(this).attr('app-data-fbshare-picture'),name: $(this).attr('app-data-fbshare-name'),description: $(this).attr('app-data-fbshare-description')}
        FB.ui(obj, (response) ->

        );

        if mixpanel?
          mixpanel.track("Share Activity on Facebook", obj)

      catch err
        alert(err.message);

  window.renderActivityList(container_obj)

  container_obj.find('a').click (e) ->
    if navigator.userAgent.match(/(iPhone|iPod|Android)/) && $(this).attr('href') != '' && $(this).attr('href') != '#'
      container_obj.find('#loading-modal').modal('show')

  ###
  Blog
  ###

  container_obj.find('.blog-link').click (e) ->
    if $(this).attr('data-blog-post-id')?
      e.preventDefault();
      e.stopPropagation();

      header = $(this).find('h5').text()

      $('#content-modal .modal-body').css({'maxHeight':parseInt($(window).height() * 0.75)});
      $('#content-modal').modal('show');
      $.ajax({
        dataType: "jsonp",
        cache: false,
        async: false,
        contentType: "application/json",
        url: 'http://blog.myapp.com/?json=get_post&post_id=' + $(this).attr('data-blog-post-id'),
        beforeSend: ->
          $('#content-modal .modal-body').html('<div class="loader-screen">loading...</div>')
        ,
        success: (data) ->
          console.log(data);
          $('#content-modal .modal-body').html('<h2>' + data.post.title_plain + '</h2>' + data.post.content);
          $('#content-modal .modal-header-content').text(header);
        error: (e) ->
          console.log(e.message);
      });


window.enableScreens = (container_obj) ->
  screen_selector = container_obj.find('.screen')
  if screen_selector.length > 0
    window.bindScreenControls(container_obj)
    screen_selector.first().show()
    window.populateToolTip(container_obj.find('.screen:visible:first'))

    window.renderFooterProgress()

    if screen_selector.length > 1
      url_screen_index = 0
      raw_url_screen_index = window.URLParameter('screen')
      if raw_url_screen_index != "" && parseInt(raw_url_screen_index) > 0
        url_screen_index = parseInt(raw_url_screen_index)
      History.pushState({screen:0}, window.page_title, "?screen=0")
      if url_screen_index > 0 && screen_selector.eq(url_screen_index).hasClass('allow-screen-url')
        History.pushState({screen:url_screen_index}, window.page_title, "?screen=" + url_screen_index)
        screen_selector.eq(url_screen_index).trigger('onURLScreenLoad')


window.bindScreenControls = (container_obj) ->
  container_obj.find('.btn.next').click (e) ->
    e.preventDefault()
    matching_screens_selector = '.screen'
    if container_obj.attr('id')?
      matching_screens_selector = '#' + container_obj.attr('id') + ' .screen'
    screen_index = $(this).parents('.screen').index(matching_screens_selector) + 1
    return unless screen_index < $(matching_screens_selector).length
    if $(this).hasClass('disabled')
      return false

    if $(this).hasClass('delay')
      setTimeout(->
        History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)
      ,3000)
    else if $(this).hasClass('short-delay')
      setTimeout(->
        History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)
      ,700)
    else
      History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)

  container_obj.find('.btn.back').click (e) ->
    e.preventDefault()
    matching_screens_selector = '.screen'
    if container_obj.attr('id')?
      matching_screens_selector = '#' + container_obj.attr('id') + ' .screen'
    screen_index = $(this).parents('.screen').index(matching_screens_selector) - 1
    return unless screen_index >= 0
    if $(this).hasClass('disabled')
      return false

    if $(this).hasClass('delay')
      setTimeout(->
        History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)
      ,3000)
    else if $(this).hasClass('short-delay')
      setTimeout(->
        History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)
      ,700)
    else
      History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)


  container_obj.find('.btn-group.next .btn').click (e) ->
    e.preventDefault()
    matching_screens_selector = '.screen'
    if container_obj.attr('id')?
      matching_screens_selector = '#' + container_obj.attr('id') + ' .screen'
    screen_index = $(this).parents('.screen').index(matching_screens_selector) + 1
    return unless screen_index < $(matching_screens_selector).length
    if $(this).hasClass('disabled')
      return false

    if $(this).parents('.btn-group').hasClass('delay')
      setTimeout(->
        History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)
      ,3000)
    else if $(this).parents('.btn-group').hasClass('short-delay')
      setTimeout(->
        History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)
      ,700)
    else
      History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)

  container_obj.find('.btn-jump').each ->
    screen_index = $(this).attr('href')
    $(this).click (e) ->
      e.preventDefault()
      return unless screen_index < container_obj.find('.screen').length
      if $(this).hasClass('disabled')
        return false

      if $(this).parents('.btn-group').hasClass('delay')
        setTimeout(->
          window.jumpToScreen(screen_index)
        ,3000)
      else if $(this).parents('.btn-group').hasClass('short-delay')
        setTimeout(->
          window.jumpToScreen(screen_index)
        ,700)
      else
        window.jumpToScreen(screen_index)

    container_obj.find('.screen').eq(screen_index).bind('onURLScreenLoad', ->
      container_obj.find('.btn.btn-jump[href=' + screen_index + ']').click()
    )


window.jumpToScreen = (screen_index) ->
  History.pushState({screen:screen_index}, window.page_title, "?screen=" + screen_index)
  clicked_button_selector = $('.btn.btn-jump[href=' + screen_index + ']')
  if clicked_button_selector.parents('ul.nav').length > 0
    clicked_button_selector.parents('ul.nav').find('li').removeClass('active')
    clicked_button_selector.parent().removeClass('active').addClass('active')
  else
    $('.btn.btn-jump').removeClass('active')
    clicked_button_selector.removeClass('active').addClass('active')

window.renderFooterProgress = () ->
  footer_progress_html = ''
  footer_progress_element = $('.footer-progress')
  num_elements = 0
  $('.screen').each ->
    class_html = ''
    if $(this).hasClass('progress-exclude')
      class_html += ' excluded '
    else
      num_elements++
    if footer_progress_element.hasClass('style-2') && num_elements % 4 == 0
      class_html += ' section-end '
    footer_progress_html += '<li class="' + class_html + '">-</li>'
  footer_progress_element.append(footer_progress_html)
  footer_progress_element.find('li:visible:first').addClass('first active')
  footer_progress_element.find('li:visible:last').removeClass('section-end').addClass('last')
  window.updateFooterProgress(0)

window.updateFooterProgress = (current_index) ->
  footer_progress_li_selector = $('.footer-progress li')
  footer_progress_li_selector.removeClass('active')
  for i in [0..current_index] by 1
    footer_progress_li_selector.eq(i).addClass('active')
  if $('.screen.progress-exclude:visible').length > 0
    $('.footer-progress').hide()
  else
    $('.footer-progress').show()


window.renderFooterDayCounter = () ->
  $('.footer-progress-meter').each ->
    $(this).html('')
    $(this).removeClass('cf').addClass('cf')
    selected_index = parseInt($(this).attr('data-current-day'))
    for i in [1..30] by 1
      $(this).append('<li><div>o</div></li>')
    $(this).find('li').each ->
      list_item_index = $(this).index('.footer-progress-meter li')
      if list_item_index < selected_index
        $(this).addClass('complete')
    $(this).find('li').eq(selected_index - 1).removeClass('complete').removeClass('current').addClass('current')

window.renderActivityList = (container_obj) ->
  container_obj.find('.activity-list').each ->
    activity_list_element = $(this)
    $(this).find('li').each ->

      if !$(this).hasClass('label-row')

        details_html = "";
        detail_icon_classes = "detail-icon"
        inherited_classes = ['blue']
        for inherited_class, i in inherited_classes
          if activity_list_element.hasClass(inherited_class)
            detail_icon_classes += (" " + inherited_class);

        if $(this).hasClass('daytime')
          details_html += "<span class=\"" + detail_icon_classes + " daytime\">Daytime</span>"
        if $(this).hasClass('nighttime')
          details_html += "<span class=\"" + detail_icon_classes + " nighttime\">Nighttime</span>"
        if $(this).attr('data-time')?
          details_html += "<span class=\"" + detail_icon_classes + " time\">" + $(this).attr('data-time') + "</span>"
        if $(this).attr('data-tag')?
          details_html += "<span class=\"" + detail_icon_classes + " tag\">" + $(this).attr('data-tag') + "</span>"
        if $(this).hasClass('focus')
          details_html += "<span class=\"" + detail_icon_classes + " focus\">Focus</span>"
        if $(this).hasClass('positivity')
          details_html += "<span class=\"" + detail_icon_classes + " positivity\">Positivity</span>"
        if $(this).hasClass('sleep')
          details_html += "<span class=\"" + detail_icon_classes + " sleep\">Sleep</span>"
        if $(this).hasClass('social')
          details_html += "<span class=\"" + detail_icon_classes + " social\">Social</span>"
        if $(this).hasClass('gain')
          details_html += "<span class=\"" + detail_icon_classes + " gain\">Gain</span>"
        if details_html != ''
          details_html = "<div class=\"detail-icon-row\">" + details_html + "</div>"
        $(this).append(details_html)
        $(this).find('.description-details').prepend("<span class='pointer'>^</span>").wrap('<div class="description-details-container" />')
        $(this).wrapInner('<div class="description" />')
        if $(this).attr('data-img-src')?
          if $(this).hasClass('complete')
            $(this).append('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div><span class="check">x</span></div>')
          else
            $(this).append('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div></div>')
        if $(this).hasClass('has-icon')
          $(this).append('<div class="icon">x</div>')
        if $(this).attr('href')?
          $(this).wrapInner('<a href="' + $(this).attr('href') + '" />')
        if activity_list_element.hasClass('as-buttons')
          $(this).wrapInner('<div class="outer">')

    $(this).find('li').each ->
      if $(this).outerHeight() > 80
        $(this).find('.description').css({'paddingTop':15, 'paddingBottom':15})

  container_obj.find('.activity-list-columns').each ->
    activity_list_element = $(this)
    $(this).find('li').each ->
      $(this).wrapInner('<h3 class="intervention-title" />')
      details_html = "";
      if $(this).hasClass('daytime')
        details_html += "<li class=\"blue detail-icon daytime\">Daytime</li>"
      if $(this).hasClass('nighttime')
        details_html += "<li class=\"blue detail-icon nighttime\">Nighttime</li>"
      if $(this).attr('data-time')?
        details_html += "<li class=\"blue detail-icon time\">" + $(this).attr('data-time') + "</li>"
      if details_html != ''
        details_html = "<ul class=\"detail-rows\">" + details_html + "</ul>"
      if $(this).attr('data-img-src')?
        if $(this).hasClass('complete')
          $(this).append('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div><span class="check">x</span></div>')
        else
          $(this).append('<div class="img-container"><div class="img-padding"><div class="img" style="background:url(' + $(this).attr('data-img-src') + ') 0px 0px no-repeat; background-size:cover;">x</div></div></div>')
      $(this).append(details_html)
      $(this).append('<div class="button-container"><div class="btn btn-border-simple btn-block lime-2 pill size-minus-2"><div class="inner-border"><div class="inner"><div class="icon">Start</div></div></div></div></div>')
      if $(this).attr('href')?
        $(this).wrapInner('<a href="' + $(this).attr('href') + '" />')
      if activity_list_element.hasClass('as-buttons')
        $(this).wrapInner('<div class="outer">')
    $(this).find('li').each ->
      if $(this).outerHeight() > 80
        $(this).find('.description').css({'paddingTop':15, 'paddingBottom':15})

window.loadLessonsRSS = () ->
  $('.blog-article-list').each () ->
    rssurl = 'http://blog.myapp.com/feed/app4'
    blog_article_list_element = $(this)
    window.parseRSS(rssurl,(data) ->
      max_num_items = data.entries.length
      max_allowed_items = 3
      offset = 0
      if blog_article_list_element.attr('data-max-num-items')?
        max_allowed_items = parseInt(blog_article_list_element.attr('data-max-num-items'))
      if max_num_items > max_allowed_items
        max_num_items = max_allowed_items
      if blog_article_list_element.attr('data-offset')?
        offset = parseInt(blog_article_list_element.attr('data-offset'))
        max_num_items += offset
      for i in [offset...max_num_items]
        json_content = String(data.entries[i].content)
        json_content = json_content.replace(/&quot;/g,'"')
        json_content_obj = $.parseJSON(json_content);

        if max_allowed_items <= 1
          list_html = "<li><a href=\"" + data.entries[i].link + "\" class=\"blog-link\" data-blog-post-id=\"" + json_content_obj.id + "\" target=\"_new\"><h5>" + data.entries[i].categories[0] + "</h5>" +  data.entries[i].title + "<div class=\"icon\" style=\"background:url(" + json_content_obj.thumbnail + ") 0px 0px no-repeat; background-size:cover;\">image</div><div class=\"article-description\">" + json_content_obj.excerpt
          list_html += " <span class=\"view-all-link\">View All Studies</span>"
          list_html += "</div></a></li>"
        else
          list_html = "<li><a href=\"" + data.entries[i].link + "\" class=\"blog-link\" data-blog-post-id=\"" + json_content_obj.id + "\" target=\"_new\"><h5>" + data.entries[i].categories[0] + "</h5>" +  data.entries[i].title + "<div class=\"icon\" style=\"background:url(" + json_content_obj.thumbnail + ") 0px 0px no-repeat; background-size:cover;\">image</div><div class=\"article-description\">" + json_content_obj.excerpt + "...</div></a></li>"

        blog_article_list_element.append(list_html)

      blog_article_list_element.find('li a').each ->
        content_height = $(this).height()
        icon_element = $(this).find('.icon')
        icon_y_pos = Math.ceil((content_height - icon_element.outerHeight())/2)
        #icon_element.css({'position':'absolute','top': icon_y_pos})
        arrow_height = 25
        arrow_y_pos = Math.ceil((content_height - arrow_height)/2)
        $(this).css({'backgroundPosition':'right -' + (550 - arrow_y_pos) + 'px'})

      window.resizeCanvas()
      window.alignHeights('.footer-content .container-module')
      window.buildComponents($('.blog-article-list'))
    )

window.renderActionPlanNavigation = () ->
  $('.week-navigation').each () ->
    current_day = parseInt($(this).attr('data-day-index'))

    $(this).find('li').each (index) ->
      day_num = index + 1
      $(this).text("Day " + day_num)
      if $(this).hasClass('complete') || $(this).hasClass('incomplete')
        $(this).wrapInner('<div class="inner" />').wrapInner('<a href="?day=' + day_num + '" class="outer" />')
      else
        $(this).wrapInner('<div class="inner" />').wrapInner('<label class="outer" />')

    item_width = $(this).find('li').width()
    scroll_x = item_width * (current_day - 1)
    $(this).parent('.week-navigation-content').scrollLeft(scroll_x)

###word break###
window.wordBreak = (jq_obj) ->
  jq_obj.each () ->
    if $(this).attr('char-limit')?
      char_limit = $(this).attr('char-limit')
      content = $(this).text()
      content_array = content.split(" ")
      new_content_array = new Array()
      for word, i in content_array
        if word.length > char_limit
          new_content_array.push(word.substr(0,char_limit - 2) + '&hellip;')
          new_content_array.push(word.substr(char_limit - 2,word.length))
        else
          new_content_array.push(word)
      $(this).html(new_content_array.join(' '))


###word overflow shrink###
window.wordOverflowShrink = (jq_obj) ->
  jq_obj.each () ->
    if $(this).attr('char-limit')?
      char_limit = $(this).attr('char-limit')
      content = $(this).text()
      content_array = content.split(" ")
      has_overflowing_word = false
      for word, i in content_array
        if word.length > char_limit
          has_overflowing_word = true
      if has_overflowing_word
        $(this).removeClass('shrink').addClass('shrink')

### auto closing alerts ###

window.attachAutoCloseFunction = ->
  $('.alert.auto-close').each ->
    alert = $(this)
    setTimeout((-> alert.alert('close')), 3000)

jQuery ->
  attachAutoCloseFunction()
