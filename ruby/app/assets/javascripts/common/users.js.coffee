window.buildUsers = (container_obj) ->

  return unless container_obj.length == 1

  container_obj.find('.registration-form').submit (e) ->
    # prevent double-registrations
    $(this).find('button[type=submit]').attr('disabled', true)

  container_obj.find('.btn-toggle').click (e) ->
    value = $(this).val()
    hidden_field = $($(this).data('hidden-field'))
    target = $($(this).data('target'))
    action = $(this).data('click')

    # copy this button's value into hidden field
    hidden_field.val(value)

    # execute click action
    switch action
      when 'show' then target.slideDown()
      when 'hide' then target.slideUp()

  window.forwardToOnboarding = () ->
    container_obj.find('#splash_screen.screen .btn.next').click();

  # cache page elements for performance
  main_form = container_obj.find('form.edit_user')
  photo_button = container_obj.find('#onboarding-photo-button')
  cloudinary_fileupload = $('.cloudinary-fileupload')
  username_field = container_obj.find('form.edit_user #user_name')
  profile_button = container_obj.find('form.edit_user #profile .btn.next')
  password_dialog = container_obj.find('#change-password-dialog')

  container_obj.find('#welcome-audio-player').audioPlayer({
    jPlayerPath: '/audio/Jplayer.swf',
    cssSelector: {
      play: "#audio-slideshow-container .jp-play"
    }

  });

  container_obj.find('#welcome-audio-button').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    if $(this).text() == 'Play'
      container_obj.find('#welcome-audio-player #jp_jplayer_0').jPlayer("play");
      $(this).find('.icon').html('Pause')
      _gaq.push(['_trackEvent', 'audio', 'play', 'welcome']);
    else
      container_obj.find('#welcome-audio-player #jp_jplayer_0').jPlayer("pause");
      $(this).find('.icon').html('Play')

  container_obj.find('#start .btn.next').click (e) ->
    container_obj.find('#welcome-audio-button').find('.icon').html('Pause')
    container_obj.find('#welcome-audio-player #jp_jplayer_0').jPlayer("pause");

  container_obj.find('form.edit_user .btn-group').each ->
    group_container = $(this)
    group_container.find('.btn').click (e) ->
      e.preventDefault()
      value = $(this).val()
      group_container.parent().find('input[type=hidden]').val(value)

  if username_field.length
    if username_field.val() == ''
      profile_button.removeClass('disabled').addClass('disabled')

  username_field.bind "keyup change click mouseover", (e) ->
    if $(this).val() != ''
      profile_button.removeClass('disabled')
    else
      profile_button.removeClass('disabled').addClass('disabled')

  main_form.submit (event) ->
    if profile_button.hasClass('disabled')
      event.preventDefault()
      event.stopPropagation()

  cloudinary_fileupload.bind('fileuploadstart', (e, data) ->
    $('#photo-modal .modal-body').html('Uploading photo...<div class=\"image-progress\"></div>');
    $('#photo-modal').modal('show')
  );

  cloudinary_fileupload.bind('fileuploadprogress', (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    $('#photo-modal .modal-body').find('.image-progress').html(progress + '% complete')
  );

  cloudinary_fileupload.bind('fileuploadfail', (e, data) ->
    $('#photo-modal .modal-body').html('image upload failed...');
    $('#photo-modal').modal('show')
  );

  cloudinary_fileupload.bind('cloudinarydone', (e, data) ->
    photo_button.removeClass('fullimg').addClass('fullimg')
    container_obj.find('.cloudinary-preview').html($.cloudinary.image(data.result.public_id,{ format: data.result.format, version: data.result.version, angle: 'exif' }))
    uploaded_img_url = container_obj.find('.cloudinary-preview img').attr('src')
    photo_button.find('.image').css({'background':'url(' + uploaded_img_url + ') 0px 0px no-repeat','background-size':'cover'})
    $('#photo-modal').modal('hide')
    return true;
  );

  # set background image of photo button
  if photo_url = photo_button.data('image-url')
    photo_button.find('.image').css({'background':'url(' + photo_url + ') 0px 0px no-repeat','background-size':'cover'})
    photo_button.removeClass('fullimg').addClass('fullimg')

  photo_button.click (event) ->
    event.preventDefault()
    event.stopPropagation()
    $('#photo-input').click()

  setTimeout(->
    if container_obj.find('#splash_screen.screen:visible').length > 0
      window.forwardToOnboarding()
  ,3000)

  password_dialog.on('hide', ->
    password_dialog.find('#password').val('')
    password_dialog.find('#password_confirmation').val('')
    password_dialog.find('.alert').remove()
  );

  container_obj.find('form button[type=submit], form input[type=submit]').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    form_element = $(this).parents('form')
    window.submitActivityForm(container_obj,form_element)

