# encoding: UTF-8
module ProgressHelper

	def change_for_category(category_key, difference)
		# categorized_index returns:
		#   0 or 1 if the user has increased in this category,
    #   2 is it is about the same, and
    #   3 or 4 if the user has decreased in this category.
		[:better, :better, :same, :worse, :worse][categorized_index(category_key, difference)]
	end

	def categorized_index(category_key, difference)
		case category_key.to_sym
	  	when :focus then case difference
					  	when 6.67..100 then 0
							when 2.15..6.67 then 1
							when -3.47..2.15 then 2
							when -15.07..-3.47 then 3
							when -100..-15.07 then 4
							else
								raise "Developer error #67387863768678: unsupported case statement value (#{difference})"
						end
			when :positivity then case difference
					  	when 18.75..100 then 0
							when 8.33..18.75 then 1
							when -0.0..8.33 then 2
							when -6.25..0.0 then 3
							when -100..-6.25 then 4
							else
								raise "Developer error #77599017749: unsupported case statement value (#{difference})"
						end
			when :social then case difference
					  	when 8.33..100 then 0
							when 4.17..8.33 then 1
							when -6.25..4.17 then 2
							when -18.75..-6.25 then 3
							when -100..-18.75 then 4
							else
								raise "Developer error #20057690143: unsupported case statement value (#{difference})"
						end
			when :sleep then case difference
					  	when 12.5..100 then 0
							when 4.17..12.5 then 1
							when -4.17..4.17 then 2
							when -16.67..-4.17 then 3
							when -100..-16.67 then 4
							else
								raise "Developer error #34449566599290: unsupported case statement value (#{difference})"
						end
			else
				raise "Developer error #2665899562: unsupported case statement value (#{category_key})"
		end

	end

  def analysis_statement(category_key, difference)
  	texts = PROGRESS_ANALYSIS_COPY[category_key]
  	index = categorized_index(category_key, difference)
  	texts[index]
  end
  
	PROGRESS_ANALYSIS_COPY = {
		:focus => [
			"You are a true focus champion this week.  Your ability to stay connected to the present moment has skyrocketed.  You may notice that when your mind wanders to the future or the past, you're able to quickly bring yourself back to the now.  This will allow you to appreciate your experiences and build stronger connections with the people around you.",
			"You are more focused this week. Your thoughts of the future and the past are reduced, and you feel more aware of your surroundings. You may also find that your natural pace has slowed down a little. This is change in the right direction.  Keep it up!",
			"It seems like your focus levels are about the same this week. Cultivating focus is not easy and takes time. Practicing the focus exercises in this app will help you learn how to notice when your mind drifts and how to bring yourself back.",
			"You may find that you are rushing a little faster through your day and your mind wanders off a little more than usual. In certain situations, your ability to focus may be compromised. Is there something major change or deadline approaching in your life?  Using the focus exercises in the app will help keep you from getting distracted during the day to focus on what's most important.",
			"It looks like you are preoccupied with some concerns that take your mind away from the present moment. It may feel like you have no time.  Just remember, that you do have time.  You simply need to prioritize that time. Practice the focus exercises in this app to lower the pace so you can regain your focus and take control of your time.",
		],
		:sleep => [
			"They might start calling you Sleeping Beauty soon, because the quality of your sleep has significantly increased. You must be feeling more alert and energized! Sleep provides you with the clarity and energy you need to build face your day. Look at your sleep patterns from the past few days and try to replicate them - the time you went to bed, the time you woke up, and the activities you were engaged in during the evening.",
			"You are getting better sleep and probably feeling more alert than usual. Sleep provides you with the clarity and energy you need to face your day. Look at your sleep patterns in the past few days and try to replicate the days when you got great sleep - the time you went to bed, the time you woke up, and the activities you were engaged in during the evening.",
			"Your quality of sleep is about the same this week. Look at your sleep patterns in the past few days and try to determine what in your daily routine results in a better good night’s sleep - the time you went to bed, the time you woke up, and the activities you were engaged in during the evening.",
			"Tough week? Your sleep quality seems to have gone down a bit. Look at your sleep patterns in the past few days and try to determine what in your daily routine results in a better good night’s sleep - the time you went to bed, the time you woke up, and the activities you were engaged in during the evening. Try to avoid too much activity in the evenings. Also, practicing the exercises in this app can help you clear your mind and enjoy more positive emotions during the day, leading to better sleep at night.",
			"Tough week?  Your sleep quality seems to have suffered this week. Look at your sleep patterns in the past few days and try to determine what in your daily routine seems to have a negative effect on the quality of your sleep - the time you went to bed, the time you woke up, and the activities you were engaged in during the evening. Also, practice the exercises in this app to clear your mind and enjoy more positive emotions during the day, leading to better sleep at night.",
		],
		:social => [
			"What a social butterfly! You feel significantly more connected to others, and enjoy the company of people who share your interests and values. This sense of connectedness is great to your well-being and serves as a strong barrier to stress. Keep your significant social connections active and continue to reap the mental benefits they provide.",
			"Your sense of connectedness to the people around you has gone up. You have a stronger sense of relatedness to the around you, allowing you to be more resilient to stress. Continuing to be surrounded by significant and like-minded will increase your sense of connectedness and help you strengthen your resilience to stress.",
			"Your level of social activity seems about the same this week. Being around like-minded others and interacting with the significant people in your life will help you feel less isolated and help build your resilience to stress. Think of the important relationships in your life and the steps you can take today to strengthen them. ",
			"Being around like-minded others and interacting with the significant people in your life will help you feel less isolated and help give your strength throughout the day. You may be feeling slightly more isolated recently. Think of the important relationships in your life and the steps you can take today to strengthen them.",
			"Being around like-minded others and interacting with the significant people in your life will help you feel less isolated and help give you power throughout the day. It looks like you are feeling more isolated than usual recently. Think of the important relationships in your life and the steps you can take today to strengthen them.",
		],
		:positivity => [
			"Your perspective has taken a very healthy positive turn. Continue to engage in the exercises of this app, strengthen your social relationships, get the sleep and rest you need, and be sure to enjoy the clarity, focus, and positive emotions that you are experiencing!
Increased a little",
			"Good news: your outlook is much more positive this week. Look at the past few days to determine what you have done to reduce your stress - and do more of it! Continue to engage in the exercises of this app, to enjoy more clarity, focus, and positive emotions during your day.",
			"Your outlook on life is pretty consistent this week. Practice the exercises in this app to continue to nurture positivity and enjoy the life you have.",
			"You seem to be a little less calm and a little more concerned. Be sure to practice the exercises in this app to have the mental fuel and focus that you need  to cope with any stress in your life, and build more stress-resilience. ",
			"Are you having a tough week?  It's okay to have a bad day, or week if you are.  A bad day can be defeated by a good day. You have the tools you need on your belt to cope with external stress and manage it. Use the exercises in this app to regain your mental energy, focus, and calm, and develop the inner strength to fend off stress. ",
		],
	}
end



