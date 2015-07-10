APP.buildComponents = function(container_obj) {

  container_obj.removeClass('components-built').addClass('components-built');
  container_obj.find('textarea.wysihtml').wysihtml5();

  container_obj.find('.button-2').each(function(index) {
    if($(this).find('.button-content').length <= 0) {
      $(this).wrapInner('<span class="button-content">');
    }
  });

  container_obj.find('input.custom-checkbox').each(function(index) {

    var checkbox_element = $(this)
    if($(this).parents('.tooltip-content').length <= 0) { //to be rendered later

      //popover handling
      var popover_parent = $(this).parents('.popover');
      var original_checkbox = [];
      if(popover_parent.length > 0) {
        var tooltip_parent = popover_parent.parent().find('.tooltip-content')
        original_checkbox = tooltip_parent.find("input[name=" + checkbox_element.attr('name') + "]")
        if(original_checkbox.length > 0 && original_checkbox.is(":checked")) {
          $(this).prop('checked',true).attr('checked',true)
        }
      }

      $(this).checkbox();
      if ($(this).attr('data-toggle-show-class') !== undefined) {
        var target_element = $('.' + $(this).attr('data-toggle-show-class'))
        if ($(this).is(":checked")) {
          target_element.show()
        } else {
          target_element.hide()
        }
        $(this).on('change',function(event) {
          if ($(this).is(":checked")) {
            target_element.show()
          } else {
            target_element.hide()
          }
        })
      }
      if ($(this).attr('data-toggle-readonly-id') !== undefined) {
        var target_element = $('#' + $(this).attr('data-toggle-readonly-id'))
        if ($(this).is(":checked")) {
          target_element.attr('readonly', false);
          target_element.removeClass('disabled')
        } else {
          target_element.attr('readonly', true);
          target_element.removeClass('disabled').addClass('disabled')
        }
        $(this).on('change',function(event) {
          if ($(this).is(":checked")) {
            target_element.attr('readonly', false);
            target_element.removeClass('disabled')
          } else {
            target_element.attr('readonly', true);
            target_element.removeClass('disabled').addClass('disabled')
          }
        })
      }

      //popover handling continued
      if(original_checkbox.length > 0) {
          $(this).on('change',function(event) {
            if ($(this).is(":checked")) {
              original_checkbox.prop('checked',true).attr('checked',true);
            } else {
              original_checkbox.prop('checked',false).attr('checked',false);
            }
          });
      }

    }

  })

  container_obj.find('.force-one-row').each(function(row_index) {

    row_element = $(this);
    row_width = 0;
    row_element.children().each(function(children_index) {
      row_width += $(this).outerWidth();
      row_width += parseInt($(this).css("marginLeft").substring(0,$(this).css("marginLeft").length - 1));
      row_width += parseInt($(this).css("marginRight").substring(0,$(this).css("marginRight").length - 1));
      row_width += 5; //inline blocks
    })
    row_element.width(row_width);

  });

  container_obj.find('.button-copy').on("mouseup",function(e) {
    e.preventDefault();
    e.stopPropagation();
    target_element = $($(this).attr('data-rel'))
    target_element.focus()
    target_element.select()
  })

  container_obj.find('.message-box .close-button').click(function(e) {
    e.preventDefault();
    e.stopPropagation();

    message_box = $(this).parents('.message-box')
    if (message_box.hasClass('show-only-on-initial-view') && message_box.attr('data-admin-id') !== undefined && message_box.attr('data-page') !== undefined) {

      jqxhr = $.ajax({
        type: "POST",
        url: '/company/showhelp',
        cache: false,
        data: {
          admin_id: message_box.attr('data-admin-id'),
          page: message_box.attr('data-page')
        },
      }).done(function(data) {
        if (data["response"] == "success") {
          message_box.fadeOut("slow",function() {
            $(this).remove()
          });
        } else {
          window.console.log("Request failed." + data.message);
        }
      }).fail(function(data) {
        window.console.log("Request failed.");
      });

    } else {

      $(this).parents('.message-box').fadeOut("slow",function() {
        $(this).remove()
      });

    }

  })

  container_obj.find('#page-notification .close-button').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    APP.hidePageNotification();
  })

  container_obj.find('#page-alert-container').hover(function() {
    if (APP.timers.pageAlert !== undefined) {
      clearTimeout(APP.timers.pageAlert);
    }
  })

  container_obj.find('#page-alert-container').mouseout(function() {
    //broken
    //APP.hidePageAlert();
  })

  container_obj.find('#page-alert-container .close-button').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    APP.hidePageAlert();
  })

  container_obj.find('#content-modal-alert-container .close-button').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    APP.hideContentModalAlert();
  })

  container_obj.find('.modal-close-button').click(function(e) {
    e.preventDefault()
    e.stopPropagation()
    $(this).parents('#content-modal').modal('hide')
  })

  container_obj.find('#content-modal').on('shown.bs.modal', function() {
      if (APP.trim($(this).find('.modal-header-content').text()) == '') {
        $(this).removeClass('hidden-header').addClass('hidden-header')
      } else {
        $(this).removeClass('hidden-header')
      }
  })

  container_obj.find('.slider-container').each(function() {

    var slider_container_element = $(this);
    var num_values = slider_container_element.find('.label-list li').length;
    var value = 1;

    if(slider_container_element.find('.slider').length <= 0) {

      num_answers = slider_container_element.find('.label-list li').length - 1
      if (slider_container_element.find('.slider-value').length > 0) {
        //slider index starts at 1
        value = Math.round(parseInt(slider_container_element.find('.slider-value').val()) / 100 * num_answers) + 1;
      }

      slider_container_element.find('.slider-input').slider({
        min: 1,
        value: value,
        max: num_values,
        step: 1,
        orientation: 'horizontal',
        tooltip: 'hide',
        handle: 'square'
      }).on('slide slideStop',function(ev) {
         value = parseInt($(this).slider('getValue'));
         slider_container_element = $(this).parents('.slider-container');
         answer_label = slider_container_element.find('.label-list li').eq(value - 1).text()
         slider_container_element.find('.label').text(answer_label)
         slider_container_element.find('input.slider-input').val(answer_label);
         num_answers = slider_container_element.find('.label-list li').length - 1
         slider_container_element.find('input.slider-value').val(parseInt((value - 1)/num_answers*100)).trigger('change');
      });

      answer_index = value - 1
      if (answer_index < 0) {
        answer_index = 0
      }
      answer_label = slider_container_element.find('.label-list li').eq(answer_index).text()
      slider_container_element.find('.label').text(answer_label)
      slider_container_element.find('input.slider-input').val(answer_label);
      //slider_container_element.find('input.slider-value').val((value - 1)/num_answers*100);

    }

  })

  container_obj.find('.slider-results').each(function() {

    var slider_results_element = $(this);
    var bar_percentage = slider_results_element.attr('data-percentage')
    if (slider_results_element.find('.bar-outer').length <= 0) {

      if (slider_results_element.attr('data-required-percentage') !== undefined) {
        var bar_class = "yellow";
        var required_percentage = parseInt(slider_results_element.attr('data-required-percentage'));
        if (parseInt(bar_percentage) >= required_percentage) {
          bar_class = "green";
        }
        slider_results_element.removeClass(bar_class).addClass(bar_class)
        slider_results_element.append('<div class="bar-outer"><div class="bar-inner"><div class="required-level">|</div>' + bar_percentage + '</div></div>');
        slider_results_element.find('.bar-outer').css({'margin':'7px 0px'})
        slider_results_element.find('.bar-inner').css({'width':bar_percentage + '%'})
        slider_results_element.find('.required-level').css({'position':'absolute','left':required_percentage + '%'})
      } else {
        slider_results_element.append('<div class="bar-outer"><div class="bar-inner">' + bar_percentage + '</div></div>');
        slider_results_element.find('.bar-inner').css({'width':bar_percentage + '%'})
      }

    }

  })

  container_obj.find('.dynamic-section').each(function() {
    var dynamic_section = $(this);
    var section_toggle_container = $(this).parents('.section-toggle-container');

    dynamic_section.find('.close-button').click(function(event) {
      event.preventDefault();
      event.stopPropagation();

      if(section_toggle_container.length > 0 && typeof $(this).attr('data-input-prefix') !== 'undefined' && APP.trim($(this).attr('data-input-prefix')) != '') {
        section_toggle_container.find('a[data-input-prefix=' + $(this).attr('data-input-prefix') +']').parents('li').removeClass('disabled')
      }
      dynamic_section.remove();

    })
  })

  container_obj.find('.content-toggle').each(function() {
    content_toggler = $(this)
    if (content_toggler.attr('data-rel') !== undefined) {

      target_element = $(content_toggler.attr('data-rel'));
      if (content_toggler.hasClass('active')) {
        target_element.show()
      } else {
        target_element.hide()
      }

      content_toggler.click(function(event) {
        event.preventDefault();
        event.stopPropagation();

        target_element = $($(this).attr('data-rel'));
        if ($(this).hasClass('active')) {
          $(this).removeClass('active')
          target_element.hide()
        } else {
          $(this).addClass('active')
          target_element.show()
        }
        APP.resizeCanvas($('body'))
      });

    }

  })

  container_obj.find('.section-toggle-container').each(function() {
    var section_toggle_container = $(this);
    var dynamic_sections_container = section_toggle_container.find('.dynamic-sections-container')

    section_toggle_container.find('.section-toggle-buttons a').click(function(event) {
      event.preventDefault();
      event.stopPropagation();
      $(this).parents('li').removeClass('disabled').addClass('disabled');

      var source   = section_toggle_container.find(".dynamic-section-template").html();
      var template = Handlebars.compile(source);
      var filtered_label = APP.filterStringForInput($(this).text());
      var context = {
        header: filtered_label,
        label: filtered_label,
        input_prefix: $(this).attr('data-input-prefix'),
        container_class: ''
      }
      var html    = template(context);

      dynamic_sections_container.prepend(html);
      APP.buildComponents(dynamic_sections_container);
      dynamic_sections_container.trigger("afterAddDynamicSection")
    })

    section_toggle_container.find('.add-button').click(function(event) {
      var add_other_label_input = section_toggle_container.find('.other-label')
      if(APP.trim(add_other_label_input.val()) != '') {

        event.preventDefault();
        event.stopPropagation();
        $(this).parents('li').removeClass('disabled').addClass('disabled');

        var filtered_label = APP.filterStringForInput(add_other_label_input.val());
        var already_used = false;
        $('.other-skill-container input').each(function(index) {
          if(APP.trim($(this).val()) == APP.trim(filtered_label)) {
            already_used = true;
          }
        })


        if(already_used) {

          APP.showPageAlert(3,'The skill ' + filtered_label + ' is already used.','',1);

        } else {

          var input_prefix = 'other_skill_' + (dynamic_sections_container.find('.other-skill-container').length + 1)

          var source   = section_toggle_container.find(".dynamic-section-template").html();
          var template = Handlebars.compile(source);
          var context = {
            header: filtered_label,
            label: filtered_label,
            input_prefix: input_prefix,
            container_class: 'other-skill-container'
          }
          var html    = template(context);

          dynamic_sections_container.prepend(html);
          add_other_label_input.val('')
          $('.swiftype-widget .autocomplete div').empty()
          APP.buildComponents(dynamic_sections_container);
          dynamic_sections_container.trigger("afterAddDynamicSection")

        }

      } else {
        APP.showPageAlert(3,'Please enter the name for the skill you would like to add.','',1);
      }
    })


  })

  //mixpanel
  container_obj.find('.mixpanel-track-click').click(function(event) {
    if(!$(this).hasClass('disabled')) {
      APP.mixpanel_track($(this).attr('data-mp-event'),{})
    }
  })

  container_obj.find('[data-toggle="tooltip"]').each(function() {
    $(this).tooltip()
  })

  container_obj.find('.tooltip-trigger').each(function() {
    var tooltip_trigger_element = $(this);
    var placement = 'top';
    var trigger = 'hover focus';
    var container = false;

    if ($(this).attr('data-tooltip-placement') !== undefined) {
      placement = $(this).attr('data-tooltip-placement');
    }
    if ($(this).attr('data-tooltip-trigger') !== undefined) {
      trigger = $(this).attr('data-tooltip-trigger');
    }

    if ($(this).attr('data-tooltip-container') !== undefined) {
      container = $(this).attr('data-tooltip-container');
    }

    tooltip_trigger_element.popover({
      trigger: trigger,
      placement: placement,
      container: container,
      content: function() {
        return tooltip_trigger_element.find('.tooltip-content').html()
      },
      html: 1
    });

    /*
    tooltip_trigger_element.on('show.bs.popover', function () {
      var popover_element = tooltip_trigger_element.parent().find('.popover');
      if (popover_element.length != 1 && tooltip_trigger_element.next().hasClass('popover')) {
        popover_element = tooltip_trigger_element.next()
      }
      if(popover_element.length > 0) {
        popover_element.show();
      }
    })
    */

    tooltip_trigger_element.on('shown.bs.popover', function () {
      var popover_element = tooltip_trigger_element.parent().find('.popover');
      if (popover_element.length != 1 && tooltip_trigger_element.next().hasClass('popover')) {
        popover_element = tooltip_trigger_element.next()
      }
      $(this).removeClass('active').addClass('active')
      if(popover_element.length > 0) {
        popover_element.find('form').removeClass('ready') //add back listeners
        APP.buildComponents(popover_element);
      }
    })

    tooltip_trigger_element.on('hidden.bs.popover', function () {

      $(this).removeClass('active')
      /*
      var popover_element = tooltip_trigger_element.parent().find('.popover');
      if (popover_element.length != 1 && tooltip_trigger_element.next().hasClass('popover')) {
        popover_element = tooltip_trigger_element.next()
      }
      if (popover_element.length > 0) {
        popover_element.hide();
      }
      */
    })

  })

  APP.enableScreens(container_obj);

  container_obj.find('.feedback-link').click(function(event) {
    APP.showFeedbackModal()
  });

  container_obj.find('.close-modal-after-submit').bind('onSuccess',function() {
    APP.hideContentModal();
  })

  container_obj.find('a.smooth-scroll').click (function(event) {

    event.preventDefault();
    var anchor = $(this);
    var selector_text = anchor.attr('href')
    if (typeof selector_text !== 'undefined') {
      selector_text = selector_text.replace('/', '')
    }

    var screen_index = anchor.attr('data-screen')
    if (typeof screen_index !== 'undefined') {
      APP.jumpToScreen(parseInt(screen_index));
    }

    selector = $(selector_text)
    if (selector.length > 0) {
      $('html, body').stop().animate({
        scrollTop: selector.offset().top - 50
      }, 500,'swing');
    } else {
      self.location = anchor.attr('href')
    }

  })

  container_obj.find('.time-picker').timepicker({
    scrollDefault: '09:00'
  });

  container_obj.find('.time-picker.start').each(function(index) {
    time_picker_element = $(this)

    time_pickers_element = time_picker_element.parents('.time-pickers-container')

    if (time_pickers_element.length > 0) {
      end_time_picker = time_pickers_element.find('.time-picker.end')
      if (end_time_picker.length > 0) {
        time_picker_element.on('changeTime', function() {
            end_time_picker = $(this).parents('.time-pickers-container').find('.time-picker.end')
            if(APP.trim(end_time_picker.val()) == '') {
              current_time = $(this).timepicker('getTime', new Date());
              later = new Date(current_time.getTime() + (1*1000*60*60));
              end_time_picker.timepicker('setTime', later);
            }
        });
      }
    }
  })

  container_obj.find('.time-picker.end').each(function(index) {
    time_picker_element = $(this)

    time_pickers_element = time_picker_element.parents('.time-pickers-container')

    if (time_pickers_element.length > 0) {
      start_time_picker = time_pickers_element.find('.time-picker.start')
      if (start_time_picker.length > 0) {
        time_picker_element.on('changeTime', function() {
            start_time_picker = $(this).parents('.time-pickers-container').find('.time-picker.start')
            if(APP.trim(start_time_picker.val()) == '') {
              current_time = $(this).timepicker('getTime', new Date());
              before = new Date(current_time.getTime() - (1*1000*60*60));
              start_time_picker.timepicker('setTime', before);
            }
        });
      }
    }
  })

  container_obj.find('.flexslider').flexslider({
    animation: "slide",
    controlNav: "thumbnails"
  });

  container_obj.find('a').click(function(e) {
    if ($(this).hasClass('disabled')) {
      e.preventDefault()
    }
  })

  $('.main-nav-list li .smooth-scroll').click(function(e) {
    $('.main-nav-list li').removeClass('active')
    $(this).parents('li').addClass('active')
  });

  container_obj.find('.use-s3-upload').each(function(index) {
    image_container = $(this)
    APP.s3upload = APP.s3upload != null ? APP.s3upload : new S3Upload(
    {
        s3_sign_put_url: '/signS3put',
        file_dom_selector: '.use-s3-upload input[type=file]',
        onProgress: function(percent, message)
        {
          window.console.log("making progress")
          // Use this for live upload progress bars
          //console.log('Upload progress: ', percent, message);
        },
        onFinishS3Put: function(public_url)
        {
          // Get the URL of the uploaded file
          //console.log("on finosh")
          //console.log(public_url)
          var input_file_container = image_container.find('input[type=file]')
          image_container.css("background-image", "url(" + public_url + "?v=" + Math.random() + ")")
          image_container.css("background-size", "cover")
          image_container.css("background-position", "0px 0px")
          image_container.find(".image-public-url").val(public_url)
          // $("#avatar_url").val(public_url)
          // $("#uploading").hide();
          // $("#dev_avatar").show();
          // $("#dev_avatar").attr("src",public_url).removeAttr("height");

          // $(".avatar-box").css("background", "none");
          // $(".avatar-box").css("border", "0px none");

          // $("#btn_next").val("Next");
        },
        onError: function(status)
        {
          window.console.log(status)
        }
    });

    image_container.find("input[type=file]").change(function()
    {
      if($(this)[0].files[0])
      {
        file = $(this)[0].files[0];

        var file_valid = true;
        var allowed_file_types = ['image/gif','images/gif','image/jpeg','image/jpg','image/pjpeg','image/png'];
        if (file.size > 2000000) {
          file_valid = false;
          APP.showPageAlert(3,'The file you have selected is too large. Must be under 2MB.','',1);
        } else if (!_.contains(allowed_file_types, file.type)) {
          file_valid = false;
          APP.showPageAlert(3,'The file you have selected is not in an approved format. Must be of type JPG, PNG or GIF.','',1);
        }

        if (file_valid) {
          ext = file.name.split(".")[1]
          APP.s3upload.s3_object_name = image_container.attr('data-s3-object-name') + '.' + ext
          APP.s3upload.uploadFile(file);
        }

      }
    });

  })

  container_obj.find('.read-more').each(function(index) {
    read_more_container = $(this)
    read_more_link_element = $(this).find('.read-more-link');
    max_height = parseInt(read_more_container.attr('data-start-height'));
    if(read_more_link_element.length <= 0 && read_more_container.height() > max_height) {
      read_more_container.wrapInner('<div class="collapsible-content">');
      read_more_container.find('.collapsible-content').css({maxHeight:max_height});
      read_more_container.append('<a href="#" class="read-more-link">Read </a>')
      read_more_link_element = read_more_container.find('.read-more-link');
      read_more_link_element.click(function(e) {
       e.preventDefault();
       e.stopPropagation();
       read_more_container.toggleClass('expanded')
      });
    }
  })

  container_obj.find('.video-modal-link').click(function(e) {

    var html = ""
    var source   = $(".video-modal-template").html();
    var template = Handlebars.compile(source);
    var context = {
      video_id: $(this).attr('data-video-id')
    }
    html    = template(context);

    var modal_body_element = $("#content-modal .modal-body")

    modal_body_element.html(html)
    APP.buildComponents(modal_body_element);

    if ($(this).attr('data-header-title') !== undefined) {
      $("#content-modal .modal-header-content").text($(this).attr('data-header-title'))
      $("#content-modal").removeClass('hidden-header')
    } else {
      $("#content-modal").removeClass('hidden-header').addClass('hidden-header')
    }

    $("#content-modal").modal("show");

  });

  container_obj.find('select').each(function(index) {
    $(this).on('focus',function() {
      $(this).find('option').each(function(option_index) {
        $(this).html(APP.replaceAll($(this).html(),' ','&nbsp;'))
      })
    })
    $(this).on('blur',function() {
      $(this).find('option').each(function(option_index) {
        $(this).html(APP.replaceAll($(this).html(),'&nbsp;',' '))
      })
    })
  })

  container_obj.find('.dropdown-multiselect').each(function(index) {

    var dropdown_element = $(this)
    dropdown_element.find('.value').click(function(event) {
      dropdown_element.toggleClass('active')
    });

    /*
    dropdown_element.bind('touchend', function(e) {
      e.preventDefault();
      $(this).toggleClass('hover');
    });
    */

    dropdown_element.find('input[type=radio]').click(function(event) {
      dropdown_element.find('> ul > li').removeClass('active')
      if($(this).is(":checked")) {
        $(this).parents('li').addClass('active')

        value_element = dropdown_element.find('.value')
        value_element.text($(this).parent().find('label').text())

        sublist_element = $(this).parents('li').find('ul')
        if(sublist_element.length > 0) {
          selected_values = []
          sublist_element.find('input[type=checkbox]:checked').each(function(index) {
            selected_values.push($(this).parent().find('label').text())
          })
          if (selected_values.length > 0) {
            value_element.text(selected_values.join(', '))
          } else {
            value_element.text(value_element.attr('data-default-value'))
          }

        }
      }

    })

    dropdown_element.find('input[type=checkbox]').click(function(event) {
      selected_values = []
      dropdown_element.find('input[type=checkbox]').each(function(index) {
        if($(this).is(":checked")) {
          selected_values.push($(this).parent().find('label').text())
        }
      })

      value_element = dropdown_element.find('.value')

      if (selected_values.length > 0) {
        value_element.text(selected_values.join(', '))
      } else {
        value_element.text(value_element.attr('data-default-value'))
      }

    })

  })




  container_obj.find('.fb_js_sdk_share_link').click(function(e) {

    e.preventDefault();
    e.stopPropagation();

    var description = "";
    if ($(this).attr('data-fbshare-description-target') !== undefined) {
      description = $($(this).attr('data-fbshare-description-target')).val()
    } else if ($(this).attr('data-fbshare-description') !== undefined) {
      description = $(this).attr('data-fbshare-description')
    }

    try {

      obj = {
        method: 'feed',
        link: $(this).attr('href'),
        picture: $(this).attr('data-fbshare-picture'),
        name: $(this).attr('data-fbshare-name'),
        caption: 'Powered by app',
        description: description
      }
      FB.ui(obj, function(response) {

      });

    } catch(err) {
      window.console.log(err.message)
    }

  });

  container_obj.find('.fb_js_sdk_share_basic_link').click(function(e) {

    e.preventDefault();
    e.stopPropagation();

    try {

      obj = {
        method: 'share',
        href: $(this).attr('href')
      }
      FB.ui(obj, function(response) {

      });

    } catch(err) {
      window.console.log(err.message)
    }

  });


  container_obj.find("#content-modal").on('hide.bs.modal', function() {
    var video_iframe_element = $(this).find('.video-container iframe');
    if (video_iframe_element.length > 0) {
      video_iframe_element.get(0).contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*');
    }
  });

  container_obj.find('.trigger-reamaze').click (function(e) {
    e.preventDefault()
    e.stopPropagation()
    $( "#reamaze-widget" ).trigger( "click" );
  });

  /*subscription*/
  container_obj.find('.modal-show-current-plan-button').click(function(e) {
    e.preventDefault()
    e.stopPropagation()

    APP.showUpgradeSubscriptionModal({header: 'UPGRADE PLAN'})

  })

  container_obj.find('#payment-form .payment-plans-container > div').click(function(e) {

    e.preventDefault()
    e.stopPropagation()
    if (!$(this).hasClass('selected') && $(this).attr('data-plan-value') !== undefined) {
      $("#content-modal").removeClass('wide hidden-header')
      $('#content-modal .modal-dialog').attr('style','')
      $("#content-modal .modal-header-content").html("Confirm your plan")
      modal_body_element = $("#content-modal .modal-body")
      template = $('.change-plan-confirm-template')
      source   = template.html();
      template = Handlebars.compile(source);
      context = {
        plan: $(this).attr('data-plan-name'),
        plan_value: $(this).attr('data-plan-value'),
        plan_description: $(this).attr('data-plan-description')
      }
      html    = template(context);
      modal_body_element.html(html)
      APP.buildComponents(modal_body_element)
    } else if($(this).attr('href') !== undefined) {
      self.location = $(this).attr('href')
    }

  });

  container_obj.find("form#form-upgrade-plan").unbind('onSuccess')
  container_obj.find('form#form-upgrade-plan').bind('onSuccess', function(data) {
    $("#content-modal").removeClass('wide hidden-header')
    $("#content-modal .modal-header-content").html("Congratulations!")
    modal_body_element = $("#content-modal .modal-body")
    template = $('.change-plan-success-template')
    source   = template.html();
    template = Handlebars.compile(source);
    context = {}
    html    = template(context);
    modal_body_element.html(html)
    APP.buildComponents(modal_body_element)

    setTimeout( function() {
      location.reload(); //reload page
    },2000);

  })


  /*form handling*/
  APP.addFormValidation(container_obj)

  /*
  container_obj.find('.navbar-sublist .item').click(function(e) {
      e.preventDefault();
      e.stopPropagation();
      $(this).parent().toggleClass('active');
  })
  */


  container_obj.find('[data-toggle=collapse]').on('hidden.bs.collapse', function () {
    APP.resizeCanvas(container_obj)
  })

  container_obj.on('click', function (e) {
      $('[data-toggle=popover]').each(function () {
          // hide any open popovers when the anywhere else in the body is clicked
          if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
               $(this).popover('hide');
          }
      });
      $('.dropdown-multiselect').each(function () {
          // hide any open popovers when the anywhere else in the body is clicked
          if (!$(this).is(e.target) && $(this).has(e.target).length === 0) {
               $(this).removeClass('active');
          }
      });
      /*
      $('.navbar-sublist').each(function () {
          // hide any open popovers when the anywhere else in the body is clicked
          if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.navbar-sublist').has(e.target).length === 0) {
               $(this).removeClass('active');
          }
      });
      */
  });

  container_obj.on('mouseup', function (e) { //hide when clicked outside

    $('.time-picker').each(function () {
        if (!$(this).is(e.target) && $(this).has(e.target).length === 0) {
          $(this).parents('.time-picker-container').find('.time-picker-dd').removeClass('active')
        }
    });

  });

  APP.buildAdditionalComponents(container_obj);

}

