# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.vb_color_list = ['red','orange','blue','purple','magenta','green']
window.page_title = $(document).attr('title')

window.buildActivityModal = () ->
  window.recursiveUnbind($('#modal-ajax-content'))
  window.buildComponents($('#modal-ajax-content'))
  window.buildAbout($('#modal-ajax-content #about'))
  window.buildHome($('#modal-ajax-content #home'))
  window.buildIntervention($('#modal-ajax-content #intervention'))
  window.buildCheckins($('#modal-ajax-content #checkins'))
  window.buildThanks($('#modal-ajax-content #thanks'))
  window.buildIntentions($('#modal-ajax-content #intentions'))
  window.buildInvitations($('#modal-ajax-content #invitations'))
  window.buildUsers($('#modal-ajax-content #users'))
  window.buildVisionboard($('#modal-ajax-content #visionboard_items'))
  window.redirectDesktopLinks($('#modal-ajax-content'))

window.scaffolding_init = () ->

  window.redirectDesktopLinks($('body'))

  window.renderUserMirror($('body'))

  $('.login-container .mirror-button').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    login_container_element = $('.login-container')
    if login_container_element.hasClass('active')
      login_container_element.removeClass('active')
      $('.profile-expander').css({'height':0})
    else
      login_container_element.addClass('active')
      $('.profile-expander').css({'height':$('.profile-info-container').height() + 2})

  $('#activity-modal .modal-close-button').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    $('#activity-modal').modal('hide')

  $('#activity-modal').on('hidden', ->
      $(this).find('#modal-ajax-content div:first-child').remove()
  )

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

  avatar_photo_button = $('.avatar')
  avatar_form_container_object = $('#avatar-upload')
  avatar_cloudinary_fileupload = avatar_form_container_object.find('.cloudinary-fileupload')

  avatar_cloudinary_fileupload.bind('fileuploadstart', (e, data) ->
    $('#photo-modal .modal-body').html('Uploading photo...<div class=\"image-progress\"></div>');
    $('#photo-modal').modal('show')
  );

  avatar_cloudinary_fileupload.bind('fileuploadprogress', (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    $('#photo-modal .modal-body').find('.image-progress').html(progress + '% complete')
  );

  avatar_cloudinary_fileupload.bind('fileuploadfail', (e, data) ->
    $('#photo-modal .modal-body').html('image upload failed...');
    $('#photo-modal').modal('show')
  );

  avatar_cloudinary_fileupload.bind('cloudinarydone', (e, data) ->
    avatar_form_container_object.find('.cloudinary-preview').html($.cloudinary.image(data.result.public_id,{ format: data.result.format, version: data.result.version, angle: 'exif' }))
    uploaded_img_url = avatar_form_container_object.find('.cloudinary-preview img').attr('src')
    avatar_photo_button.css({'background':'url(' + uploaded_img_url + ') 0px 0px no-repeat','background-size':'cover'})
    $('#photo-modal').modal('hide')
    avatar_form_container_object.find('form').submit()
    return true;
  );

  avatar_photo_button.click (event) ->
    event.preventDefault()
    event.stopPropagation()
    $('#avatar-photo-input').click()

  $('.header-notification .close-button').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    $(this).parents('.header-notification').fadeOut()

  window.loadLessonsRSS()


window.redirectDesktopLinks = (container_obj) ->
  container_obj.find('.desktop-modal-load').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    $('#modal-ajax-content').html('<div class="loader-screen">loading...</div>')
    $('#activity-modal').modal('show')
    target_url = $(this).attr('href')
    if '?' in target_url
      target_url += "&show_desktop=1"
    else
      target_url += "?show_desktop=1"
    $('#modal-ajax-content').load(target_url, (responseText, textStatus, XMLHttpRequest) ->
      window.buildActivityModal()
    );


window.resizeCanvas = () ->

  if $('.fulloverlay').length > 0
   $('.fulloverlay').css({'position':'absolute'})
   $('.fulloverlay').height($(document).height())


window.resetCanvas = () ->
  #disable

window.styleVerticalCenter = () ->
  #disable

window.styleCanvasBottom = () ->
  #disable

window.populateToolTip = (container_element) ->
  #disable


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


window.drawSVGElements = () ->
  #disable

window.submitActivityForm = (container_obj, form_obj) ->
  if form_obj.length <= 0
    return false

  form_data = form_obj.serialize() + "&show_desktop=1"
  form_url = form_obj.attr('action')
  $.ajax({
    type: "POST",
    data : form_data,
    cache: false,
    url: form_url,
    beforeSend: ->
      $('#modal-ajax-content').html('<div class="loader-screen">loading...</div>')
    ,
    success: (data) ->
      $('#modal-ajax-content').html(data);
      window.buildActivityModal()
  });

window.submitActivityFormAndForward = (container_obj, form_obj, url) ->
  if form_obj.length <= 0
    return false

  form_data = form_obj.serialize() + "&show_desktop=1"
  form_url = form_obj.attr('action')
  $.ajax({
    type: "POST",
    data : form_data,
    cache: false,
    url: form_url,
    beforeSend: ->
      $('#modal-ajax-content').html('<div class="loader-screen">loading...</div>')
    ,
    success: (data) ->
      $('#activity-modal').modal('hide');
      window.location.href = url
  });


window.renderScreens = (screen_index) ->
  screen_selector = $('#modal-ajax-content').find('.screen')
  previous_screen_selector = $('#modal-ajax-content').find('.screen:visible')
  previous_screen_selector.trigger("afterLeaveScreen",[screen_index])
  screen_selector.hide()
  selected_screen_selector = screen_selector.eq(screen_index)
  selected_screen_selector.show()
  window.updateFooterProgress(screen_index)
  selected_screen_selector.trigger("afterShowScreen")
  if window.renderScreen?
    window.renderScreen(screen_index)

window.enableButtonsWithoutHistory = (container_obj) ->
  container_obj.find('.btn.next').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    matching_screens_selector = '.screen'
    if container_obj.attr('id')?
      matching_screens_selector = '#' + container_obj.attr('id') + ' .screen'

    screen_selector = container_obj.find('.screen')
    screen_index = $(this).parents('.screen').index(matching_screens_selector) + 1
    previous_screen_selector = container_obj.find('.screen:visible')
    previous_screen_selector.trigger("afterLeaveScreen",[screen_index])
    screen_selector.hide()
    selected_screen_selector = screen_selector.eq(screen_index)
    selected_screen_selector.show()
    selected_screen_selector.trigger("afterShowScreen")

  container_obj.find('.btn.back').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    matching_screens_selector = '.screen'
    if container_obj.attr('id')?
      matching_screens_selector = '#' + container_obj.attr('id') + ' .screen'

    screen_selector = container_obj.find('.screen')
    screen_index = $(this).parents('.screen').index(matching_screens_selector) - 1
    return unless screen_index >= 0

    previous_screen_selector = container_obj.find('.screen:visible')
    previous_screen_selector.trigger("afterLeaveScreen",[screen_index])
    screen_selector.hide()
    selected_screen_selector = screen_selector.eq(screen_index)
    selected_screen_selector.show()
    selected_screen_selector.trigger("afterShowScreen")


  container_obj.find('.btn-jump').each ->
    screen_index = $(this).attr('href')
    $(this).click (e) ->
      e.preventDefault()
      e.stopPropagation()
      return unless screen_index < container_obj.find('.screen').length

      screen_selector = container_obj.find('.screen')
      previous_screen_selector = container_obj.find('.screen:visible')
      previous_screen_selector.trigger("afterLeaveScreen",[screen_index])
      screen_selector.hide()
      selected_screen_selector = screen_selector.eq(screen_index)
      selected_screen_selector.show()
      selected_screen_selector.trigger("afterShowScreen")

window.renderBootstrapTooltips = (container_obj) ->
  ###bootstrap tooltips###
  container_obj.find(".popover-trigger").popover({'placement':'bottom'})


window.renderUserMirror = (container_obj) ->
  if container_obj.find('.mind-metrics.showone').length > 0
    first_active_metric = $('.mind-metrics li').not('.disabled').first()
    if first_active_metric.length > 0
      default_screen_index = first_active_metric.find('a').attr('href')
      first_active_metric.removeClass('active').addClass('active')
      container_obj.find('.metric-screen').eq(default_screen_index).addClass('active')

  $('.mind-metrics a').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    clicked_item = $(this).parents('li')
    screen_index = $(this).attr('href')
    if !clicked_item.hasClass('paywall')
      if clicked_item.hasClass('active')
        $('.mind-metrics li').removeClass('active')
        container_obj.find('.metric-screen').removeClass('active')
      else
        $('.mind-metrics li').removeClass('active')
        $(this).parents('li').removeClass('active').addClass('active')
        container_obj.find('.metric-screen').removeClass('active')
        container_obj.find('.metric-screen').eq(screen_index).addClass('active')
    else if $(this).attr('href') == '/subscriptions'
      self.location = $(this).attr('href')

