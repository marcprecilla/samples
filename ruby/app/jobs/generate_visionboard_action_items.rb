












# THIS IS OVERRIDDEN with the new action plan generation scheme
#  however, the notifications need to be reimplemented  















# require 'mandrill'

# INTENTION_DAY = 2
# THANK_DAY = 3
# VB_INTENTION_DAY = 5
# VB_THANK_DAY = 6

# class GenerateVisionboardActionItems
#   @queue = :normal

#   def self.perform
#     plans_for(INTENTION_DAY).each do |plan|
#       Rails.logger.info "   - intention for #{plan.uuid}"
#       plan.create_intention_action_item
#        Resque.enqueue(SendVisionboardNotificationEmail, plan.uuid, :intention)
#      # Resque.enqueue(SendIntentionNotificationEmail, plan.uuid, :focus)
#     end

#     plans_for(THANK_DAY).each do |plan|
#       Rails.logger.info "   - thank for #{plan.uuid}"
#       plan.create_thank_action_item
#        Resque.enqueue(SendVisionboardNotificationEmail, plan.uuid, :thank)
#      # Resque.enqueue(SendThankNotificationEmail, plan.uuid, :focus)
#     end

#     plans_for(VB_INTENTION_DAY).each do |plan|
#       Rails.logger.info "   - visionboard/intention for #{plan.uuid}"
#       plan.create_visionboard_intention_action_item
#       Resque.enqueue(SendVisionboardNotificationEmail, plan.uuid, :intention_visualization)
#     end

#     plans_for(VB_THANK_DAY).each do |plan|
#       Rails.logger.info "   - visionboard/thank for #{plan.uuid}"
#       plan.create_visionboard_thank_action_item
#       Resque.enqueue(SendVisionboardNotificationEmail, plan.uuid, :thank_visualization)
#     end
#   end

#   private

#   def self.plans_for(days_old)
#     time_range=days_old.days.ago..(days_old-1).days.ago
#           Rails.logger.info "     - timerange: #{time_range}"

#     res = StressLessAppWeeklyActionPlan.where(created_at:time_range)
#               Rails.logger.info "     - results: #{res.length}"

#     res
#   end
# end
