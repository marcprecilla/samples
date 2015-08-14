# THIS IS OVERRIDDEN with the new action plan generation scheme
#  however, the notifications 
#     Resque.enqueue(SendCheckin, :sleep, plan)
#  need to be reimplemented  

# require 'mandrill'
# include ApplicationHelper
# include InterventionHelper
# include StressLessEmailHelper

# load_intervention_metadata

# SLEEP_DAY       = 2
# POSITIVITY_DAY  = 3
# SOCIAL_DAY      = 5
# FOCUS_DAY       = 6

# class GenerateCheckInQuestions
#   @queue = :normal

#   def self.perform
#     self.log "GenerateCheckInQuestions started..."

#     # checkin: day, hour
#     sleep_check_in = [2.days.ago.to_date, 8]
#     positivity_check_in = [3.days.ago.to_date, 10]
#     social_check_in = [5.days.ago.to_date, 15]
#     focus_check_in = [6.days.ago.to_date, 17]

#     self.log "sleep_check_in = #{sleep_check_in}"
#     self.log "positivity_check_in = #{positivity_check_in}"
#     self.log "social_check_in = #{social_check_in}"
#     self.log "focus_check_in = #{focus_check_in}"

#     # NOTE: This code will not scale well. Optimally, there should be a table in the
#     # database for checkins, and when a new Action Plan is created, records are inserted
#     # in that table for each checkin with the appropriate date and time for when it
#     # should be sent.

#     # loop for all action plans created in the last week
#     StressLessAppWeeklyActionPlan.where("created_at > ?", 7.days.ago).find_each do |plan|
#       self.log "plan.uuid = #{plan.uuid}"

#       next unless user = plan.try(:enrollment).try(:user)
#       receive_notifications = user.receive_email_notifications || user.receive_sms_notifications

#       time_zone = user.time_zone
#       time_zone = "Eastern Time (US & Canada)" if time_zone.blank?

#       plan_start = plan.created_at.to_date

#       now = Time.now.in_time_zone(time_zone)
#       nearest_hour = now.min < 30 ? now.hour : now.hour + 1
#       # nearest_hour = Time.at((now.to_f / 1.hour).round * 1.hour).hour

#       self.log "enrollment.uuid = #{plan.enrollment.uuid}"
#       self.log "user.uuid = #{user.uuid}"
#       self.log "time_zone = #{time_zone}"
#       self.log "plan_start = #{plan_start}"
#       self.log "now = #{now}"
#       self.log "nearest_hour = #{nearest_hour}"

#       case [plan_start, nearest_hour]
#       when sleep_check_in
#         # plan.try(:create_sleep_check_in_action_items)
#         Resque.enqueue(SendCheckin, :sleep, plan.uuid) if receive_notifications
#       when positivity_check_in
#         # plan.try(:create_positivity_check_in_action_items)
#         Resque.enqueue(SendCheckin, :positivity, plan.uuid) if receive_notifications
#       when social_check_in
#         # plan.try(:create_social_check_in_action_items)
#         Resque.enqueue(SendCheckin, :social, plan.uuid) if receive_notifications
#       when focus_check_in
#         # plan.try(:create_focus_check_in_action_items)
#         Resque.enqueue(SendCheckin, :focus, plan.uuid) if receive_notifications
#       end
#     end

#     self.log "GenerateCheckInQuestions finished."
#   end

# private

#   def self.log(message)
#     puts "#{message}"
#   end
# end
