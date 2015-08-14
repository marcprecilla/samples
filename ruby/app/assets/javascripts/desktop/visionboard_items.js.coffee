# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  return unless $('body#visionboard_items').length == 1

  if $('body#visionboard_items.desktop_scaffolding').length > 0

    #s$('html, body').scrollTop(350)

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

