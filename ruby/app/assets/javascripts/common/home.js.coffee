window.buildHome = (container_obj) ->
  return unless container_obj.length == 1
  window.resizeCanvasAdditional = () ->
    window.renderHomePage()

  window.renderHomePage = () ->
    window_height = $(window).height()
    if container_obj.prop("tagName") == 'DIV'
      window_height = container_obj.height()
    if navigator.userAgent.match(/(iPhone|iPod)/)
      window_height += 60
    main_container_element = container_obj.find('#main')
    main_padding_height = main_container_element.outerHeight() - main_container_element.height()
    footer_height = container_obj.find('#buttons').outerHeight()
    title_height = container_obj.find('#main .stress-less-title').outerHeight()
    content_height = window_height - main_padding_height - footer_height - title_height
    container_obj.find('.activity-list').height(content_height)
