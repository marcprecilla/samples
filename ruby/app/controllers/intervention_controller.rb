class InterventionController < ApplicationController
  include InterventionHelper

  def index
    load_intervention_metadata
    puts current_week
    allowed_keys = []
    for week in 1..current_week
      puts week
   puts    allowed_keys << StressLessAppWeeklyActionPlan.intervention_keys_for_week(week)
    end
    allowed_keys.flatten!
    allowed_keys.compact!
    allowed_keys.uniq!
    all_interventions = Intervention.all

    @interventions = { "Positivity" => [], "Focus" => [], "Social" => [], "Sleep" => [] }
    all_interventions.each do |intervention|
      if allowed_keys.include? intervention.key.to_sym
        category = category_for_intervention_sym intervention.key.to_sym
        collection = @interventions[category]
        collection << intervention #unless collection.include? intervention
        collection.flatten!
      end
    end

    @interventions_by_week=(1..current_week).collect do |week|
      StressLessAppWeeklyActionPlan.intervention_keys_for_week(week).compact.collect{|key| all_interventions.detect{|intervention|  intervention.key == key.to_s}}
    end
    puts @interventions_by_week.collect{|arr| arr.collect(&:key)}.to_yaml


    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax"
    end

    @menu_section = "activity-feed"
  end

  def new
    key = params[:id] || session[:current_key] || "thank_bank_work"

    load_intervention_metadata
    @intervention = Intervention.where(key:key).first

    @why_text = why_text(@intervention.key)
    @why_source = why_source(@intervention.key)
    @image_urls = assessment_image_urls(@intervention)

    @enrollment = current_enrollment
    @activity = @enrollment.latest_activity

    @window_title = "#{category_for_intervention_sym @intervention.key} Exercise"

    @photo_upload_enabled = true;
    if browser.iphone? || browser.ipad? || browser.ipod?
      if request.env['HTTP_USER_AGENT'].downcase.match(/os 5/)
        @photo_upload_enabled = false;
      end
    end

    if params[:show_desktop].present?
        render :layout => "layouts/application_ajax", :template => "intervention/#{@intervention.intervention_type}"
    else
      render template:"intervention/#{@intervention.intervention_type}"
    end
  end

  def show
    load_intervention_for params[:id]

    @enrollment = current_enrollment
    @activity = @enrollment.latest_activity

    render template:"intervention/#{@intervention.intervention_type}"
  end

  def update
    @intervention = Intervention.where(uuid:params[:id]).first
    logger.info "user_enjoys=#{params[:user_enjoys]}, user_values=#{params[:user_values]}"

    if params[:user_enjoys] != ""
      preference = nil
      if params[:user_enjoys] == "true"; preference = 1
      else
        if params[:user_values] == "true"; preference = 0
        else; preference = -1
        end
      end
      throw "DEV ERROR #775893094" unless preference

      @enrollment = current_enrollment
      @enrollment.intervention_preferences[@intervention.key] = preference
      @enrollment.save!
    else
      logger.info "(Not updating preferences)"
    end
    redirect_to dashboard_path + "?skip_intro=1"

  end

end
