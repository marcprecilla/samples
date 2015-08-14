require 'mandrill'
include BaselineAssessmentsHelper

class SendMiniBaselineResultsEmail
  @queue = :normal

  def self.perform(assessment_uuid, params)
    log "NO baseline assessment found for uuid #{assessment_uuid}" and return unless assessment = BaselineAssessment.find_by_uuid(assessment_uuid)

    user = assessment.enrollment.try(:user)
    log "NO USER FOR baseline assessment #{assessment_uuid}" and return unless assessment

    numeric_result = assessment.results[:positivity]
    log "NO RESULT FOUND FOR baseline assessment #{assessment_uuid}" and return unless numeric_result

    result_level = score_level_for_positivity numeric_result
    css_class_for_meter = baseline_dial_meter_class_for_level(result_level)
    score_description = score_explination_for(result_level, :positivity)

    log "SendMiniBaselineResultsEmail:  #{numeric_result}/#{result_level}/#{css_class_for_meter}/#{score_description}"

    subject = "#{user.first_name.titlecase}, your Positivity results are ready!"
    url = Rails.application.routes.url_helpers.subscription_url(protocol: PROTOCOL, host: HOST)
    template = "mini-baseline-results"

    link_params_string = generate_link_parameters(source:params[:source], campaign:params[:campaign], landing_page:params[:landing_page])

    # build email
    m = Mandrill::API.new
    message = {
      subject: subject,
      from_name: "app Team",
      from_email: "support@myapp.com",
      to: [{name: user.first_name, email: user.email}],
      track_opens: true,
      track_clicks: true,
      url_strip_qs: true,
      preserve_recipients: false,

      global_merge_vars: [
        {name: 'FNAME', content: user.first_name},
        {name: 'DISPLAYABLE_SCORE', content: result_level.to_s.titleize},
        {name: 'CSS_CLASS_FOR_METER', content: css_class_for_meter},
        {name: 'SCORE_DESCRIPTION', content: score_description},
        {name: 'URL', content: url},
        {name: 'LINK_PARAMS', content: link_params_string},
        {name: 'SOURCE', content: params[:source]},
        {name: 'CAMPAIGN', content: params[:campaign]},
        {name: 'LANDING_PAGE', content: params[:landing_page]},
      ],
      
      google_analytics_domains: GA_DOMAINS,
      google_analytics_campaign: "mini-baseline-results"
    }

    # send email
    results = m.messages.send_template(template, [], message)
    Rails.logger.info "Mandrill results: #{results.inspect}"
  end
end
