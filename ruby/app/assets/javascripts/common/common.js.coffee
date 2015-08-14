window.scrollToTop = () ->
  if navigator.userAgent.match(/(iPhone|iPod)/)
    $('body').scrollTop(0)


window.centerFixElement = (selector, do_animate) ->
  do_animate = do_animate || 0;

  if selector
    center_x = Math.ceil(($(window).width() - $(selector).width()) / 2);
    center_y = Math.ceil(($(window).height() - $(selector).height()) / 2);

    if navigator.userAgent.match(/(iPhone|iPod|Android)/)
      $(selector).css('position',"absolute");
    else if(($(window).height() - $(selector).height()) > 50 && ($(window).width() - $(selector).width()) > 50)
      $(selector).css('position',"fixed");
    else
      $(selector).css('position',"absolute");
      center_y = $(window).scrollTop();
      if($('.main_container').length)
        if((center_y + $(selector).height()) > $('.main_container').height())
          center_y = $('.main_container').height() - $(selector).height() - 50;

    if(center_x < 0)
      center_x = 0;
    if(center_y < 0)
      center_y = 0;

    if(do_animate)
      $(selector).animate(
        { left: center_x, top:center_y },
        300,
        'swing'
      );
    else
      $(selector).css('left',center_x);
      $(selector).css('top',center_y);

window.trim = (stringToTrim) ->
    return stringToTrim.replace(/^\s+|\s+$/g,"")

window.alignHeights = (selector) ->
  max_intervention_title_height = 0
  $(selector).each ->
    if $(this).height() > max_intervention_title_height
      max_intervention_title_height = $(this).height()
  if max_intervention_title_height > 0
    $(selector).height(max_intervention_title_height)

window.showPoints = (score_value) ->
  $('#score-modal .score-value').text(score_value)
  $('#score-modal').modal('show');
  setTimeout(->
    $('#score-modal').modal('hide');
  , 1500);

window.URLParameter = (name) ->
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.search)
  if results == null
    return ""
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "))

