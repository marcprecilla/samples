window.buildIntentions = (container_obj) ->
  return unless container_obj.length == 1

  container_obj.find('.random-color').each (index)->
    random_color = window.vb_color_list[Math.floor(Math.random()*window.vb_color_list.length)]
    $(this).removeClass(random_color).addClass(random_color)

  container_obj.find('.question-screen .btn.continue').click (e) ->
    e.preventDefault()
    matching_screens_selector = '.screen'
    if container_obj.attr('id')?
      matching_screens_selector = '#' + container_obj.attr('id') + ' .screen'
    screen_element = $(this).parents('.screen')
    answer_screen_element = container_obj.find('.answer-screen')
    answer_screen_index = container_obj.find('.answer-screen').index(matching_screens_selector)
    clean_value = screen_element.find('input#other-intention-text').val()
    clean_value = clean_value.replace("\r"," ");
    clean_value = clean_value.replace("\"","&quot;");
    color_class = screen_element.find('input#other-intention-color').val()

    if clean_value == ''
      screen_element.find('.error-container').text('Please select/fill out your intention.')
    else

      btn_content = "<div class=\"btn btn-square-simple " + color_class + "\"><div class=\"inner\"><div class=\"btn-content\" style=\"height: 97px; width: 97px;\">"
      btn_content += screen_element.find('.label-text').text() + ' <b class="word-break" char-limit="8">' + clean_value + '</b>'
      btn_content += "</div></div></div>"

      btn_content += "<input type=\"hidden\" value=\"" + clean_value + "\" name=\"intentions[][text]\" id=\"\">"
      btn_content += "<input type=\"hidden\" value=\"" + color_class + "\" name=\"intentions[][color]\" id=\"\">"

      answer_screen_element.find('.buttons-container').append(btn_content)
      window.wordBreak(answer_screen_element.find('.word-break'))
      screen_element.find('.error-container').text('')
      screen_element.find('.btn-group .btn').removeClass('active')
      screen_element.find('input#other-intention-text').val('')
      window.setRandomColor()
      History.pushState({screen:answer_screen_index}, window.page_title, "?screen=" + answer_screen_index)


  container_obj.find('.question-screen .btn-group .btn').click (e) ->

    matching_screens_selector = '.screen'
    if container_obj.attr('id')?
      matching_screens_selector = '#' + container_obj.attr('id') + ' .screen'

    screen_element = $(this).parents('.screen')
    answer_screen_element = container_obj.find('.answer-screen')
    answer_screen_index = container_obj.find('.answer-screen').index(matching_screens_selector)

    clean_value = $(this).val()
    clean_value = clean_value.replace("\r"," ");
    clean_value = clean_value.replace("\"","&quot;");
    color_class = ''
    for i in [0..window.vb_color_list.length] by 1
      if $(this).hasClass( window.vb_color_list[i] )
        color_class = window.vb_color_list[i];
        break;

    inherited_classes_array = new Array()
    inherited_classes = ['shrink']
    for inherited_class, i in inherited_classes
      if $(this).hasClass(inherited_class)
        inherited_classes_array.push(inherited_class)

    screen_element.find('input#intentions__color').val(color_class)
    btn_content = "<div class=\"btn btn-square-simple " + color_class + " " + inherited_classes_array.join(' ') + "\" char-limit=\"8\"><div class=\"inner\"><div class=\"btn-content\" style=\"height: 97px; width: 97px;\">"
    btn_content += screen_element.find('.label-text').text() + ' <b>' + clean_value + '</b>'
    btn_content += "</div></div></div>"

    btn_content += "<input type=\"hidden\" value=\"" + clean_value + "\" name=\"intentions[][text]\" id=\"\">"
    btn_content += "<input type=\"hidden\" value=\"" + color_class + "\" name=\"intentions[][color]\" id=\"\">"
    answer_screen_element.find('.buttons-container').append(btn_content)
    History.pushState({screen:answer_screen_index}, window.page_title, "?screen=" + answer_screen_index)
    $(this).hide()
    window.setRandomColor()

  if container_obj.hasClass('new') || container_obj.find('.new').length > 0

    window.setRandomColor = () ->
      random_color = window.vb_color_list[Math.floor(Math.random()*window.vb_color_list.length)]
      container_obj.find('.question-screen .textarea-container #other-intention-color').val(random_color)

    window.setRandomColor()

    container_obj.find('#button-add-another').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      matching_screens_selector = '.screen'
      if container_obj.attr('id')?
        matching_screens_selector = '#' + container_obj.attr('id') + ' .screen'

      if container_obj.find('.question-screen .btn-group .btn:visible').length <= 0
        container_obj.find('.question-screen .buttons-label').hide()
      question_screen_index = container_obj.find('.question-screen').index(matching_screens_selector)
      History.pushState({screen:question_screen_index}, window.page_title, "?screen=" + question_screen_index)

    container_obj.find('#button-finish').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      completion_screen_index = container_obj.find('.screen').length - 1
      History.pushState({screen:completion_screen_index}, window.page_title, "?screen=" + completion_screen_index)

  if container_obj.hasClass('show') || container_obj.find('.show').length > 0
    container_obj.find('.upload-button').click (e) ->
      e.preventDefault()
      e.stopPropagation()
      $.ajax({
        type: "PUT",
        url: container_obj.find('form#image-upload-form').attr("action"),
        data: container_obj.find('form#image-upload-form').serialize(),
        success: (data) ->
          console.log('success')
          completion_screen_index = container_obj.find('.screen').length - 1
          History.pushState({screen:completion_screen_index}, window.page_title, "?screen=" + completion_screen_index)
        ,
        error: (errorThrown) ->
         console.log(errorThrown)
         completion_screen_index = container_obj.find('.screen').length - 1
         History.pushState({screen:completion_screen_index}, window.page_title, "?screen=" + completion_screen_index)
        dataType: "json"
      })

  if (container_obj.hasClass('new') || container_obj.find('.new').length > 0)
    container_obj.find('.screen.completion-screen').bind('afterShowScreen', (event) ->
      $('.navbar-container #title').text('Saved!')
      $.ajax({
        type: "POST",
        url: container_obj.find('form.intention-questions').attr("action"),
        data: container_obj.find('form.intention-questions').serialize(),
        success: (data) ->
          console.log('success')
        , dataType: "json"
      })
    )

    container_obj.find('.screen.question-screen').bind('afterShowScreen', (event) ->
      container_obj.find('.navbar-container #title').text('Set Intention')
    )

    container_obj.find('.screen.answer-screen').bind('afterShowScreen', (event) ->
      container_obj.find('.navbar-container #title').text('Review')
    )


  container_obj.find('#button-take-photo').click (event) ->
    event.preventDefault()
    event.stopPropagation()
    if !$(this).hasClass('disabled')
      $('#photo-input').click()

  container_obj.find('.flexslider-mini-gallery').each ->
    flexslider_element = $(this)
    flexslider_element.flexslider({
      animation: "slide",
      animationLoop: false,
      slideshow: false,
      itemWidth: 108,
      itemMargin: 0,
      start: (slider) ->
        window.adjustUploadGallery(flexslider_element)
      ,
      added: ->
        window.adjustUploadGallery(flexslider_element)
      ,
      removed: ->
        window.adjustUploadGallery(flexslider_element)
    });


