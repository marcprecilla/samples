class SubscriptionsController < ApplicationController
  skip_before_filter :authenticate, only: [:index, :new, :create, :stripe_callback]
  skip_before_filter :verify_subscription, only: [:index, :new, :create, :stripe_callback]
  skip_before_filter :accept_terms, :check_for_interstitials, :complete_onboarding

  layout 'subscriptions'

  #
  # display the plans for the current offer
  #
  def index
  end

  #
  # handle login/registration & payment info
  #
  def new
    @return_path = new_subscription_path

    redirect_to subscriptions_path and return unless current_plan
  end

  #
  # apply new subscription info
  #
  def create
    @return_path = new_subscription_path

    redirect_to subscriptions_path and return unless current_plan
    render 'new' and return unless current_user

    current_user.update_stripe_card!(params[:stripe_card_token]) unless params[:stripe_card_token].blank?
    current_user.apply_coupon!(current_coupon.id) if current_coupon
    current_user.set_offer_and_subscription_plan!(current_offer, current_plan) if current_offer && current_plan

    unless current_user.stripe_subscription_active?
      Rails.logger.debug "current_user.stripe_subscription_active? is false"
      render 'new' and return
    end

    Resque.enqueue(UpdateMailChimp, current_user.email, :subscriber)

    Rails.logger.info "Subscription updated."
    
    clear_subscription_data
    process_new_subscription_analytics

    redirect_to subscription_confirm_path

  rescue Stripe::StripeError => e
    error = e.json_body[:error]

    # this POST happens twice.  The first time through, the user hasn't entered any form data and we don't want to show bogus errors.
    unless params[:stripe_customer_id].nil?  # first pass through won't include stripe_customer_id as a param
      Rails.logger.error error[:message]
      flash.alert = error[:message]
    end
    
    render 'new'

  rescue => e
    Rails.logger.error e.message
    flash.alert = "M2222"#e.message

    render 'new'

  end

  def destroy
    current_user.cancel_subscription!
    Resque.enqueue(UpdateMailChimp, current_user.email, :past_subscriber)
    redirect_to settings_path
  end

  def confirm
    @user = current_user

    # default notifications to true
    @user.receive_email_notifications = true if @user.receive_email_notifications.nil?
    @user.receive_sms_notifications = true if @user.receive_sms_notifications.nil?
  end

  def stripe_callback
    Resque.enqueue(HandleStripeCallback, params)
    head :ok
  end

private

  def process_new_subscription_analytics
    # Mixpanel Tracking
    mixpanel_track('Created Subscription', {plan: current_plan.name})
    push_mixpanel_event "mixpanel.people.track_charge(#{current_plan.price});"

    # fire a conversion pixel if the purchase source was "EverySignal" (any case).
    if current_lead && "EverySignal".casecmp(current_lead.source.to_s)
      session[:push_everysignal_pixel] = current_plan.price # value is the price
    end

    #for google/optimizely tracking js
    session[:purchase_information] = {
      transaction_id: "#{current_plan.stripe_plan_id}_#{Time.now.iso8601}",
      store_name: 'app Site',
      total: current_plan.discounted_price,
      tax: 0.0,
      shipping: 0.00,
      city: '',
      state: '',
      country: 'USA',
      sku: "#{current_plan.stripe_plan_id}",
      product_name: "#{current_plan.name}",
      category: "#{current_plan.offer.name}",
      unit_price: current_plan.price,
      quantity: 1,
    }
  end
end
