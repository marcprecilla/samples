module SharingHelper

  def facebook_share_url
    host=ENV['DOMAIN_NAME'] || "train.myapp.com"
    params = {
      app_id: ENV['FACEBOOK_APP_ID'],
      link: "https://#{host}",
      picture: "https://s3.amazonaws.com/s3.stressless.myapp.com/app_icon_200x200.png",
      name: "Stress Less",
      description: "I just signed up for app. Register here and start your journey now #{host}",
      redirect_uri: "https://#{host}"
    }

    "https://www.facebook.com/dialog/feed?#{params.to_query}"
  end

  def twitter_share_url
    host=ENV['DOMAIN_NAME'] || "train.myapp.com"
    params = {
      original_referer: "https://#{host}",
      text: "I just signed up for app. Register here and start your journey now #{host}",
      tw_p: "tweetbutton",
      url: "https://#{host}"
    }

    "https://twitter.com/intent/tweet?#{params.to_query}"
  end

  def email_share_url
    host=ENV['DOMAIN_NAME'] || "train.myapp.com"

    params = {
      subject: "Join me on Stress Less",
      body: "I just signed up for app's Mind Fitness program. Register here and start your journey now https://#{host}\n\nHaving less stress is proven to slow down aging, increase performance and build happiness."
    }

    # to_query uses CGI.encode which replaces spaces with '+', which is not valid for mailto uris
    query = params.collect {|k,v| "#{URI.encode(k.to_param)}=#{URI.encode(v.to_s)}"}

    "mailto:?#{query.join("&")}"
  end
end
