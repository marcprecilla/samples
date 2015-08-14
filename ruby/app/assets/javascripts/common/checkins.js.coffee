window.buildCheckins = (container_obj) ->
  return unless container_obj.length == 1

  console.log("Checkins Loaded")

  container_obj.find('.screen').bind('afterShowScreen', (event) ->
    titlebar = $(this).attr('data-title')
    if titlebar?
      container_obj.find('.navbar #title').html(titlebar)

  )

  container_obj.find('.screen:last').find('.btn').click (e) ->
    e.preventDefault()
    e.stopPropagation()

    score_value = 0
    container_obj.find('.screen').each ->
      if $(this).attr('data-points')?
        score_value += parseInt($(this).attr('data-points'))
    window.showPoints(score_value)
    setTimeout(->
      container_obj = $('#checkins')
      window.submitActivityFormAndForward(container_obj,container_obj.find('#pam-question-form'),'/toolkit')
    , 3000);

