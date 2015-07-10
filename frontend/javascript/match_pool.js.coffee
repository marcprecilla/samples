# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  APP.buildPageCompanyMatchPool($('body.page-company-match-pool'))

APP.buildPageCompanyMatchPool = (container_obj) ->
  return unless container_obj.length == 1

  APP.showMatchPoolModal = (modal_type, match_id, added_context = {}) ->
    match_container = $("#match-cards-container")
    target_match = APP.matchList.get(match_id)
    data_valid = true
    header_title = ""
    html = ""
    context = {}
    if target_match
      context = target_match.toJSONDecorated();
    context = _.extend(context, added_context)

    $("#content-modal").removeClass('profile-header')

    switch modal_type
      when "profile"
        source   = $(".match-pool-profile-modal-template").html();
        template = Handlebars.compile(source);
        html    = template(context);
        $("#content-modal").removeClass('profile-header').addClass('profile-header')
      when "contact-info"
        source   = $(".match-pool-contact-info-modal-template").html();
        template = Handlebars.compile(source);
        html    = template(context);
        $("#content-modal").removeClass('profile-header').addClass('profile-header')
      when "hire"
        source   = $(".match-pool-hire-modal-template").html();
        template = Handlebars.compile(source);
        html    = template(context);
        header_title = "Offer Details"
      when "prescreen-questions"
        header_title = "PRESCREEN QUESTIONS"
        source   = $(".match-pool-prescreen-questions-modal-template").html();
        template = Handlebars.compile(source);
        html    = template(context);
      when "confirm"
        source   = $(".match-pool-confirm-modal-template").html();
        template = Handlebars.compile(source);
        html    = template(context);
      when "export"
        source   = $(".match-pool-export-modal-template").html();
        template = Handlebars.compile(source);
        html    = template(context);
        header_title = "EXPORT"

        jqxhr = $.ajax({
          type: "POST",
          url: '/company/showprompt',
          cache: false,
          data: {
            admin_id: match_container.attr('data-admin-id'),
            prompt_action: match_container.attr('data-action')
          },
        }).done( (data) ->
          if data["response"] == "success"
            $("#match-cards-container").removeClass('show-prompts')
          else
            window.console.log("Request failed." + data.message);
        ).fail( (data) ->
          window.console.log("Request failed.");
        );

      when "introduction"
        header_title = "Congratulations!"
        source   = $(".match-pool-introduction-modal-template").html();
        template = Handlebars.compile(source);
        html    = template(context);

      else
        data_valid = false

    if data_valid
      modal_body_element = $("#content-modal .modal-body")
      $("#content-modal .modal-header-content").text(header_title)
      modal_body_element.html(html)
      APP.buildComponents(modal_body_element);

      if APP.trim(header_title) == ''
        $("#content-modal").removeClass('hidden-header').addClass('hidden-header')
      else
        $("#content-modal").removeClass('hidden-header')

      $("#content-modal").modal("show");


  if APP.URLParameter('filter')
    $('#match-cards-container').removeClass('only-new only-pending only-mutual-interest')
    $('.filter-list-arrows li').removeClass('selected')
    switch APP.URLParameter('filter')
      when 'matches'
        $('#match-cards-container').addClass('only-new')
        $('.filter-list-arrows a[href=new]').parent().addClass('selected')
      when 'awaiting_reply'
        $('#match-cards-container').addClass('only-pending')
        $('.filter-list-arrows a[href=pending]').parent().addClass('selected')
      when 'intro_required'
        $('#match-cards-container').addClass('only-mutual-interest')
        $('.filter-list-arrows a[href=mutual-interest]').parent().addClass('selected')
      when 'intro_sent'
        $('#match-cards-container').addClass('only-intro-sent')
        $('.filter-list-arrows a[href=intro-sent]').parent().addClass('selected')
      when 'all'
        $('.filter-list-arrows a[href=all]').parent().addClass('selected')


  APP.onCardListChange = () ->

  APP.updateEmptyListMessage = () ->
    count = 0
    selection = 'all'
    cards_container = $('#match-cards-container')
    if cards_container.hasClass('only-new')
      selection = 'new'
    else if cards_container.hasClass('only-pending')
      selection = 'pending'
    else if cards_container.hasClass('only-mutual-interest')
      selection = 'mutual interest'
    else if cards_container.hasClass('only-intro-sent')
      selection = 'intro sent'

    total_count = $('.status-new').length + $('.status-pending').length + $('.status-mutual-interest').length + $('.status-hired').length + $('.status-moved-to-ats').length + $('.status-intro-sent').length

    switch selection
      when 'new'
        count = $('.status-new').length
        #count = APP.pageData.match_counts.matches
      when 'pending'
        count = $('.status-pending').length
      when 'mutual interest'
        count = $('.status-mutual-interest').length
      when 'intro sent'
        count = $('.status-intro-sent').length
      else
        count = total_count

    if count <= 0
      label = ""
      switch selection
        when 'new'
          message = "We are working hard to find you matches. We will notify you of new matches."
        when 'pending'
          message = "There are no <span class=\"selection\">\"Awaiting Reply\"</span> matches for this job."
        when 'mutual interest'
          message = "There are no <span class=\"selection\">\"Intro Required\"</span> matches for this job."
        when 'intro sent'
          message = "There are no <span class=\"selection\">\"Intro Sent\"</span> matches for this job."
        else
          message = "We are working hard to find you matches. We will notify you of new matches."

      $('.empty-list-message').html(message)
      $('.empty-list-container').show()

    else
      $('.empty-list-container').hide()


    if count == 1
      switch selection
        when 'new'
          $('#match-counter').text(count + ' Match');
        when 'pending'
          $('#match-counter').text(count + ' Awaiting Reply');
        when 'mutual interest'
          $('#match-counter').text(count + ' Intro Required');
        when 'intro sent'
          $('#match-counter').text(count + ' Intro Sent');
        else
          $('#match-counter').text(count + ' Match');
    else
      switch selection
        when 'new'
          $('#match-counter').text(count + ' Matches');
        when 'pending'
          $('#match-counter').text(count + ' Awaiting Reply');
        when 'mutual interest'
          $('#match-counter').text(count + ' Intro Required');
        when 'intro sent'
          $('#match-counter').text(count + ' Intro Sent');
        else
          $('#match-counter').text(count + ' Matches');



  #load/format card data
  APP.matchList = new APP.MatchCollection([],{});

  APP.renderMatches = (rebuild_components = 1) ->
    #close zombie popovers
    $('#match-cards-container [data-toggle=popover]').each (index) ->
      $(this).popover('hide');

    $("#match-cards-container").empty()
    for match_data in APP.pageData.matches
      APP.updateMatch(match_data.id, match_data, false)

    if APP.pageData.matches.length <= 0
      APP.updateEmptyListMessage()


    #APP.matchListView = new APP.MatchListView({model:APP.matchList, viewType: "open", el: $("#match-cards-container")});
    #APP.matchListView.render();
    #APP.updateEmptyListMessage()
    #if rebuild_components
    #  APP.buildComponents($('#match-cards-container'))

  APP.updateMatch = (match_id, updated_data, use_loader) ->
    target_match_element = $('.card-wrapper[data-id="' + match_id + '"]')
    target_match = APP.matchList.get(match_id)
    if target_match_element.length > 0 && target_match?
      target_match_element.removeClass('fadeIn')
      previous_co_status_integer = parseInt(target_match.get('co_status_integer'))
      previous_dev_status_integer = parseInt(target_match.get('dev_status_integer'))
      target_match.set(updated_data);
      setTimeout( ->
        previously_not_mutual = previous_co_status_integer in [0] || previous_dev_status_integer in [0,1]
        now_mutual = parseInt(target_match.get('co_status_integer')) in [1] && parseInt(target_match.get('dev_status_integer')) in [2]

        target_match_element.remove()
        if parseInt(target_match.get('dev_status_integer')) in [1,2] || parseInt(target_match.get('co_status_integer')) in [1]
          $('#match-cards-container').prepend(new APP.MatchView({model:target_match}).render().el);
        else
          $('#match-cards-container').append(new APP.MatchView({model:target_match}).render().el);
        APP.updateEmptyListMessage()
        target_match_element = $('.card-wrapper[data-id="' + match_id + '"]')
        if target_match_element.length > 0
          APP.buildComponents(target_match_element)
          setTimeout( ->
            target_match_element.removeClass('fadeIn').addClass('fadeIn')
            #if previously_not_mutual && now_mutual
            #  APP.showMatchPoolModal('introduction',match_id)
          ,100);


        APP.updateEmptyListMessage()

      ,500);

    else
      APP.createMatch(updated_data, use_loader)

  APP.createMatch = (new_data, use_loader) ->
    target_match = new APP.Match(new_data)
    APP.matchList.add(target_match)
    if parseInt(target_match.get('dev_status_integer')) in [1,2] || parseInt(target_match.get('co_status_integer')) in [1]
      $('#match-cards-container').prepend(new APP.MatchView({model:target_match}).render().el);
    else
      $('#match-cards-container').append(new APP.MatchView({model:target_match}).render().el);
    APP.updateEmptyListMessage()
    if new_data.id?
      target_match_element = $('.card-wrapper[data-id="' + new_data.id + '"]')
      if target_match_element.length > 0
        APP.buildComponents(target_match_element)
        setTimeout( ->
          if use_loader
            target_match_element.find('.updating').text('Loading')
            target_match_element.removeClass('status-updating').addClass('status-updating')

          target_match_element.removeClass('fadeIn').addClass('fadeIn')

          if use_loader
            setTimeout( ->
              target_match_element.removeClass('status-updating')
              target_match_element.find('.updating').text('Updating')
            ,2000);

        ,100);

    APP.updateEmptyListMessage()

  APP.renderMatches(0)

  if APP.URLParameter('id') && APP.URLParameter('msg')
    target_match = APP.matchList.get(APP.URLParameter('id'))
    if target_match?
      switch parseInt(APP.URLParameter('msg'))
        when 1
          if parseInt(target_match.get('dev_status_integer')) in [2]
            APP.showPageAlert(1,'You have expressed interest in <b><a href="/match/' + target_match.get('id') + '">' + target_match.get('name') + '</a></b>. There is a mutual interest and they have been moved to Intro Required.', '',0);
          else
            APP.showPageAlert(1,'You have expressed interest in <b><a href="/match/' + target_match.get('id') + '">' + target_match.get('name') + '</a></b> and they have been moved to Awaiting Reply.', '',0);
        when 9
          APP.showPageAlert(3,'You have indicated you are not interested in <b><a href="/match/' + target_match.get('id') + '">' + target_match.get('name') + '</a></b>.', '',0);
    else if parseInt(APP.URLParameter('msg')) == 9 && APP.URLParameter('candidate_name')
      APP.showPageAlert(3,'You have indicated you are not interested in <b>' + APP.URLParameter('candidate_name') + '</b>.', '',0);

  else if parseInt(APP.URLParameter('msg')) == 2
    APP.showPageAlert(1,'Your message has been posted.', '',0);

  else if APP.URLParameter('id') && APP.URLParameter('modal')
    target_match = APP.matchList.get(APP.URLParameter('id'))
    if target_match?
      switch APP.URLParameter('modal')
        when "intro"
          if parseInt(target_match.get('co_status_integer')) in [1] && parseInt(target_match.get('dev_status_integer')) in [2]
            filter_list_element = $('.filter-list-arrows')
            filter_list_element.find('li').removeClass('selected')
            filter_list_element.find('a[href="mutual-interest"]').parent().removeClass('selected').addClass('selected')
            $('#match-cards-container').removeClass('only-new only-pending only-mutual-interest only-intro-sent').addClass('only-mutual-interest')
            APP.updateEmptyListMessage()
            APP.showMatchPoolModal('introduction',APP.URLParameter('id'))


  #websockets
  APP.PusherNotifier = (channel) ->

    self = this;
    channel.bind('match_update', (data) ->
      self._handleMatchUpdate(data)
    );

    channel.bind('job_match_count_update', (data) ->
      self._handleJobMatchCountUpdate(data)
    );

    channel.bind('matches_complete', (data) ->
      self._handleMatchesComplete(data)
    );

  APP.PusherNotifier.prototype._handleMatchUpdate = (data) ->
    if data.message? && APP.trim(data.message) != ''
      APP.showPageAlert(1,data.message, '',1);

    if data.data? && data.data.match? && data.data.match.id? && data.data.match.job_id?
      if data.data.match.job_id == APP.pageData.job.id
        APP.updateMatch(data.data.match.id, data.data.match, true)

    if data.data? && data.data.match_counts?
      APP.pageData.match_counts = data.data.match_counts
      APP.updateEmptyListMessage()

    #window.console.log(data)

  APP.PusherNotifier.prototype._handleJobMatchCountUpdate = (data) ->
    if data.message? && APP.trim(data.message) != ''
      APP.showPageAlert(1,data.message, '',1);

    if data.data? && data.data.match_counts? && data.data.job_id?
      if data.data.job_id == APP.pageData.job.id
        APP.pageData.match_counts = data.data.match_counts
        APP.updateEmptyListMessage()

    #window.console.log(data)

  APP.PusherNotifier.prototype._handleMatchesComplete = (data) ->
    if data.data? && data.data.active_match_ids? && data.data.job_id?
      if data.data.job_id == APP.pageData.job.id
        missing_match_ids = []
        for match_id in data.data.active_match_ids
          target_match = APP.matchList.get(match_id)
          unless target_match?
            missing_match_ids.push(match_id)
          else
            window.console.log('found' + match_id)

        if missing_match_ids.length > 0

          jqxhr = $.ajax({
            type: "POST",
            url: '/matches',
            data: {
              match_ids: missing_match_ids
            },
            cache: false
          }).done((data) ->
            window.console.log(data);
            if data["response"] == "success"
              for match in data.data
                if match.job_id == APP.pageData.job.id
                  APP.updateMatch(match.id, match, true)
              APP.showPageAlert(1,'New matches loaded', '',1);
            else
              window.console.log("there was an error");
              #APP.showPageAlert(4,data.message, '',1);
          ).fail((data) ->
            window.console.log("Request failed.");
            APP.showPageAlert(4,'An Error Occurred', '',1);
          );

        else
          APP.showPageAlert(1,'New matches loaded', '',1);



    #window.console.log(data)


  if APP.webSockets.channel?
    APP.webSockets.notifier = new APP.PusherNotifier(APP.webSockets.channel);



  APP.buildAdditionalComponents = (container_obj) ->
    container_obj.find('.filter-list-arrows a').click (e) ->
      e.preventDefault();
      e.stopPropagation();
      filter_list_element = $(this).parents('.filter-list-arrows')
      filter_list_element.find('li').removeClass('selected')
      $(this).parent().removeClass('selected').addClass('selected')
      selection = $(this).attr('href')
      if selection == 'all'
        $('#match-cards-container').removeClass('only-new only-pending only-mutual-interest only-intro-sent')
      else
        $('#match-cards-container').removeClass('only-new only-pending only-mutual-interest only-intro-sent').addClass('only-' + selection)
      APP.updateEmptyListMessage()

    container_obj.find('.circle-graph-path').each((index) ->
      APP.drawStaticCircle($(this),index)
    )

    container_obj.find('form').each (index) ->
      client = new ZeroClipboard( $(this).find('.button-copy'), {
          moviePath: "swf/ZeroClipboard.swf",
          debug: false
      });

    #container_obj.find('.img-container').click (e) ->
    #  e.preventDefault()
    #  e.stopPropagation();
    #  card_container = $(this).parents('.card-wrapper')
    #  card_container.find('.card-skills-content').toggleClass('active')
    #  $('.card-wrapper').removeClass('in-focus')
    #  if card_container.find('.card-skills-content').hasClass('active')
    #    $('#focus-bg').show()
    #    card_container.addClass('in-focus')
    #  else
    #    $('#focus-bg').hide()

    container_obj.find('.button-export').click (e) ->
      e.preventDefault();
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      added_context = {}

      target_match = APP.matchList.get(match_id)
      unless target_match.get('show_export_authorize')
        $.ajax({
          async: false,
          type: "GET",
          url: '/match/' + match_id + '/export',
          success: (data) ->
            window.console.log(data)
            added_context = {
              ats_enabled: data.data.ats_enabled,
              ats_provider: data.data.ats_provider,
              ats_jobs: data.data.jobs
            }
          ,
          error: (xhr, ajaxOptions, thrownError) ->
            window.console.log('cleanup error')
          ,
          dataType: "json"
          })


      APP.showMatchPoolModal('export',match_id,added_context)

    container_obj.find('.button-do-confirm').click (e) ->
      e.preventDefault();
      e.stopPropagation();
      match_id = $(this).attr('data-match-id')
      action = $(this).attr('data-action')
      switch action
        when "not-interested"
          APP.markAsNotInterested(match_id)

    container_obj.find('.button-interested').click (e) ->
      e.preventDefault();
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      APP.markAsInterested(match_id)

    container_obj.find('.button-not-interested-prompt').click (e) ->
      e.preventDefault();
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      if $("#match-cards-container").hasClass('show-prompts')
        APP.showMatchPoolModal("confirm",match_id,{
          message: "Please confirm you are not interested in this candidate. We will remove them from your matches.",
          action: "not-interested"
        })
      else
        APP.markAsNotInterested(match_id)

    container_obj.find('.button-not-interested').click (e) ->
      e.preventDefault();
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      APP.markAsNotInterested(match_id)

    container_obj.find('.button-send-later').click (e) ->
      e.preventDefault();
      e.stopPropagation();
      APP.hideContentModal();
      match_id = $("form#form-introduction").find('input[name=id]').val()
      target_match = APP.matchList.get(match_id)
      APP.showPageAlert(1,'<b>' + target_match.get('name') + '</b> is in Intro Required.', '',1);


    container_obj.find('.trigger-profile').click (e) ->
      e.preventDefault()
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      APP.showMatchPoolModal('profile',match_id)

    container_obj.find('.button-contact-info').click (e) ->
      e.preventDefault()
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      APP.showMatchPoolModal('contact-info',match_id)

    container_obj.find('.button-prescreen-questions').click (e) ->
      e.preventDefault()
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      APP.showMatchPoolModal('prescreen-questions',match_id)

    container_obj.find('.button-send-intro').click (e) ->
      e.preventDefault()
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      APP.showMatchPoolModal('introduction',match_id)


    container_obj.find('.button-move-to-ats').click (e) ->
      e.preventDefault()
      e.stopPropagation();
      match_id = card_container.attr('data-id')
      APP.moveToATS(match_id)

    container_obj.find('.button-hired').click (e) ->
      e.preventDefault()
      e.stopPropagation();
      card_container = $(this).parents('.card-wrapper')
      match_id = card_container.attr('data-id')
      APP.showMatchPoolModal('hire',match_id)

    container_obj.find('.button-save-offer').each () ->
      $(this).click (e) ->
        e.preventDefault();
        e.stopPropagation();
        button_element = $(this)
        form_element = container_obj.find('#form-make-offer, #form-accept-offer')
        if APP.validateForm(form_element)
          $('#content-modal').modal('hide')
          match_id = form_element.find('input[name=id]').val()
          card_container = $('.card-wrapper[data-id=' + match_id + ']')
          card_container.removeClass('status-updating').addClass('status-updating')

          APP.updateMatch(match_id,{"status_integer":100},false)
          #target_match = APP.matchList.get(match_id)
          #target_match.set({"status_integer":100});
          #APP.renderMatches()
          APP.showPageAlert(1,'Congratulations. Offer details saved. Candidate has been successfully indicated as hired', '',1);


    container_obj.find("form#form-introduction").unbind('onSuccess')
    container_obj.find("form#form-introduction").bind('onSuccess', (data) ->
      match_id = $("form#form-introduction").find('input[name=id]').val()
      target_match = APP.matchList.get(match_id)
      APP.updateMatch(match_id,{"status_integer":2},false)
      $('#content-modal').modal('hide')
      APP.showPageAlert(1,'Your introduction to <b>' + target_match.get('name') + '</b> was sent.', '',1);
    );

    container_obj.find("form#form-accept-offer").unbind('onSuccess')
    container_obj.find("form#form-accept-offer").bind('onSuccess', (data) ->
      $('#content-modal').modal('hide')
      form_element = $(this)
      match_id = form_element.find('input[name=id]').val()

      APP.updateMatch(match_id,{"status_integer":100},false)
      #target_match = APP.matchList.get(match_id)
      #target_match.set({"status_integer":100});
      #APP.renderMatches()
      APP.showPageAlert(1,'Congratulations. The candidate has been marked as hired.', '',1);
      form_element.find('input[type=submit]').button('reset');

    )

    container_obj.find("form#form-export").unbind('onSuccess')
    container_obj.find("form#form-export").bind('onSuccess', (data) ->
      APP.showSuccessModal({
        message: "Your candidate has been successfully exported."
      })

    )

    container_obj.on('click', (e) ->
        found_element = false
        $('.card-wrapper').each (index) ->
            if !$(this).is(e.target) && $(this).has(e.target).length is 0
              $(this).removeClass('in-focus')
              $(this).find('.card-skills-content').removeClass('active')
            else
              found_element = true

        unless found_element
          $('#focus-bg').hide()


    );



  APP.onCardListChange()

  APP.moveToATS = (match_id) ->
    card_container = $('.card-wrapper[data-id=' + match_id + ']')
    target_match = APP.matchList.get(match_id)
    if target_match.get('status_integer') < 3
      APP.showPageAlert(3,'In order to move a candidate to app tracking there must be mutual interest. As soon as the candidate expresses interest we will let you know and you can move them to app tracking!', '',0);
      APP.closeAllPopovers()
      return

    $.ajax({
      async: true,
      type: "GET",
      url: '/meeting/setup/' + match_id + '/0/0',
      success: (data) ->
        card_container.removeClass('status-updating').addClass('status-updating')
        setTimeout( ->
          APP.updateMatch(match_id,{"status":"interview_pending","status_integer":4},false)
          #target_match.set({"status":"interview_pending","status_integer":4});
          #APP.renderMatches()
          APP.showPageAlert(1,'Candidate has been moved to app tracking.', '',1);

        ,2000);
      ,
      error: (xhr, ajaxOptions, thrownError) ->
        window.console.log('cleanup error')
      ,
      dataType: "json"
      })


  APP.markAsInterested = (match_id) ->
    $('#content-modal').modal('hide')
    card_container = $('.card-wrapper[data-id=' + match_id + ']')
    card_container.removeClass('status-updating').addClass('status-updating')
    if true
      jqxhr = $.ajax({
        type: "POST",
        url: '/match/' + match_id + '/interest/1',
        cache: false
      }).done((data) ->
        window.console.log(data);
        if data["response"] == "success"
          #card_container.removeClass('is-liked').addClass('is-liked')
          setTimeout( ->
            APP.updateMatch(match_id,{"status_integer":1, "co_status_integer":1},false)
            target_match = APP.matchList.get(match_id)
            #target_match.set({"status_integer":1});
            #APP.renderMatches()
            unless parseInt(target_match.get('dev_status_integer')) in [1,2]
              APP.showPageAlert(1,'You have expressed interest in <b>' + target_match.get('name') + '</b> and they have been moved to Awaiting Reply.', '',1);
              APP.updateEmptyListMessage()
            else
              APP.showMatchPoolModal('introduction',match_id)

            APP.updateMatchQueue();

          ,2000);
        else
          window.console.log("there was an error");
          APP.showPageAlert(4,data.message, '',1);
          card_container.removeClass('status-updating')
      ).fail((data) ->
        window.console.log("Request failed.");
        APP.showPageAlert(4,'An Error Occurred', '',1);
        card_container.removeClass('status-updating')
      );

  APP.undoNotInterested = (match_id) ->
    target_match = APP.matchList.get(match_id)
    revert_status_integer = target_match.get('previous_status_integer')
    if true
      jqxhr = $.ajax({
        type: "POST",
        url: '/match/' + match_id + '/interest/' + revert_status_integer,
        cache: false
      }).done((data) ->
        if data["response"] == "success"
          APP.updateMatch(match_id,{"status_integer":revert_status_integer},false)
          #target_match.set({"status_integer":revert_status_integer});
          #APP.renderMatches()
          APP.showPageAlert(1,'Candidate has been added back to matches.', '',1);
        else
          window.console.log("there was an error");
          APP.showPageAlert(4,data.message, '',1);
      ).fail((data) ->
        window.console.log("Request failed.");
        APP.showPageAlert(4,'An Error Occurred', '',1);
      );


  APP.markAsNotInterested = (match_id) ->
    $('#content-modal').modal('hide')
    card_container = $('.card-wrapper[data-id=' + match_id + ']')
    card_container.removeClass('status-updating').addClass('status-updating')
    if true
      jqxhr = $.ajax({
        type: "POST",
        url: '/match/' + match_id + '/interest/9',
        cache: false
      }).done((data) ->
        if data["response"] == "success"
          setTimeout( ->
            target_match = APP.matchList.get(match_id)
            previous_status_integer = target_match.get('status_integer')
            APP.updateMatch(match_id,{
              status_integer: 9,
              previous_status_integer: previous_status_integer,
              co_status_integer: 9
            },false)
            #target_match.set({
            #  status_integer: 9,
            #  previous_status_integer: previous_status_integer
            #});
            #APP.renderMatches()
            #APP.showPageAlert(4,'Candidate has been deleted. <a href="#" onclick="APP.undoNotInterested(\'' + match_id + '\'); return false">Undo</a>', '',1);
            APP.showPageAlert(4,'You have indicated you are not interested in <b>' + target_match.get('name') + '</b>.', '',1);

            APP.updateEmptyListMessage()

            APP.updateMatchQueue();

          ,2000);
        else
          window.console.log("there was an error");
          APP.showPageAlert(4,data.message, '',1);
          card_container.removeClass('status-updating')
      ).fail((data) ->
        window.console.log("Request failed.");
        APP.showPageAlert(4,'An Error Occurred', '',1);
        card_container.removeClass('status-updating')
      );

  APP.updateMatchQueue = () ->
    jqxhr = $.ajax({
      type: "GET",
      url: '/company/matches/queue/' + APP.pageData.job.id,
      cache: false
    }).done((data) ->
      if data["response"] == "success"
        if data.data.id? && data.data?
          APP.updateMatch(data.data.id, data.data, false)
      else
        window.console.log("there was an error");
        APP.showPageAlert(4,data.message, '',1);
    ).fail((data) ->
      window.console.log("Request failed.");
      APP.showPageAlert(4,'An Error Occurred', '',1);
    );
