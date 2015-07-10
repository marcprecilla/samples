# Models
APP.DashboardCard = Backbone.Model.extend({
  url : "/company/dashboard",
  urlRoot : "/company/dashboard",
  defaults : {
    id : null,
    status: null,
    name : null,
    title : null,
    company: null,
    profile_img_url: '/img/profile.blank.jpg',
    skills: [],
    interest_status: '',
    not_interested_reason: '',
    offer_meeting: null,
    offer_salary: null,
    offer_equity: null,
    offer_benefits: null,
    offer_relocation_amount: null
  },
  toJSONDecorated: ->

    top_skills = _(this.get('skills')).sortBy( (skill) ->
        return skill.weight;
    ).reverse().slice(0, 3);

    num_nonlisted_skills = 0
    if this.get('skills').length > 3
      num_nonlisted_skills = this.get('skills').length - 3

    new_attributes = {
      num_skills: this.get('skills').length,
      top_skills: top_skills,
      num_nonlisted_skills: num_nonlisted_skills,
      job_profile_url: "/match/53cf0e43892e1b6096000001/full"
    }

    if APP.trim(this.get('profile_img_url')) == ''
      new_attributes.profile_img_url = '/img/profile.blank.jpg'

    return _.extend(this.toJSON(),new_attributes);
});

APP.Match = Backbone.Model.extend({
  url : "/match",
  urlRoot : "/match",
  defaults : {
    id : null,
    status: null,
    name : null,
    title : null,
    company: null,
    profile_img_url: '/img/profile.blank.jpg',
    company_img_url: 'https://s3.amazonaws.com/app/email/img/company_profile_default.png',
    skills: [],
    interest_status: '',
    not_interested_reason: '',
    offer_meeting: null,
    offer_salary: null,
    offer_equity: null,
    offer_benefits: null,
    offer_relocation_amount: null,
    state_change_date: 'Oct. 22, 2014',
    status_integer: 0,
    dev_status_integer: 0,
    co_status_integer: 0,
    previous_status_integer: 0
  },
  toJSONDecorated: ->

    top_skills = _(this.get('skills')).sortBy( (skill) ->
        return skill.weight;
    ).reverse().slice(0, 3);

    num_nonlisted_skills = 0
    if this.get('skills').length > 3
      num_nonlisted_skills = this.get('skills').length - 3

    new_attributes = {
      previous__status_integer: this.get('status_integer'),
      num_skills: this.get('skills').length,
      top_skills: top_skills,
      num_nonlisted_skills: num_nonlisted_skills,
      job_profile_url: "/match/53cf0e43892e1b6096000001/full",
      developer_interested: false,
      show_intro: false,
      show_export: false,
      show_export_authorize: true,
      score_pos: {x:0,y:0}
    }

    if APP.trim(this.get('profile_img_url')) == ''
      new_attributes.profile_img_url = '/img/profile.blank.jpg'

    if APP.trim(this.get('company_img_url')) == ''
      new_attributes.company_img_url = 'https://s3.amazonaws.com/app/email/img/company_profile_default.png'


    switch parseInt(this.get('status_integer'))
      when 0
        new_attributes.match_pool_label = 'New'
      when 1
        new_attributes.match_pool_label = 'Awaiting Reply'
      when 2
        new_attributes.match_pool_label = 'Intro Sent'
      when 3
        new_attributes.match_pool_label = 'Mutual Interest'
      when 4,5,6,7,8
        new_attributes.match_pool_label = 'Moved To Tracking'
      when 9
        new_attributes.match_pool_label = 'Not Interested'
      when 100
        new_attributes.match_pool_label = 'Hired'

    if parseInt(this.get('status_integer')) < 5 && parseInt(this.get('dev_status_integer')) == 2 && parseInt(this.get('co_status_integer')) == 1
        if parseInt(this.get('status_integer')) != 2
          new_attributes.show_intro = true
          new_attributes.match_pool_label = 'Intro Required'
        else
          new_attributes.match_pool_label = 'Intro Sent'
          new_attributes.show_export = true
          if APP.pageData.ats_provider?
            if APP.pageData.ats_provider == 'greenhouse'
              new_attributes.show_export_authorize = false
          if this.get('ats_exported')
            new_attributes.match_pool_label = 'Exported'

    #if developer answered questions and company has not acted
    if parseInt(this.get('dev_status_integer')) in [1,2] && parseInt(this.get('co_status_integer')) == 0
        new_attributes.match_pool_label = 'New - Developer Has Shown Interest'

    #developer interested
    if parseInt(this.get('dev_status_integer')) in [1,2]
        new_attributes.developer_interested = true

    #if developer not answered and company interested
    if parseInt(this.get('dev_status_integer')) in [0] && parseInt(this.get('co_status_integer')) == 1
      new_attributes.match_pool_label = 'Awaiting Reply'

    #developer not interested
    if parseInt(this.get('dev_status_integer')) in [90]
      if parseInt(this.get('co_status_integer')) in [0]
        new_attributes.match_pool_label = 'New'
      else if parseInt(this.get('co_status_integer')) in [1]
        new_attributes.match_pool_label = 'Awaiting Reply'

    new_attributes.score_pos = APP.calculateCirclePercentagePosition(130,-59,55,(parseInt(this.get('score')) / 100),40,40)

    switch this.get('primary_role')
      when 'software_engineer'
        new_attributes.primary_role_label = 'Software Engineer'
      when 'software_engineer_backend_developer'
        new_attributes.primary_role_label = 'Backend Developer'
      when 'software_engineer_frontend_developer'
        new_attributes.primary_role_label = 'Frontend Developer'
      when 'software_engineer_mobile_developer'
        new_attributes.primary_role_label = 'Mobile Developer'
      when 'data_scientist'
        new_attributes.primary_role_label = 'Data Scientist'
      when 'product_manager'
        new_attributes.primary_role_label = 'Product Manager'
      when 'ui_ux_designer'
        new_attributes.primary_role_label = 'UI/UX Designer'
      when 'other'
        new_attributes.primary_role_label = 'Other'

    return _.extend(this.toJSON(),new_attributes);
});