APP.closeAllPopovers = function() {

  $('[data-toggle=popover]').each(function () {
    $(this).popover('hide');
  });

}

APP.buildAdditionalComponents = function() {

}

APP.showPageAlert = function(type, message, title, autoFade) {

  if (APP.trim(message) == '') return true;

  var alert_class = ""
  switch(type)
  {
    case 1: alert_class = "success";
    break;
    case 2: alert_class = "info";
    break;
    case 3: alert_class = "warning";
    break;
    case 4: alert_class = "danger";
    break;
  }

  $('#page-alert-container').removeClass('success info warning danger').addClass(alert_class)

  $('#page-alert-message').html(message);
  height = $('#page-alert-message .content').height()
  if(autoFade) {
    if(autoFade > 1) {
      $('#page-alert-container').animate({maxHeight: 100},"ease", function() {

        APP.timers.pageAlert = setTimeout( function() {
          $('#page-alert-container').animate({maxHeight: 0},"ease",function() {
            $('#page-alert-message').html('')
          })
        },autoFade);

      });
    } else {
      $('#page-alert-container').animate({maxHeight: 100},"ease", function() {

        APP.timers.pageAlert = setTimeout( function() {
          $('#page-alert-container').animate({maxHeight: 0},"ease",function() {
            $('#page-alert-message').html('')
          })
        },3000);

      });
    }
  } else {
    $('#page-alert-container').animate({maxHeight: 100},"ease", function() { });
  }
}