window.checkEmail = (inputvalue) ->
    pattern=/^([a-zA-Z0-9\+_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
    if pattern.test(inputvalue)
      return true
    else
      return false

window.parseRSS = (url, callback) ->
  $.ajax({
    url: document.location.protocol + '//ajax.googleapis.com/ajax/services/feed/load?v=2.0&num=10&callback=?&q=' + encodeURIComponent(url),
    dataType: 'json',
    success: (data) ->
      #console.log(data.responseData.feed)
      callback(data.responseData.feed);
  });

$ ->
  $('.camera-controls .cloudinary-fileupload').bind('fileuploadstart', (e, data) ->
    window.togglePopunder()
    $('#photo-modal .modal-body').html('Uploading photo...<div class=\"image-progress\"></div>');
    $('#photo-modal').modal('show')
  );

  $('.camera-controls .cloudinary-fileupload').bind('fileuploadprogress', (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $('#photo-modal .modal-body').find('.image-progress').html(progress + '% complete')
  );

  $('.camera-controls .cloudinary-fileupload').bind('fileuploadfail', (e, data) ->
    $('#photo-modal .modal-body').html('image upload failed...');
    $('#photo-modal').modal('show')
  );

  $('.camera-controls .cloudinary-fileupload').bind('cloudinarydone', (e, data) ->
    $('.camera-controls .cloudinary-preview').html($.cloudinary.image(data.result.public_id,{ format: data.result.format, version: data.result.version, angle: 'exif' }));
    window.addToGallery($('.camera-controls .cloudinary-preview img').attr('src'))
    $('#photo-modal').modal('hide')
    return true;
  );


$ ->
  $('.slider-handle').each ->
    grid_size = Math.round(($(window).width() - 100) / ($(this).attr('app-data-slider-step') - 0));
    $(this).draggable({
      axis: "x",
      containment: $('body'),
      grid: [ grid_size,grid_size ],
      stop: ->
          position = $(this).position()
          answer = (Math.floor(position.left / grid_size)) / 2
          $(this).parents('form').find('input[name=answer]').val(answer)
    });



$ ->
  $('.flexslider').each ->
    if $(this).find('.slides li').length > 1
      $(this).flexslider({
        animation: "slide",
        animationLoop: false,
        slideshow: false
      });
    else
      $(this).find('.slides li').css('display','block')

$ ->
  $('.disable-enter-submit').keypress (e) ->
      code = e.keyCode || e.which;
      if code == 13
          e.preventDefault()
          return false

window.showFlickrFeedDefault = () ->
 window.togglePopunder()
 window.showFlickrFeed('.flickr-input-field')


window.showFlickrFeed = (input_selector) ->
  flickr_content = ''
  search_terms_array = ''
  if $(input_selector).length
    if $(input_selector).val() != ''
      search_terms_array = $(input_selector).val().split(' ');
    else
      search_terms_array = $('#title').text().split(' ');
  stop_words = new Array("a","about","above","after","again","against","all","am","an","and","any","are","aren't","as","at","be","because","been","before","being","below","between","both","but","by","can't","cannot","could","couldn't","did","didn't","do","does","doesn't","doing","don't","down","during","each","few","for","from","further","had","hadn't","has","hasn't","have","haven't","having","he","he'd","he'll","he's","her","here","here's","hers","herself","him","himself","his","how","how's","i","i'd","i'll","i'm","i've","if","in","into","is","isn't","it","it's","its","itself","like","let's","me","more","most","mustn't","my","myself","no","nor","not","of","off","on","once","only","or","other","ought","our","ours","ourselves","out","over","own","same","shan't","she","she'd","she'll","she's","should","shouldn't","so","some","such","than","that","that's","the","their","theirs","them","themselves","then","there","there's","these","they","they'd","they'll","they're","they've","this","those","through","to","too","under","until","up","very","was","wasn't","we","we'd","we'll","we're","we've","were","weren't","what","what's","when","when's","where","where's","which","while","who","who's","whom","why","why's","with","won't","would","wouldn't","you","you'd","you'll","you're","you've","your","yours","yourself","yourselves")
  search_terms_filtered_array = new Array()
  for i in [0..(search_terms_array.length - 1)] by 1
    if(jQuery.inArray(search_terms_array[i].toLowerCase(), stop_words) < 0)
      search_terms_filtered_array.push(search_terms_array[i])
  search_terms = search_terms_filtered_array.join(',')
  url = 'https://secure.flickr.com/services/feeds/photos_public.gne?tags=' + search_terms + '&lang=en-us&format=json&jsoncallback=?'
  $.getJSON url, (data) ->
    items = []
    $.each data.items, (key, json_item) ->
      items.push('<li><a href=\"' + json_item.media.m + '\"><span class=\"img\" style=\"background:url(' + json_item.media.m + ') 0px 0px no-repeat; background-size:cover\" >x</span></a></li>')
    flickr_content = '<form class=\'flickr-search-form\'  onsubmit=\'return false;\'><div id=\'flickr-slideshow\'><ul class=\'slides\'>' + items.join('') + '</ul></div><div class=\'button-container\'><input type=\'text\' name=\'search_terms\' class=\'search_terms text-input-1\' placeholder=\'Search\'><a href="#" class="button-7 lightbg" id="button-flickr-search"><span class="outer"><span class="inner search"><span>search</span></span></span></a></div></form>'
    modal_body_container = $('#photo-modal .modal-body')
    modal_body_container.find('.flickr-search-form').remove()
    modal_body_container.html(flickr_content);
    $('#photo-modal').modal({})
    $('#photo-modal form.flickr-search-form li a').click (event) ->
      event.preventDefault()
      event.stopPropagation()
      window.addToGallery($(this).attr('href'))
    $('#photo-modal form.flickr-search-form a#button-flickr-search').click (event) ->
      event.preventDefault()
      event.stopPropagation()
      window.showFlickrFeed('.flickr-search-form .search_terms')
    $('#photo-modal form.flickr-search-form .search_terms').keypress (event) ->
      if ( event.which == 13 )
        window.showFlickrFeed('.flickr-search-form .search_terms')

    setTimeout(->
      $('#flickr-slideshow').flexslider({
          animation: "slide",
          animationLoop: false,
          slideshow: false,
          itemWidth: 100,
          itemMargin: 10,
          minItems: 3,
          maxItems: 3
        });
    ,200);


window.addToGallery = (img_url) ->
  $('.flexslider-mini-gallery').each () ->
    if $(this).data('flexslider') != undefined
      obj = $(document.createElement("li")).html("<a href=\"#\" class=\"remove-button\" onclick=\"window.removeFromGallery(this)\">x</a><div class=\"img-container\"><div class=\"img-container-content\" style=\"background:url(" + img_url + ") 0px 0px no-repeat; background-size:cover;\">x</div></div><input type=\"hidden\" name=\"images[]\" value=\"" + img_url + "\" />");
      pos = $(this).find('.slides li').length - 1
      $(this).data('flexslider').addSlide(obj, pos)
      $('#photo-modal').modal('hide')

window.removeFromGallery = (obj) ->
  flexslider_element = $(obj).parents('.flexslider-mini-gallery')
  list_element = $(obj).parent()
  pos = flexslider_element.find('.slides li').index(list_element)
  flexslider_element.data('flexslider').removeSlide(pos)

window.adjustUploadGallery = (gallery_element) ->
  num_slides = gallery_element.find('.slides li').length
  num_content_slides = num_slides - 1
  slide_to = Math.floor(num_slides / 3)
  if num_slides <= 3
    slide_to = 0

  if gallery_element.attr('data-max-images')?
    if num_content_slides >= gallery_element.attr('data-max-images')
      gallery_element.find('#button-take-photo').removeClass('disabled').addClass('disabled')
    else
      gallery_element.find('#button-take-photo').removeClass('disabled')

  setTimeout(->
    gallery_element.data('flexslider').flexAnimate(slide_to,true);
  , 300);


window.toggleToolTip = () ->
  if $('.tip-container').css('display') == 'block'
    window.hideToolTip()
  else
    window.showToolTip()

window.hideToolTip = () ->
  $('.tip-container').animate(
      { opacity: 0.0 },
      300,
      'swing',
      ->
        $('.tip-container').css({'display':'none'})
        $('#navbar-button-right').removeClass('brain-on').removeClass('brain').addClass('brain')
  );

window.showToolTip = () ->
  $('.tip-container').css({'display':'block','opacity':0})
  $('.tip-container').animate(
    { opacity: 1.0 },
    300,
    'swing'
  );
  ga_category = 'buttons'
  ga_action = 'why'
  ga_label = $('#tip-container-header').attr('data-ga-label')
  if ga_category? && ga_action? && ga_label?
    _gaq.push(['_trackEvent', ga_category, ga_action, ga_label]);


window.recursiveUnbind = (container_obj) ->
  container_obj.unbind();
  container_obj.children().each( ->
    window.recursiveUnbind($(this))
  )