APP.Meeting = Backbone.Model.extend({
  url: "/meeting",
  urlRoot: "/meeting",
  defaults : {
    id: null,
    meeting_type: 'virtual',
    status: 0,
    date: null,
    time: null,
    start: null,
    end: null,
    interviewer: null,
    url: null,
    platform: null,
    developer_name : null,
    developer_title : null,
    developer_company: null,
    developer_profile_img_url: '/img/profile.blank.jpg',
    time_slots: [],
    rejected_time_slots: [],
    ics_link: null
  },
  toJSONDecorated: ->
    max_num_slots_available = 3
    num_slots_taken = 0

    meeting_day_of_week = ""
    meeting_date = ""
    meeting_month = ""
    meeting_time_label = ""
    details_missing = true
    send_invite_invalid = true

    if this.get('time_slots').length >= 1 && this.get('meeting_type')
      send_invite_invalid = false

    switch this.get('meeting_type')
      when "virtual"
        if this.get('url') && this.get('platform')
          details_missing = false
      when "in_person"
        if this.get('location')
          details_missing = false

    if this.get('start') && this.get('end')
      meeting_start_moment = $.fullCalendar.moment.utc(this.get('start'))
      meeting_end_moment = $.fullCalendar.moment.utc(this.get('end'))
      meeting_day_of_week = meeting_start_moment.format("dddd")
      meeting_date = meeting_start_moment.format("D")
      meeting_month = meeting_start_moment.format("MMMM")
      meeting_time_label = meeting_start_moment.format("h:mmA") + " - " + meeting_end_moment.format("h:mmA")


    shown_time_slots = []
    _.each(this.get('time_slots'), (time_slot) ->
      if time_slot.start && time_slot.end
        num_slots_taken++

        start_moment = $.fullCalendar.moment.utc(time_slot.start)
        end_moment = $.fullCalendar.moment.utc(time_slot.end)
        time_label = start_moment.format("ddd MMM D, h:mmA");

        shown_time_slot = {
          start: time_slot.start,
          end: time_slot.end,
          label: time_label,
          status: time_slot.status
        }

        shown_time_slots.push(shown_time_slot)
    )

    num_slots_available = max_num_slots_available - num_slots_taken
    if num_slots_available <= 0
      num_slots_available = 0
    else
      for i in [1..num_slots_available]
        shown_time_slots.push({start:null,end:null,label:null});

    meeting_type_label = "Virtual"
    if this.get('meeting_type') == 'in_person'
      meeting_type_label = "In Person"
    else
      this.set('meeting_type','virtual')

    new_attributes = {
      max_num_slots_available: max_num_slots_available,
      num_slots_available: num_slots_available,
      num_slots_taken: num_slots_taken,
      shown_time_slots: shown_time_slots,
      meeting_type_label: meeting_type_label,
      meeting_day_of_week: meeting_day_of_week,
      meeting_date: meeting_date,
      meeting_month: meeting_month,
      meeting_time_label: meeting_time_label,
      details_missing: details_missing,
      send_invite_invalid: send_invite_invalid
    }

    if APP.trim(this.get('developer_profile_img_url')) == ''
      new_attributes.developer_profile_img_url = '/img/profile.blank.jpg'

    return _.extend(this.toJSON(),new_attributes);
  ,
  reRenderTimeSlots: () ->
    time_slots = this.get('time_slots')
    rejected_time_slots = this.get('rejected_time_slots')
    meeting_id = this.get('id')
    for i in [0..5]
      event_id = meeting_id + "_" + i;
      $('#main-calendar').fullCalendar('removeEvents',[event_id]);
    slot_index = 0
    _.each(time_slots, (time_slot,index) ->
      event_id = meeting_id + "_" + slot_index
      APP.addEventToCalendar(meeting_id,event_id,time_slot.start,time_slot.end,time_slot.status)
      slot_index++
    )
    _.each(rejected_time_slots, (rejected_time_slot,index) ->
      event_id = meeting_id + "_" + slot_index
      APP.addEventToCalendar(meeting_id,event_id,rejected_time_slot.start,rejected_time_slot.end,rejected_time_slot.status)
      slot_index++
    )
    #$('.not-scheduled-card-container .meeting-card').not(".active").trigger("hide")

  ,
  highlightCalendarEvents: () ->
    $('.fc-day').removeClass('active')
    $('.not-scheduled-card-container .meeting-card').not(".active").trigger("hide")

    _.each(this.get('time_slots'), (time_slot) ->
      start_moment = $.fullCalendar.moment.utc(time_slot.start)
      date_id = start_moment.format("YYYY-MM-DD");
      $('.fc-day[data-date=' + date_id + ']').addClass('active')
    )

  ,getTimeSlotsForGivenDay: (date_string) ->
    matching_time_slots = []
    _.each(this.get('time_slots'), (time_slot) ->
      start_moment = $.fullCalendar.moment.utc(time_slot.start)
      end_moment = $.fullCalendar.moment.utc(time_slot.end)
      date_id = start_moment.format("YYYY-MM-DD");
      start_time = start_moment.format("h:mmA");
      end_time = end_moment.format("h:mmA");
      if date_string == date_id
        matching_time_slots.push({start_time: start_time, end_time: end_time})
    )
    return matching_time_slots

  ,getTimeSlotIndex: (start,end) ->
    target_index = -1
    _.find(time_slots,(time_slot,index) ->
      if (time_slot.start == start && time_slot.end == end)
        target_index = index
        return true
      else
        return false
    )
  ,removeTimeSlotsFromMeetingOnDay: (date_string) ->
    new_time_slots = []
    _.each(this.get('time_slots'), (time_slot) ->
      start_moment = $.fullCalendar.moment.utc(time_slot.start)
      date_id = start_moment.format("YYYY-MM-DD");
      if date_string != start_moment.format("YYYY-MM-DD")
        new_time_slots.push(time_slot)
      else
        #event_id = this.get('id') + "_" + timeslot_index;
        #$('#main-calendar').fullCalendar('removeEvents',[event_id]);

    )
    this.set('time_slots',new_time_slots)
  ,resetTimeSlots: () ->
    this.set('time_slots',[])
    this.set('invite_status','not_scheduled')


})


