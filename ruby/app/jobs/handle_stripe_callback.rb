require 'mixpanel-ruby'

class HandleStripeCallback
    @queue = :normal

    def self.perform(event)
        Rails.logger.info '========== HANDLING STRIPE CALLBACK =========='
        Rails.logger.info event.inspect


        begin
            object = event['data']['object']
        
            customer_id = object['customer'] || object['id']
    
            type = event['type'].downcase.tr('.','_').tr(' ','_').to_sym

            unless customer_id.index("cus_") == 0
                Rails.logger.info("STRIPE CALLBACK PROCESSING ERROR: Stripe callbacks not a valid customer id")
                return
            end
        
            user = User.find_by_stripe_customer_id(customer_id)
            unless user
                Rails.logger.info("STRIPE CALLBACK PROCESSING ERROR: User not found for customer_id: #{customer_id}")
                return
            end

            Rails.logger.info 'notifying mixpanel...'
            self.track_via_mixpanel(user, event)
    
            # Create App log
            Rails.logger.info 'creating event....'
            event_name = "stripe_#{type.to_s.titlecase}"
            Rails.logger.info "  event name: #{event_name}"

            Event.create!(type:event_name, enrollment_uuid:user.enrollments.first.uuid, data:object)
    
            case type
            when :customer_subscription_deleted
                Rails.logger.info "Doing special processing for the #{type} event"
                user.update_stripe_subscription_status!
                Resque.enqueue(UpdateMailChimp, user.email, :past_subscriber)
            end
            # case
            # when STRIPE_SUBSCRIPTION_EVENTS.include?(event[:type])
            #     Rails.logger.info 'special processing...'
    
            #     stripe_customer_id = event[:data][:object][:customer]
            #     if user = User.where(stripe_customer_id: stripe_customer_id).first
            #         Rails.logger.info '.. found user, calling update_stripe_subscription'
            #         user.update_stripe_subscription!
            #     end
            # else
            #     # all other events
            #     Rails.logger.info '(NO special processing...)'
            # end
            Rails.logger.info '========== fin. HANDLING STRIPE CALLBACK =========='

        rescue => e
            Rails.logger.info '========== fin. Exception =========='
            Rails.logger.error e.message
            Rails.logger.error e.backtrace.join("\n")
        end

    end

    def self.track_via_mixpanel(user, event)
        event_name = 'Stripe '+event['type'].tr('.', '_').titlecase
        event_data = event['data']['object']

        tracker = Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_ID'])
        tracker.track(user.uuid, event_name, event_data)
    end
end
