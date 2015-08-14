# encoding: UTF-8
module StressLessEmailHelper
	PROTOCOL = ENV['REQUIRE_HTTPS'] ? 'https' : 'http'
  HOST = ENV['MAIL_HOST'] || 'localhost:3000'
  GA_DOMAINS = (%w(train.myapp.com stresslessapp.myapp.com stressless.myapp.com www.myapp.com) + [ENV['DOMAIN_NAME']]).uniq

  def generate_link_parameters(params)
  	# need to pass through the source, campaign and landing page to the email so that the recipient will propigate the values.
    link_params = {}
    link_params["utm_source"] = params[:source] if params[:source]
    link_params["utm_campaign"] = params[:campaign] if params[:campaign]
    link_params["lp"] = params[:landing_page] if params[:landing_page]
  
    link_params_string = link_params.collect{|k,v|"#{URI::escape k}=#{URI::escape v}"}.join("&")
  end

	def index_for_week(week)
    	(week-1) % EMAIL_CONTENT.length
  	end

	def subject(week)
		hash = EMAIL_CONTENT[index_for_week week]
		hash ? hash[:name] : nil
	end

	def message_text(week)
		hash = EMAIL_CONTENT[index_for_week week]
		hash ? hash[:text] : nil
	end

	def quote(week, index)
		hash = EMAIL_CONTENT[index_for_week week]
		return nil unless hash
		[hash["quote_#{index}_text".to_sym], hash["quote_#{index}_source".to_sym]]
	end

	# def start_url
 #    Rails.application.routes.url_helpers.dashboard_url(protocol: PROTOCOL, host: HOST)
 #  end

 #  def unsubscribe_url(email)
 #    Rails.application.routes.url_helpers.unsubscribe_url(protocol: PROTOCOL, host: HOST, email: email)
 #  end

 #  def intervention_url(key)
 #    "http://train.myapp.com/activity/new/#{key}"
 #  end
 #  def intervention_url(key)
 #    "http://train.myapp.com/activity/new/#{key}"
 #  end

 #  def intervention_image_url(key)
 #    key = key.to_s.gsub("_","-")
 #    "http://s3.myapp.com/stressless/email/email.stressless.int.#{key}.gif"
 #  end


	EMAIL_CONTENT = [
	  {name:"Open your eyes", quote_1_text:"The real voyage of discovery consists not in seeking new landscapes, but in having new eyes", quote_1_source:"Marcel Proust", quote_2_text:"Joy is what happens to us when we allow ourselves to recognize how good things really are", quote_2_source:"Marianne Williamson", text:"This week expand your awareness to include more of the good things in your life." },
	  {name:"Step into happiness", quote_1_text:"Action speaks louder than words but not nearly as often", quote_1_source:"Mark Twain", quote_2_text:"The ability to perceive or think differently is more important than the knowledge gained", quote_2_source:"David Bohm", text:"In the next few days, mix things up a little. Use the following exercises to experience daily life in a slightly different way." },
	  {name:"Breathe, relax, and stay connected", quote_1_text:"To have faith is to trust yourself to the water. When you swim you don't grab hold of the water, because if you do you will sink and drown. Instead you relax, and float", quote_1_source:"Alan Watts", quote_2_text:"The two most powerful warriors are patience and time", quote_2_source:"Leo Tolstoy", text:"It's time to unwind and calm down. Allocate the time in the coming days to engage in relaxation exercises, declutter your mind, and gain some clarity." },
	  {name:"Reconnect with others and get the rest you need", quote_1_text:"Man should forget his anger before he lies down to sleep", quote_1_source:"Mahatma Gandhi", quote_2_text:"I have found the paradox, that if you love until it hurts, there can be no more hurt, only more love", quote_2_source:"Mother Teresa", text:"This coming week, focus on getting the rest you need, and use your energy to connect with the important people in your life. " },
	  {name:"Gain some mental muscle", quote_1_text:"A mind at peace, a mind centered and not focused on harming others, is stronger than any physical force in the universe", quote_1_source:"Wayne Dyer", quote_2_text:"Silence is a source of great strength", quote_2_source:"Lao Tzu", text:"Make time this week to work on your mental muscles: sharpen your focus, cultivate positivity, and learn to recognize the little good things." },
	  {name:"Strengthen relationships", quote_1_text:"Old friends pass away, new friends appear. It is just like the days. An old day passes, a new day arrives. The important thing is to make it meaningful: a meaningful friend - or a meaningful day", quote_1_source:"Dalai Lama", quote_2_text:"Trust is the glue of life. It's the most essential ingredient in effective communication. It's the foundational principle that holds all relationships", quote_2_source:"Stephen Covey", text:"Positive relationships in your life give you the strength and energy you need to deal with life's challenges. In the coming few days, focus your attention on your relationships, and how they can develop, evolve, and grow." },
	  {name:"Feel the gratitude", quote_1_text:"As we express our gratitude, we must never forget that the highest appreciation is not to utter words, but to live by them", quote_1_source:"John F. Kennedy", quote_2_text:"The essence of all beautiful art, all great art, is gratitude", quote_2_source:"Friedrich Nietzsche", text:"Negative events capture our attention and our mindshare much more so than positive ones. This week's exercises are about capturing the good, recognizing it, and appreciaiting it." },
	  {name:"Take it all in", quote_1_text:"Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment", quote_1_source:"Buddha", quote_2_text:"Life is very short and what we have to do must be done in the now", quote_2_source:"Audre Lorde", text:"Our minds often travel to visit the past or contemplate the future. In the coming days you will work to focus on the present moment, and bring yourself back when your mind wanders off." },
	  {name:"Open up to others", quote_1_text:"When you connect with other people, you connect with something in yourself", quote_1_source:"Toni Collette", quote_2_text:"Appreciation is a wonderful thing: It makes what is excellent in others belong to us as well", quote_2_source:"Voltaire", text:"It could be fulfilling to live a rich internal life, full of thoughts and emotional experiences, but it can also make one feel a little isolated. This week you will focus on the many connections you have with the external world: your bonds with the others around you and your relationship with the environment that you live in." },
	  {name:"Keep at your center", quote_1_text:"At the center of your being you have the answer; you know who you are and you know what you want", quote_1_source:"Lao Tzu", quote_2_text:"There are no constraints on the human mind, no walls around the human spirit, no barriers to our progress except those we ourselves erect", quote_2_source:"Ronald Reagan", text:"Daily life can be busy and demanding, and many of us often feel \"off center\". In the next few days you will focus on exercises that help you find your center each time you feel off." },
	  {name:"Take a breather", quote_1_text:"Live each season as it passes; breathe the air, drink the drink, taste the fruit, and resign yourself to the influences of each.", quote_1_source:"Henry David Thoreau", quote_2_text:"To know even one life has breathed easier because you have lived - that is to have succeeded”", quote_2_source:"Ralph Waldo Emerson", text:"Breathing is both a conscious and unconscious bodily function. Controlled breathing is a powerful way to destress and cultivate calm. This week you will use exercises that help foster controlled breathing. " },
	  {name:"Close your eyes and dream", quote_1_text:"Hope is the dream of a waking man", quote_1_source:"Aristotle", quote_2_text:"The real voyage of discovery consists not in seeking new landscapes, but in having new eyes", quote_2_source:"Marcel Proust", text:"In the coming few days you will exercise your mind and teach yourself to be both attentive to your current environment, and hopeful about the future. Optimism is a powerful mental muscle of the mind that is best nourished by a strong ability to be still and focused." },
	  {name:"Share your positivitiy", quote_1_text:"Friendship is a single soul dwelling in two bodies", quote_1_source:"Aristotle", quote_2_text:"In order to carry a positive action we must develop here a positive vision", quote_2_source:"Dalai Lama", text:"Strong relationships are formed by giving - by seeking ways to be kind or supportive to another person. This week's exercises focus on strengthening the ability to be generous with your time, attention, and resources to others who can benefit from your help." },
	  {name:"Keep connected and slow things down a notch", quote_1_text:"Adopt the pace of nature: her secret is patience", quote_1_source:"Ralph Waldo Emerson", quote_2_text:"Perfection is attained by slow degrees; it requires the hand of time", quote_2_source:"Voltaire", text:"Driving in lower gear can give you more power. In the next few days you will exercise slowing down, and maintaining a steady, calm daily pace; Do the same things you always do, with full attention, intention, and focus." },
	  {name:"Pause, breathe, reframe", quote_1_text:"The right word may be effective, but no word was ever as effective as a rightly timed pause", quote_1_source:"Mark Twain", quote_2_text:"If you only have a hammer, you tend to see every problem as a nail", quote_2_source:"Abraham Maslow", text:"Sometimes things seem different when you look from a different angle. This week, simple exercises will help you get the rest, clarity, and focus you need to be able to reframe and adopt a different perspective." },
	  {name:"Bring your mind back form wandering", quote_1_text:"Our doubts are traitors and make us lose the good we oft might win by fearing to attempt", quote_1_source:"William Shakespeare", quote_2_text:"When I let go of what I am, I become what I might be", quote_2_source:"Lao Tzu", text:"In the coming days, focus your energy on staying present. This week's exercises will help you remain immersed in situations you encounter, experiencing less drifting of the mind to roam outside \"the now\"." },
	  {name:"Listen up", quote_1_text:"Hatred does not cease by hatred, but only by love; this is the eternal rule", quote_1_source:"Buddha", quote_2_text:"The less you open your heart to others, the more your heart suffers", quote_2_source:"Deepak Chopra", text:"The focus of this week's exercises is staying alert, focused, and attentive; To be able to deeply listen to others, to the cues in your environment, and to your own emotional and mental state." },
	  {name:"Focus on the present", quote_1_text:"When you really listen to another person from their point of view, and reflect back to them that understanding, it's like giving them emotional oxygen", quote_1_source:"Stephen Covey", quote_2_text:"Everything has beauty, but not everyone sees it", quote_2_source:"Confucius", text:"Breathing patterns reflect one's state of mind. Controlling these patterns further changes what goes on inside. In the next few days you will engage with breathing exercises that help regulate and control emotions, bringing yourself back into sync." },
	  {name:"Live in the now", quote_1_text:"Our greatest weakness lies in giving up. The most certain way to succeed is always to try just one more time", quote_1_source:"Thomas A. Edison", quote_2_text:"What you get by achieving your goals is not as important as what you become by achieving your goals", quote_2_source:"Henry David Thoreau", text:"The mind can sometimes feel overhwelmed with thoughts, plans, anlyses, and concerns. This week you will practice ways to maintain your mind focused and centered." },
	  {name:"Destress and get some rest", quote_1_text:"Setting goals is the first step in turning the invisible into the visible", quote_1_source:"Tony Robbins", quote_2_text:"Patience is bitter, but its fruit is sweet", quote_2_source:"Jean-Jacques Rousseau", text:"The following exercises help to clear the buildup of stress. In the coming days make the time needed to destress and to give your body and your mind the rest they need." },
	  {name:"Recognizing that \"it's all good\"", quote_1_text:"Slow thinking has the feeling of something you do. It's deliberate", quote_1_source:"Daniel Kahneman", quote_2_text:"Live as if you were living a second time, and as though you had acted wrongly the first time", quote_2_source:"Viktor E. Frankl", text:"In the next few days, take a step back and allow yourself to be still, to meditate, and to observe. Use the exercises below to be guided into a state of greater focus." },
	  {name:"Get replenishing and energizing sleep", quote_1_text:"Have courage for the great sorrows of life and patience for the small ones; and when you have laboriously accomplished your daily task, go to sleep in peace.", quote_1_source:"Victor Hugo", quote_2_text:"It is a common experience that a problem difficult at night is resolved in the morning after the committee of sleep has worked on it", quote_2_source:"John Steinbeck", text:"Sleep is thre sourvce of your energy for each new day. In the coming week you will use to exercises below, at bedtime, to improve the wuality of your sleep, so you can wake up revitalized and refreshed." },
	  {name:"Use your mental muscle to bring down stress", quote_1_text:"Toughness is in the soul and spirit, not in muscles", quote_1_source:"Alex Karras (American football player and wrestler)", quote_2_text:"All the forces in the world are not so powerful as an idea whose time has come", quote_2_source:"Victor Hugo", text:"In the past weeks you have strengthened your mental muscles and your inner strength. In the next few days you will harness your new skills to reduce the presence of stress in your life." },
	  {name:"Keep it up", quote_1_text:"Passion is energy. Feel the power that comes from focusing on what excites you", quote_1_source:"Oprah Winfrey", quote_2_text:"It is obvious that we can no more explain a passion to a person who has never experienced it than we can explain light to the blind", quote_2_source:"T. S. Eliot", text:"Keep practicing breathing and mindfulness exercises this week, to keep your mental muscles at work." },
	  {name:"Flourish", quote_1_text:"We fear to know the fearsome and unsavory aspects of ourselves, but we fear even more to know the godlike in ourselves", quote_1_source:"Abraham Maslow", quote_2_text:"The goal of life is to make your heartbeat match the beat of the universe, to match your nature with Nature", quote_2_source:"Joseph Campbell", text:"Spend time in the coming days in contemplation and in meditation. Think of where you want to go, and the ways you can usse to get there." },
	]
end