APP.DeveloperJobCard = Backbone.Model.extend({
  url : "/developer_job",
  urlRoot : "/developer_job",
  defaults : {
    id : null,
    position: null,
    company_name: null,
    company_img_url: 'https://s3.amazonaws.com/app/email/img/company_profile_default.png',
    company_website : '#',
    company_facebook : '#',
    company_linkedin : '#',
    company_twitter : '#',
    job_url : '#',
    status_integer : 0,
    meeting : {
      id: null,
      start : null,
      end : null,
      start_iso : null,
      end_iso : null,
      interviewer : null,
      url : null,
      meeting_type : null,
      platform: null,
      ics : null,
      location: null,
      follow_up: null
    },
    interview_available : false,
    offer_made : false,
    offer_salary : null,
    offer_equity : null,
    offer_benefits : null,
    offer_relocation_amount : null
  },
  toJSONDecorated: ->

    button_html = ""
    progress_label = ""
    show_completion_bar = 1
    show_button_stage = 0
    show_intro_button_stage = 0
    label_html = ""
    response_subject = encodeURIComponent('Re: ' + this.get('admin_name') + ' at ' + this.get('company_name') + ' sent you a message');
    response_message = encodeURIComponent('\r\r--Reply Above--\r\r' + this.get('intro_message'))

    meeting = this.get('meeting')

    meeting_url = "/developer/meeting/" + meeting.id
    open_in_new_window = false
    if meeting.meeting_type == 'virtual'
      if meeting.platform != 'app' && meeting.url?
        meeting_url = meeting.url
        open_in_new_window = true
        if meeting_url.indexOf('http://') < 0 && meeting_url.indexOf('https://') < 0
          meeting_url = 'http://' + meeting_url
          meeting.url = meeting_url

    if parseInt(this.get('status_integer')) < 5 && parseInt(this.get('dev_status_integer')) == 2 && parseInt(this.get('co_status_integer')) == 1
      if parseInt(this.get('status_integer')) in [2]
        show_intro_button_stage = 1
      this.set({'status_integer': 4})

    #if developer answered questions and company has not acted
    if parseInt(this.get('dev_status_integer')) in [1,2] && parseInt(this.get('co_status_integer')) == 0
      this.set({'status_integer': 3})

    #if developer not acted and company has shown interested
    if parseInt(this.get('dev_status_integer')) in [0] && parseInt(this.get('co_status_integer')) in [1]
      this.set({'status_integer': 1})

    switch parseInt(this.get('status_integer'))
      when 0
        progress_label = "Review job to get started"
        button_html = "<a class=\"button-1 block cyan button-review-job\" href=\"" + this.get('job_url') + "\">REVIEW JOB</a>"
        label_html = "<label class=\"black\">New Match</label>"
        show_button_stage = 1
      when 1
        progress_label = "Review job to get started"
        button_html = "<a class=\"button-1 block cyan button-review-job\" href=\"" + this.get('job_url') + "\">REVIEW JOB</a>"
        if APP.trim(this.get('expiration_label')) != ''
          progress_label = "<span class=\"icon-expires\">" + this.get('expiration_label') + "</span>"
          show_completion_bar = 0

        label_html = "<label class=\"yellow\">Company Interested</label>"
        show_button_stage = 1

      when 2
        progress_label = "Expressed interest"
        button_html = "Awaiting Reply..."
        label_html = "<label class=\"black\">Awaiting Reply</label>"
        show_intro_button_stage = 1

      when 3
        progress_label = "Expressed interest"
        button_html = "Awaiting Reply..."
        label_html = "<label class=\"black\">Awaiting Reply</label>"
      when 4
        label_html = "<label class=\"green\">Mutual Interest</label>"

        if meeting.meeting_status == 1
          progress_label = "Interview Process"
          button_html = "<a href=\"/meeting/" + meeting.id + "/select\" class=\"button-1 block cyan\">SELECT DATE</a>"
        else if meeting.meeting_status >= 2
          progress_label = "Interview Process"
          button_html = "Awaiting Reply..."
        else if meeting.follow_up
          progress_label = "Interview Process"
          button_html = "Awaiting Reply..."
          this.set('bar_level',2)
        else
          progress_label = "Expressed interest"
          button_html = "Awaiting Reply..."
          this.set('bar_level',1)

      when 5
        label_html = "<label class=\"green\">Mutual Interest</label>"
        progress_label = "Interview Process"
        if meeting.meeting_status > 0
          if meeting.meeting_status >= 4 && meeting.meeting_type == 'virtual'
            button_html = "<div class=\"cols-2 padded-1\">\r<div class=\"left-column\"><a href=\"#\" class=\"button-1 block size-minus-1 gray no-side-padding button-view-interview-details\">VIEW DETAILS</a></div>\r"
            if open_in_new_window
              button_html += "<div class=\"right-column\"><a href=\"" + meeting_url + "\" class=\"button-1 block size-minus-1 cyan no-side-padding button-start-interview\" target=\"_new\">START INTERVIEW</a></div>\r</div>"
            else
              button_html += "<div class=\"right-column\"><a href=\"" + meeting_url + "\" class=\"button-1 block size-minus-1 cyan no-side-padding button-start-interview\">START INTERVIEW</a></div>\r</div>"
          else
            button_html = "<a href=\"#\" class=\"button-1 block size-minus-1 gray no-side-padding button-view-interview-details\">VIEW DETAILS</a>\r"

      when 6
        progress_label = "Interview Process"
        button_html = "Awaiting reply..."
        label_html = "<label class=\"green\">Mutual Interest</label>"
      when 7
        label_html = "<label class=\"green\">Mutual Interest</label>"
        progress_label = "Offer Process"
        #button_html = "<a class=\"button-1 block cyan button-view-offer\" href=\"#\">VIEW OFFER</a>"
        if meeting.id? && APP.trim(meeting.id) != '' && meeting.meeting_status == 1
          button_html = "<a href=\"/meeting/" + meeting.id + "/select\" class=\"button-1 block cyan\">SELECT DATE</a>"
        else if meeting.meeting_status == 2
          button_html = "Awaiting reply..."
        else
          button_html = "Awaiting offer..."
      when 8
        label_html = "<label class=\"green\">Mutual Interest</label>"
        progress_label = "Offer Process"
        if meeting.meeting_status > 0
          if meeting.meeting_status >= 5
            button_html = "Awaiting reply..."
          else if meeting.meeting_status == 4 && meeting.meeting_type == 'virtual'
            button_html = "<div class=\"cols-2 padded-1\">\r<div class=\"left-column\"><a href=\"#\" class=\"button-1 block size-minus-1 gray no-side-padding button-view-interview-details\">VIEW DETAILS</a></div>\r"
            if open_in_new_window
              button_html += "<div class=\"right-column\"><a href=\"" + meeting_url + "\" class=\"button-1 block size-minus-1 cyan no-side-padding button-start-interview\" target=\"_new\">START INTERVIEW</a></div>\r</div>"
            else
              button_html += "<div class=\"right-column\"><a href=\"" + meeting_url + "\" class=\"button-1 block size-minus-1 cyan no-side-padding button-start-interview\">START INTERVIEW</a></div>\r</div>"
          else
            button_html = "<a href=\"#\" class=\"button-1 block size-minus-1 gray no-side-padding button-view-interview-details\">VIEW DETAILS</a>\r"

      when 100
        label_html = "<label class=\"green\">Mutual Interest</label>"
        progress_label = "Offer Accepted"
        button_html = "You've been hired!"
        this.set('bar_level',4)


    #if dev interested
    if parseInt(this.get('dev_status_integer')) in [2]
      show_button_stage = 0

    #if company not interested
    if parseInt(this.get('dev_status_integer')) in [0] && parseInt(this.get('co_status_integer')) == 9
      label_html = "<label class=\"black\">New Match</label>"

    #if company not interested
    if parseInt(this.get('dev_status_integer')) in [1,2] && parseInt(this.get('co_status_integer')) == 9
      label_html = "<label class=\"black\">Awaiting Reply</label>"

    new_attributes = {
      progress_label : progress_label,
      button_html : button_html,
      show_completion_bar: show_completion_bar,
      show_button_stage: show_button_stage,
      show_intro_button_stage: show_intro_button_stage,
      label_html: label_html,
      response_subject: response_subject,
      response_message: response_message
    }

    if APP.trim(this.get('company_img_url')) == ''
      new_attributes.company_img_url = 'https://s3.amazonaws.com/app/email/img/company_profile_default.png'

    return _.extend(this.toJSON(),new_attributes);
});


