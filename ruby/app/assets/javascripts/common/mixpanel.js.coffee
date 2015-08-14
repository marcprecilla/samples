jQuery ->
  if mixpanel?
    mixpanel.set_config({
      debug: true
    });

    mixpanel.pageViewed = (name, path) ->
      mixpanel
      $('.vertical-center-outer').css('padding',0)
