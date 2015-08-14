window.buildVisionboard = (container_obj) ->
  return unless container_obj.length == 1

  container_obj.find('.random-color').each (index)->
    random_color = window.vb_color_list[Math.floor(Math.random()*window.vb_color_list.length)]
    container_obj.find(this).removeClass(random_color).addClass(random_color)
  if container_obj.width() < 649
    container_obj.find('.vb-row').width(container_obj.width())
    container_obj.find('.two-row').width(container_obj.width())
    container_obj.find('.vb-row:even').scrollLeft(0)
    container_obj.find('.vb-row.thank-row').scrollLeft($(window).width())
    container_obj.find('.visionboard-container .two-row ul li').width(Math.floor(container_obj.width() / 2) - 16)
  else
    container_obj.find('.vb-row').width(649)
    container_obj.find('.two-row').width(649)
    container_obj.find('.visionboard-container .two-row ul li').width(325 - 16)
