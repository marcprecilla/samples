jQuery ->
  ###
  mobile scaffolding
  ###
  window.scaffolding_init()

  ###
  Layout
  ###
  window.buildComponents($('body'))

  ###History###
  History.Adapter.bind(window,'popstate', ->
    screen_index = History.getState().data['screen'];
    if !screen_index?
      screen_index = 0
    window.renderScreens(screen_index)
    $('#loading-modal').modal('hide')
  );

  window.renderFooterDayCounter()
  window.resizeCanvas()
  window.scrollToTop()
  window.drawSVGElements()



