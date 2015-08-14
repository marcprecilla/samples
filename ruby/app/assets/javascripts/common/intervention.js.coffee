window.buildIntervention = (container_obj) ->
  return unless container_obj.length == 1

  if container_obj.find('#segmented-intervention').length > 0
    container_obj.find('#skip-button').click (event) ->
      event.preventDefault()
      event.stopPropagation()
      container_obj.find('#start-button .icon').text('Play')
      container_obj.find('#audio-slideshow #jp_jplayer_0').jPlayer("pause");
      History.pushState({screen:1}, "Stress Less", "?screen=1")
      if mixpanel?
        mixpanel.track("Skipped Intervention")

    container_obj.find('#audio-slideshow').audioSlideshow({
      jPlayerPath: '/audio/Jplayer.swf',
      cssSelectorAncestor: '#audio-slideshow-container',
      cssSelector: {
        play: "#audio-slideshow-container .jp-play",
        currentTime: "#audio-slideshow-container .jp-current-time",
        duration: "#audio-slideshow-container .jp-duration"
      },
      play: () ->
        $('#intervention #start-button .icon').text('Pause')
        $('.footer-button-row').show()
        window.resizeCanvas()
      ,
      ended: () ->
        History.pushState({screen:1}, "Stress Less", "?screen=1")

    });

  else if container_obj.find('#continuous-intervention').length > 0
    container_obj.find('#begin-button').click (event) ->
      $('.state-1').hide()
      $('.state-2').show()
      $('#audio-slideshow #jp_jplayer_0').jPlayer("play");

    container_obj.find('#audio-slideshow').audioSlideshow({
      jPlayerPath: '/audio/Jplayer.swf',
      cssSelectorAncestor: '#audio-slideshow-container',
      cssSelector: {
        play: "#audio-slideshow-container .jp-play",
        currentTime: "#audio-slideshow-container .jp-current-time",
        duration: "#audio-slideshow-container .jp-duration"
      },
      play: () ->
        container_obj.find('#start-button .icon').text('Pause')
      ,
      ended: () ->
        container_obj.find('#start-button .icon').text('Play Again')
    });

  container_obj.find('#start-button').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    if $(this).text() == 'Play' || $(this).text() == 'Play Again' || $(this).text() == 'Start'
      container_obj.find('#audio-slideshow #jp_jplayer_0').jPlayer("play");
      if mixpanel?
        mixpanel.track("Started Intervention Audio")
    else if $(this).text() == 'Pause'
      container_obj.find('#audio-slideshow #jp_jplayer_0').jPlayer("pause");
      $(this).find('.icon').text('Play')
      if mixpanel?
        mixpanel.track("Paused Intervention Audio")


  container_obj.find('.do-action-button').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    window.submitActivityForm(container_obj,$('#intervention-action-form'))
    #window.submitInterventionForm()
    #self.location = '/pam'

  container_obj.find('.flexslider-mini-gallery').each ->
    flexslider_element = $(this)
    flexslider_element.flexslider({
      animation: "slide",
      animationLoop: false,
      slideshow: false,
      itemWidth: 98,
      itemMargin: 0,
      maxItems: 3,
      start: ->
        window.adjustUploadGallery(flexslider_element)
      ,
      added: ->
        window.adjustUploadGallery(flexslider_element)
      ,
      removed: ->
        window.adjustUploadGallery(flexslider_element)

    });

  if container_obj.find('#exercises-screen').length > 0 && !window.renderScreen?
    window.renderScreen = (screen_index) ->
      exercises_btn_selector = $('.exercises-navigation-list .btn')
      exercises_btn_selector.removeClass('active')
      exercises_btn_selector.eq(screen_index).removeClass('active').addClass('active')


  container_obj.find('#popunder #button-take-photo').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    $('#photo-input').click()

  container_obj.find('#popunder #button-select-flickr').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    window.showFlickrFeedDefault('');

  container_obj.find('#popunder #button-image-cancel').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    window.togglePopunder()

  window.hideActivityNav = (container_obj) ->
    activity_nav_button_element = container_obj.find('#activity-nav-button')
    nav_container = container_obj.find('.nav-container')
    min_nav_height = activity_nav_button_element.outerHeight()
    nav_container.height(min_nav_height)
    nav_container.find('.arrow').removeClass('down').removeClass('up').addClass('down')

  window.showActivityNav = (container_obj) ->
    activity_nav_button_element = container_obj.find('#activity-nav-button')
    nav_container = container_obj.find('.nav-container')
    max_nav_height = (nav_container.find('li').outerHeight() * nav_container.find('li').length) + activity_nav_button_element.outerHeight()
    nav_container.height(max_nav_height)
    nav_container.find('.arrow').removeClass('down').removeClass('up').addClass('up')


  container_obj.find('#activity-nav-button').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    nav_container = container_obj.find('.nav-container')
    min_nav_height = $(this).outerHeight()
    if nav_container.height() <= min_nav_height
      window.showActivityNav(container_obj)
    else
      window.hideActivityNav(container_obj)

  container_obj.find('.nav-list a').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    associated_week = $(this).attr('href')
    if associated_week == 'all'
      container_obj.find('.activity-list li').show()
    else
      container_obj.find('.activity-list li').each ->
        if $(this).attr('data-week')? && $(this).attr('data-week') == associated_week
          $(this).show()
        else if $(this).hasClass('label-row')
          $(this).show()
        else
          $(this).hide()
    container_obj.find('#activity-nav-button h2').text($(this).text())
    window.hideActivityNav(container_obj)