APP.CompanyJobCard = Backbone.Model.extend({
  url : "/company/dashboard",
  urlRoot : "/company/dashboard",
  defaults : {
    id : null,
    status: null,
    title: null,
    matches: 0,
    max_matches: 1,
    open_positions: 0,
    filled_positions: 0,
    created: null,
    updated_at: null,
    updated_by: null,
    num_matches : null,
    public : false,
    public_url: null,
    expires_in: null,
    completed: {
      description: false,
      skills: false,
      education: false,
      benefits: false,
      can_publish: false
    }
  },
  toJSONDecorated: ->

    return _.extend(this.toJSON(),{

    });
});

#Collections
APP.MatchCollection = Backbone.Collection.extend({
    model:APP.Match,
    defaults : {},
    #url: APP.urlRoot + "json_examples/company_job_dashboard.json",
    url: () ->
      return APP.urlRoot + "company/dashboard/" + this.job_id + ".json"
    ,
    initialize: (models, options) ->
      this.job_id = options.job_id
    ,
    parse: (response) ->
      values = response;
      if values?
        for value, i in values
          currentValues = values[i];
          cardObject = new APP.Match(currentValues);
          this.push(cardObject);

      return this.models;
});

APP.DashboardCardCollection = Backbone.Collection.extend({
    model:APP.DashboardCard,
    defaults : {},
    #url: APP.urlRoot + "json_examples/company_job_dashboard.json",
    url: () ->
      return APP.urlRoot + "company/dashboard/" + this.job_id + ".json"
    ,
    initialize: (models, options) ->
      this.job_id = options.job_id
    ,
    parse: (response) ->
      values = response;
      if values?
        for value, i in values
          currentValues = values[i];
          cardObject = new APP.DashboardCard(currentValues);
          this.push(cardObject);

      return this.models;
});