APP.hidePageAlert = function() {
  $('#page-alert-container').animate({maxHeight: 0},"ease", function() {
    $('#page-alert-message').html('')
  });
}

APP.hidePageNotification = function() {
  var page_notification_element = $('#page-notification');
  page_notification_element.removeClass('closed').addClass('closed')
  admin_id = page_notification_element.attr('data-admin-id')
  user_id = page_notification_element.attr('data-user-id')
  message_box = page_notification_element.find('.message')

  if (message_box.length > 0) {

    var target_url = "/company/showhelp";
    if(APP.trim(admin_id) == '' && APP.trim(user_id) != '') {
      target_url = "/developer/" + user_id + "/helpbox/" + message_box.attr('data-page');
    }

    jqxhr = $.ajax({
      type: "POST",
      url: target_url,
      cache: false,
      data: {
        admin_id: admin_id,
        page: message_box.attr('data-page')
      },
    }).done(function(data) {
      if (data["response"] == "success") {
        message_box.fadeOut("slow",function() {
          $(this).remove()
        });
      } else {
        window.console.log("Request failed." + data.message);
      }
    }).fail(function(data) {
      window.console.log("Request failed.");
    });

  }

}

APP.showContentModalAlert = function(type, message, title, autoFade) {

  if (APP.trim(message) == '') return true;

  var alert_class = ""
  switch(type)
  {
    case 1: alert_class = "success";
    break;
    case 2: alert_class = "info";
    break;
    case 3: alert_class = "warning";
    break;
    case 4: alert_class = "danger";
    break;
  }

  $('#content-modal-alert-container').removeClass('success info warning danger').addClass(alert_class)

  $('#content-modal-alert-message').html(message);
  height = $('#content-modal-alert-message .content').height()
  if(autoFade) {
    if(autoFade > 1) {
      $('#content-modal-alert-container').animate({maxHeight: 100},"ease", function() {

        setTimeout( function() {
          $('#content-modal-alert-container').animate({maxHeight: 0},"ease",function() {
            $('#content-modal-alert-message').html('')
          })
        },autoFade);

      });
    } else {
      $('#content-modal-alert-container').animate({maxHeight: 100},"ease", function() {

        setTimeout( function() {
          $('#content-modal-alert-container').animate({maxHeight: 0},"ease",function() {
            $('#content-modal-alert-message').html('')
          })
        },3000);

      });
    }
  } else {
    $('#content-modal-alert-container').animate({maxHeight: 100},"ease", function() { });
  }
}

