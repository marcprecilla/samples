# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.timeline_indicator = ''

$ ->
  return unless $('body#progress').length == 1

  $('.barchart-container').barChart({})
  $('.progress-bar').each ->
    $(this).wrapInner('<div class="progress-marker" />').wrapInner('<div class="inner" />')

  window.resizeCanvasAdditional = () ->
    $('.barchart-container .header-row').remove()
    $('.barchart-container .bars-container').remove()
    $('.barchart-container .x-axis').remove()
    $('.barchart-container .y-axis').remove()
    $('.barchart-container').barChart({})
    window.resizeProgress()
    window.updateDayIndicator()
    $('#slide-1 .slide-content').height($(window).height() - 140)

  $('.timeline-viewport').scroll (event) ->
    window.updateDayIndicator()
    indicator_scrollpos = $(this).scrollLeft() / ($(this)[0].scrollWidth - $(this)[0].clientWidth)
    timeline_indicator_element = $('.timeline-indicator')
    timeline_indicator_marker_element = timeline_indicator_element.find('div')
    trackwidth = timeline_indicator_element.width() - timeline_indicator_marker_element.width()
    timeline_indicator_marker_element.css('opacity' : 1, 'position':'absolute','left':Math.round(trackwidth * indicator_scrollpos))
    clearTimeout(window.timeline_indicator)
    window.timeline_indicator = setTimeout(->
      $('.timeline-indicator').find('div').animate(
        { opacity: 0 },
        300,
        'swing'
      )
    ,300)


  $('.timeline-viewport').mousedown (event) ->

  $('.timeline-viewport').mouseup (event) ->
    #$('.timeline-indicator').find('div').hide()

  window.resizeProgress = () ->
    $('.progress-viewport').css({'width':$(this).width()})
    timeline_width = 18;
    $('.progress-activity-day-list .day-activity-list li').each ->
      timeline_width += ($(this).outerWidth() + 10);
    $('.progress-activity-day-list .day-label').each ->
      if window.trim($(this).text()) != ''
        timeline_width += ($(this).outerWidth() + 12);

    $('.progress-activity-day-list').css({'width':timeline_width});
    if $('.progress-list:visible').length > 0
      $('.progress-list li .content:visible').each ->
        parent_container = $(this).parents('li')
        content_width = parent_container.width() - (parent_container.find('h2').outerWidth() + 32)
        $(this).css({'width':content_width})
    $('.progress-bar:visible').each ->
      percentage_position = 0
      if $(this).attr('data-rel-start')? && $(this).attr('data-rel-end')?
        data_start = parseInt($(this).attr('data-rel-start'))
        if parseInt($(this).attr('data-rel-end')) < data_start
          data_start = parseInt($(this).attr('data-rel-end'))
        raw_percentage = data_start / 100
        range_width = Math.round((parseInt($(this).attr('data-rel-end')) - parseInt($(this).attr('data-rel-start'))) * $(this).width() / 100)
        if (range_width < 0)
          range_width *= -1
        else if range_width == 0
          range_width = 1
        if raw_percentage > 0
          percentage_position = Math.round((raw_percentage * $(this).width()) - $(this).find('.progress-marker').width())
        $(this).find('.progress-marker').css({'position':'relative','left':percentage_position, 'width':range_width})

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

  if $('body#progress.index').length > 0
    $('.page-flexslider ul.slides li').bind('onEnterFlexSlide', (event) ->
      slider_index = $(this).index('li.walkthrough-slide')
      if slider_index == ($('.page-flexslider ul.slides li').length - 1)
        $('.close-button').hide()
      else
        $('.close-button').show()
    )

    $('body#progress.index .flex-next').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $('.page-flexslider').flexslider("next")

    $('body#progress.index .flex-previous').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $('.page-flexslider').flexslider("previous")

    $('body#progress.index .btn.flex-close').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $('.progress-walkthrough').hide()