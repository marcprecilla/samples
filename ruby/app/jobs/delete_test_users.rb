class DeleteTestUsers
  @queue = :normal

  def self.perform
    # destroy_all can take hours to complete, so optimize
    User.where("email like 'test_user%@myapp.com'").find_each do |u|
      # PamScore.where(user_uuid: u.uuid).delete_all

      u.enrollments.find_each do |e|
        activity_uuids = e.activities.pluck(:uuid)
        Response.where(activity_uuid: activity_uuids).delete_all
        Activity.where(uuid: activity_uuids).delete_all
        e.destroy
      end

      u.destroy
    end
  end
end