APP.MeetingCollection = Backbone.Collection.extend({
    model:APP.Meeting,
    defaults: {},
    #url: APP.urlRoot + "json_examples/company_matches_calendar.json?12",
    url: APP.urlRoot + "company/calendar.json",
    parse: (response) ->
      values = response;
      window.console.log(response)
      if values?
        for value, i in values
          currentValues = values[i];
          meetingObject = new APP.Meeting(currentValues);
          this.push(meetingObject);

      return this.models;
});

APP.DeveloperJobCardCollection = Backbone.Collection.extend({
    model:APP.DeveloperJobCard,
    defaults : {},
    #url: APP.urlRoot + "json_examples/developer_dashboard.json",
    url: APP.urlRoot + "developer/home.json",
    parse: (response) ->
      values = response;
      window.console.log(values)
      if values?
        for value, i in values
          values[i]
          currentValues = values[i];
          cardObject = new APP.DeveloperJobCard(currentValues);
          this.push(cardObject);

      return this.models;
});

APP.CompanyJobCardCollection = Backbone.Collection.extend({
    model:APP.CompanyJobCard,
    defaults : {},
    #url: APP.urlRoot + "json_examples/developer_dashboard.json",
    url: APP.urlRoot + "developer/home.json",
    parse: (response) ->
      values = response;
      window.console.log(values)
      if values?
        for value, i in values
          values[i]
          currentValues = values[i];
          cardObject = new APP.CompanyJobCard(currentValues);
          this.push(cardObject);

      return this.models;
});

