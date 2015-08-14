window.buildInvitations = (container_obj) ->
  return unless container_obj.length == 1

  container_obj.find('.screen').bind('afterShowScreen', (event) ->
    screen_index = $(this).index('.screen')
    titlebar = $(this).attr('data-title')
    container_obj.find('.navbar #title').text(titlebar)

    container_obj.removeClass('bluebg').removeClass('darkbluebg')
    add_body_class = $(this).attr('data-add-body-class')
    if add_body_class?
      container_obj.removeClass(add_body_class).addClass(add_body_class)
  );

