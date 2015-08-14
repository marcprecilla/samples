module ActivityHelper
  include InterventionHelper

  def activity_image_url(activity)
    return nil unless activity.intervention
    user_image = activity.image_urls ? activity.image_urls.first : nil
    user_image || image_for_intervention(activity.intervention)
  end

  def social_share_text(intervention)
    "Just completed the #{intervention.name.html_safe} exercise, which helps improve my #{ displayable_category_for(intervention) }.  This exercise is part of my weekly mind fitness program, primed to help me focus, perform and live better.".gsub('&','and')
  end
  def displayable_category_for(intervention)
  res = category_for_intervention_sym(intervention.key.to_sym).downcase
  res = "social interactions" if res == "social"
  res
  end
end