#Views
APP.MatchListView = Backbone.View.extend({

    tagName:'div',
    className:"card-container ui-sortable",
    statusFilter: 'none',

    initialize: (options) ->
        this.model.bind("reset", this.render, this);
        _.extend(this, _.pick(options, "statusFilter"));
    ,

    render: (eventName) ->
      for match in this.model.models

        valid_item = false;
        if this.statusFilter == 'none'
          valid_item = true
        else if this.statusFilter == match.attributes.status
          valid_item = true

        if valid_item
          $(this.el).append(new APP.MatchView({model:match}).render().el);
      return this;
});


APP.MatchView = Backbone.View.extend({

    tagName:"div",
    className: ->
      classes = "card-wrapper"
      switch parseInt(this.model.get('status_integer'))
        when 0
          classes += " status-new "
        when 1
          classes += " status-pending "
        when 2
          classes += " status-new "
        when 3
          classes += " status-mutual-interest "
        when 4,5,6,7,8
          classes += " status-moved-to-ats "
        when 9
          classes += " status-not-interested "
        when 100
          classes += " status-hired "

      #if developer not interested and company is interested
      if parseInt(this.model.get('dev_status_integer')) in [0] && parseInt(this.model.get('co_status_integer')) == 1
        classes = "card-wrapper status-pending "

      #if developer answered questions and company is interested
      if parseInt(this.model.get('dev_status_integer')) == 2 && parseInt(this.model.get('co_status_integer')) == 1
        if parseInt(this.model.get('status_integer')) == 2
          classes = "card-wrapper status-intro-sent "
        else
          classes = "card-wrapper status-mutual-interest "

      #developer not interested
      if parseInt(this.model.get('dev_status_integer')) in [90]
        if parseInt(this.model.get('co_status_integer')) in [0]
          classes = "card-wrapper status-new "
        else if parseInt(this.model.get('co_status_integer')) in [1]
          classes = "card-wrapper status-pending "

      return classes
    ,

    render: (eventName) ->
        this.$el.attr('data-id', this.model.get('id'));
        source   = $(".match-pool-card-template").html();
        template = Handlebars.compile(source);
        context = this.model.toJSONDecorated();
        html    = template(context);
        $(this.el).html(html);
        return this;

});