APP.hideContentModalAlert = function() {
  $('#content-modal-alert-container').animate({maxHeight: 0},"ease", function() {
    $('#content-modal-alert-message').html('')
  });
}

APP.hideContentModal = function() {
  $("#content-modal").modal("hide");
}

APP.clearContentModal = function() {
  $("#content-modal").modal("hide");
  $("#content-modal .modal-header .modal-header-content").text('');
  $("#content-modal .modal-body").empty();
}

APP.circleAnimationTimer = []
APP.circleAnimationAngle = []
APP.circleAnimationRadius = []
APP.circleAnimationPercentage = []
APP.drawCircle = function(circle,index) {
  APP.circleAnimationPercentage[index] = parseInt(circle.attr('data-percentage'));
  //angle = parseInt(circle.attr('data-percentage')) * 3.6
  APP.circleAnimationAngle[index] = 0
  APP.circleAnimationRadius[index] = parseInt(circle.attr('data-radius'))
  APP.circleAnimationTimer[index] = window.setInterval( function() {
    APP.circleAnimationAngle[index] +=2;
    radians= (APP.circleAnimationAngle[index]/180) * Math.PI;
    x1 = APP.circleAnimationRadius[index] + Math.sin(Math.PI) * APP.circleAnimationRadius[index];
    y1 = APP.circleAnimationRadius[index] + Math.cos(Math.PI) * APP.circleAnimationRadius[index];

    x2 = APP.circleAnimationRadius[index] + Math.sin(Math.PI - radians) * APP.circleAnimationRadius[index];
    y2 = APP.circleAnimationRadius[index] + Math.cos(Math.PI - radians) * APP.circleAnimationRadius[index];

    x3 = APP.circleAnimationRadius[index] + Math.sin(Math.PI - (359.99/180) * Math.PI) * APP.circleAnimationRadius[index];
    y3 = APP.circleAnimationRadius[index] + Math.cos(Math.PI - (359.99/180) * Math.PI) * APP.circleAnimationRadius[index];

    if (APP.circleAnimationAngle[index] > 357) {
      d = "M" + APP.circleAnimationRadius[index] + "," + APP.circleAnimationRadius[index] + " L" + x1 + "," + y1 + " A" + APP.circleAnimationRadius[index] + "," + APP.circleAnimationRadius[index] + " 0 1,1 " + x3 + "," + y3 + "z";
    } else if (APP.circleAnimationAngle[index] > 180) {
      d = "M" + APP.circleAnimationRadius[index] + "," + APP.circleAnimationRadius[index] + " L" + x1 + "," + y1 + " A" + APP.circleAnimationRadius[index] + "," + APP.circleAnimationRadius[index] + " 0 1,1 " + x2 + "," + y2 + "z";
    } else {
      d = "M" + APP.circleAnimationRadius[index] + "," + APP.circleAnimationRadius[index] + " L" + x1 + "," + y1 + " A" + APP.circleAnimationRadius[index] + "," + APP.circleAnimationRadius[index] + " 0 0,1 " + x2 + "," + y2 + "z";
    }
    circle.attr("d", d);

    if (APP.circleAnimationAngle[index] >= (APP.circleAnimationPercentage[index] * 3.6)) {
      window.clearInterval(APP.circleAnimationTimer[index])
    }
  },10)
}

