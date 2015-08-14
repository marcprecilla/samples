class CreateTestUsers
  @queue = :normal

  def self.perform(num)
    start_index = User.where("email like 'test_user%@myapp.com'").count + 1
    end_index = start_index + num.to_i - 1

    (start_index..end_index).each do |i|
      user = User.where(email: "test_user+#{i}@myapp.com").first_or_create do |u|
        u.receive_email_notifications = [true, false].sample
        u.gender = User::GENDERS.sample
        u.relationship_status = User::RELATIONSHIP_STATUSES.sample
        u.children = [true, false].sample
        u.workplace_environment = User::WORKPLACE_ENVIRONMENTS.sample
        u.home_environment = User::HOME_ENVIRONMENTS.sample
        u.age_demographic = User::AGE_DEMOGRAPHICS.sample
        u.name = "Test #{i}"
      end

      Resque.enqueue(CreateUserData, user.uuid, 1+rand(30))
      # CreateUserData.perform(user.uuid, 1+rand(30))
    end
  end
end
