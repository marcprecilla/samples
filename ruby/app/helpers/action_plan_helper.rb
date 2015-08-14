# encoding: UTF-8
module ActionPlanHelper

    def checkin_title_for_symbol(checkin_sym)
        return "" unless checkin_sym
        checkin_sym.to_s.titlecase + " Check-In"
    end
    def checkin_description_for_symbol(checkin_sym)
        return "" unless checkin_sym

        subject = checkin_sym.to_s
        subject = "mood" if checkin_sym == :positivity
        subject = "relationships" if checkin_sym == :social
        "Answer a few quick questions about your #{subject}."
    end

    def theme_title_for_week(week)
        theme_title_for_symbol(StressLessAppWeeklyActionPlan.theme_symbol_for_week(week))
    end
    def theme_detail_for_week(week)
        theme_detail_for_symbol(StressLessAppWeeklyActionPlan.theme_symbol_for_week(week))
    end

    def theme_title_for_symbol(theme_symbol)
        titles = {
            creativity:"Creativity",
            curiosity:"Curiosity",
            # curiosity_and_exploration:"Curiosity & Exploration",
            # discover_your_strengths:"Discover Your Strengths",
            # find_your_flow:"Find Your Flow",
            flow:"Flow",
            # get_rested:"Get Rested",
            growth:"Growth",
            happiness:"Happiness",
            # high_performance_at_work:"High-Performance at Work",
            # ideal_self:"Ideal Self",
            leadership:"Leadership",
            love:"Love",
            # meaning_in_life:"Meaning In Life",
            meaningful:"Meaningful ",
            # meaningful_relationships:"Meaningful Relationships",
            # orientation:"Orientation",
            # positive_moral_emotions:"Positive Moral Emotions",
            rejuvenation:"Rejuvenation",
            strength:"Strength",
            strengths:"Strengths",
            # transformational_eadership:"Transformational Leadership",
            values:"Values",
            vitality:"Vitality",
        }
        titles[theme_symbol.to_sym] #or raise "theme_title_for_symbol: #{theme_symbol} not found"
    end

    def theme_detail_for_symbol(theme_symbol)
        details = {
            creativity:"Explore joy, love and excitement to enhance your creativity.",
            curiosity:"Rekindle curiosity in your life to give your brain a performance boost.",
            # curiosity_and_exploration:"(detail copy for 'Curiosity & Exploration' should be here)",
            # discover_your_strengths:"(detail copy for 'Discover Your Strengths' should be here)",
            # find_your_flow:"(detail copy for 'Find Your Flow' should be here)",
            flow:"Power up on focus & learn stay in the zone when it’s critical.",
            # get_rested:"(detail copy for 'Get Rested' should be here)",
            growth:"Focus on becoming your own best self, and build toward the ideal future you.",
            happiness:"Be prosocial and spread love and kindness with those around you.",
            # high_performance_at_work:"(detail copy for 'High-Performance at Work' should be here)",
            # ideal_self:"(detail copy for 'Ideal Self' should be here)",
            leadership:"Inspire others to become their best selves. ",
            love:"Focus your attention on cultivating and deepening your closest relationships.",
            # meaning_in_life:"(detail copy for 'Meaning In Life' should be here)",
            meaningful:"Prioritize the positive. Spend focused time with friends and family.",
            # meaningful_relationships:"(detail copy for 'Meaningful Relationships' should be here)",
            # orientation:"(detail copy for 'Orientation' should be here)",
            # positive_moral_emotions:"(detail copy for 'Positive Moral Emotions' should be here)",
            rejuvenation:"Boost your positivity, energy and relationships by getting your ZZZ’s!",
            strength:"Learn to navigate stress to increase performance at work, school or home.",
            strengths:"Identify and leverage your natural talents.",
            # transformational_eadership:"(detail copy for 'Transformational Leadership' should be here)",
            values:"Define what’s important to you and take action.",
            vitality:"Welcome to your Mind Fitness, core development program.",
        }
        details[theme_symbol.to_sym] #or raise "theme_detail_for_symbol: #{theme_symbol.to_s} not found"
    end





end