APP.drawStaticCircle = function(circle,index) {
  APP.circleAnimationPercentage[index] = parseInt(circle.attr('data-percentage'));
  angle = parseInt(circle.attr('data-percentage')) * 3.6
  radius = parseInt(circle.attr('data-radius'))
  radians= (angle/180) * Math.PI;
  x1 = radius + Math.sin(Math.PI) * radius;
  y1 = radius + Math.cos(Math.PI) * radius;

  x2 = radius + Math.sin(Math.PI - radians) * radius;
  y2 = radius + Math.cos(Math.PI - radians) * radius;

  x3 = radius + Math.sin(Math.PI - (359.99/180) * Math.PI) * radius;
  y3 = radius + Math.cos(Math.PI - (359.99/180) * Math.PI) * radius;

  if (angle > 357) {
    d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 1,1 " + x3 + "," + y3 + "z";
  } else if (angle > 180) {
    d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 1,1 " + x2 + "," + y2 + "z";
  } else {
    d = "M" + radius + "," + radius + " L" + x1 + "," + y1 + " A" + radius + "," + radius + " 0 0,1 " + x2 + "," + y2 + "z";
  }
  circle.attr("d", d);
}

APP.updateScrollTopStatus = function () {
  if ($(window).scrollTop() <= 0) {
    $('body').removeClass('not-at-top')
  } else {
    $('body').removeClass('not-at-top').addClass('not-at-top')
  }
}

String.prototype.formatMoney = function(c, d, t){
var n = Number(this.replace(/[^0-9\.]+/g,"")),
    c = isNaN(c = Math.abs(c)) ? 2 : c,
    d = d == undefined ? "." : d,
    t = t == undefined ? "," : t,
    s = n < 0 ? "-" : "",
    i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "",
    j = (j = i.length) > 3 ? j % 3 : 0;
   return '$' + s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
 };