APP.DashboardCardListView = Backbone.View.extend({

    tagName:'div',
    className:"card-container ui-sortable",
    statusFilter: 'none',

    initialize: (options) ->
        this.model.bind("reset", this.render, this);
        _.extend(this, _.pick(options, "statusFilter"));
    ,

    render: (eventName) ->
      for dashboard_card in this.model.models

        valid_item = false;
        if this.statusFilter == 'none'
          valid_item = true
        else if this.statusFilter == dashboard_card.attributes.status
          valid_item = true

        if valid_item
          $(this.el).append(new APP.DashboardCardView({model:dashboard_card}).render().el);
      return this;
});


APP.DashboardCardView = Backbone.View.extend({

    tagName:"div",
    className:"card-wrapper",

    render: (eventName) ->
        this.$el.attr('data-id', this.model.get('id'));
        source   = $(".dashboard-card-template").html();
        template = Handlebars.compile(source);
        context = this.model.toJSONDecorated();
        html    = template(context);
        $(this.el).html(html);
        return this;

});

APP.MeetingCardListView = Backbone.View.extend({

    tagName:'div',
    className:"meetings-container",
    statusFilter: 'none',
    numItems: ->
      num_items = 0
      for meeting in this.model.models

        valid_item = false;
        switch this.statusFilter
          when "not_scheduled"
            if meeting.get('invite_status') == 'not_scheduled'
              valid_item = true;
          when "invite_sent"
            if meeting.get('invite_status') == 'invite_sent'
              valid_item = true;
          else
            valid_item = true;

        if valid_item
          num_items++
      return num_items;

    ,

    initialize: (options) ->
        this.model.bind("reset", this.render, this);
        _.extend(this, _.pick(options, "statusFilter"));
    ,

    render: (eventName) ->
      for meeting in this.model.models

        valid_item = false;
        switch this.statusFilter
          when "not_scheduled"
            if meeting.get('invite_status') == 'not_scheduled'
              valid_item = true;
          when "invite_sent"
            if meeting.get('invite_status') == 'invite_sent'
              valid_item = true;
          else
            valid_item = true;

        if valid_item
          view = new APP.MeetingCardView({model:meeting});
          $(this.el).append(view.render().el);
      return this;
});


APP.MeetingCardView = Backbone.View.extend({

    tagName:"div",
    className:"meeting-card",

    render: (eventName) ->
        this.$el.attr('data-id', this.model.get('id'));
        source   = $(".meeting-card-template").html();
        template = Handlebars.compile(source);
        context = this.model.toJSONDecorated();
        html    = template(context);
        $(this.el).html(html);
        return this;

});

APP.DeveloperDashboardCardListView = Backbone.View.extend({

    tagName:'ul',
    className:"card-list clearfix",
    statusFilter: 'none',

    initialize: (options) ->
        this.model.bind("reset", this.render, this);
        _.extend(this, _.pick(options, "statusFilter"));
    ,

    render: (eventName) ->
      for dashboard_card in this.model.models

        valid_item = true;

        if valid_item
          $(this.el).append(new APP.DeveloperDashboardCardView({model:dashboard_card}).render().el);
      return this;
});


