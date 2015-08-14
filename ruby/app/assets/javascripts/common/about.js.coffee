window.buildAbout = (container_obj) ->
  return unless container_obj.length == 1

  container_obj.find('#about-app').find('.header-button').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    window_height = $(window).height()
    if navigator.userAgent.match(/(iPhone|iPod)/)
      window_height += 60
    main_element = $('#main')
    main_padding_height = main_element.outerHeight() - main_element.height()
    button_header_height = $('#about-app').find('.header-button').outerHeight()
    content_height = window_height - main_padding_height - button_header_height

    if $(this).find('.arrow').hasClass('up')
      container_obj.find('#about-app').animate(
        { top:0 },
        300,
        'swing',
        ->
          $(this).find('.arrow').removeClass('up').addClass('down')
          $(this).find('h2').removeClass('active').addClass('active')
      );
    else
      container_obj.find('#about-app').animate(
        { top:content_height },
        300,
        'swing',
        ->
          $(this).find('.arrow').removeClass('down').addClass('up')
          $(this).find('h2').removeClass('active')
      );

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
    else
      container_obj.find('#welcome-audio-player #jp_jplayer_0').jPlayer("pause");
      $(this).find('.icon').html('Play')

  window.resizeCanvasAdditional = () ->
    window.renderAboutPage()

  window.renderAboutPage = () ->
    window_height = $(window).height()
    if container_obj.prop("tagName") == 'DIV'
      window_height = container_obj.height()
    main_element = container_obj.find('#main')
    main_padding_height = main_element.outerHeight() - main_element.height()
    button_header_height = $('#about-app').find('.header-button').outerHeight()
    if navigator.userAgent.match(/(iPhone|iPod)/)
      window_height += 60
    stretched_height = window_height - main_padding_height
    content_height = window_height - main_padding_height - button_header_height
    main_element.css('height',stretched_height);

    container_obj.find('#why-we-care').height(content_height)
    about_app_element = container_obj.find('#about-app')
    about_app_element.find('.content-container').height(content_height)

    if about_app_element.find('.header-button .arrow.up').length > 0
      about_app_element.css({'top':content_height});