APP.DeveloperDashboardCardView = Backbone.View.extend({

    tagName:"li",
    className: ->
      classes = "card"
      switch parseInt(this.model.get('status_integer'))
        when 0
          classes += " status-new "
        when 1
          classes += " status-pending "
        when 2
          classes += " status-new "
        when 3
          classes += " status-mutual-interest "
        when 4,5,6,7,8
          classes += " status-moved-to-ats "
        when 9,90
          classes += " status-not-interested "
        when 100
          classes += " status-hired "

      #if developer answered questions and company is interested
      if parseInt(this.model.get('dev_status_integer')) == 2 && parseInt(this.model.get('co_status_integer')) == 1
        classes = "card status-mutual-interest "

      #if developer answered questions and company has not acted
      if parseInt(this.model.get('dev_status_integer')) in [1,2] && parseInt(this.model.get('co_status_integer')) == 0
        classes = "card status-pending "

      #if developer answered questions and company has not acted
      if parseInt(this.model.get('dev_status_integer')) in [90]
        classes = "card status-not-interested "

      #if developer has not acted
      if parseInt(this.model.get('dev_status_integer')) in [0] && parseInt(this.model.get('co_status_integer')) in [1]
        classes = "card status-new "

      #if company not interested
      if parseInt(this.model.get('dev_status_integer')) in [0] && parseInt(this.model.get('co_status_integer')) == 9
        classes = "card status-new "

      #if company not interested
      if parseInt(this.model.get('dev_status_integer')) in [1,2] && parseInt(this.model.get('co_status_integer')) == 9
        classes = "card status-pending "

      return classes
    ,

    render: (eventName) ->
        this.$el.attr('data-id', this.model.get('id'));
        source   = $(".developer-dashboard-card-template").html();
        template = Handlebars.compile(source);
        context = this.model.toJSONDecorated();
        html    = template(context);
        $(this.el).html(html);
        return this;

});

APP.CompanyJobCardListView = Backbone.View.extend({

    tagName:'ul',
    className:"card-list clearfix",
    statusFilter: 'none',

    initialize: (options) ->
        this.model.bind("reset", this.render, this);
        _.extend(this, _.pick(options, "viewType"));
    ,

    render: (eventName) ->
      $(this.el).empty()
      for job_card in this.model.models
        switch this.viewType
          when "open"
            $(this.el).append(new APP.CompanyJobCardViewOpen({model:job_card}).render().el);
          when "drafts"
            $(this.el).append(new APP.CompanyJobCardViewDraft({model:job_card}).render().el);
          when "closed"
            $(this.el).append(new APP.CompanyJobCardViewClosed({model:job_card}).render().el);

      #if this.viewType == "open"
      # $(this.el).append("<li><a href=\"#\" class=\"upgrade-subscription-link\">Upgrade<br />Subscription</a></li>")
      APP.buildComponents($(this.el))

      return this;
});


APP.CompanyJobCardViewOpen = Backbone.View.extend({

    tagName:"li",
    className:"active",

    render: (eventName) ->
        this.$el.attr('data-id', this.model.get('id'));
        source   = $(".company-home-job-card-open-template").html();
        template = Handlebars.compile(source);
        context = this.model.toJSONDecorated();
        html    = template(context);
        $(this.el).html(html);
        return this;

});

APP.CompanyJobCardViewDraft = Backbone.View.extend({

    tagName:"li",
    className:"active",

    render: (eventName) ->
        this.$el.attr('data-id', this.model.get('id'));
        source   = $(".company-home-job-card-draft-template").html();
        template = Handlebars.compile(source);
        context = this.model.toJSONDecorated();
        html    = template(context);
        $(this.el).html(html);
        return this;

});

APP.CompanyJobCardViewClosed = Backbone.View.extend({

    tagName:"li",
    className:"active",

    render: (eventName) ->
        this.$el.attr('data-id', this.model.get('id'));
        source   = $(".company-home-job-card-closed-template").html();
        if parseInt(this.model.get('status')) == 4
          source   = $(".company-home-job-card-hired-template").html();
          $(this.el).removeClass('hired').addClass('hired')
        template = Handlebars.compile(source);
        context = this.model.toJSONDecorated();
        html    = template(context);
        $(this.el).html(html);
        return this;

});