class Api::MarketingController < Api::ApiController



  def new_subscriptions
    render text:NEW_SUBSCRIPTIONS_RESPONSE
  end

  def subscription_types
  	render text:SUBSCRIPTION_TYPES_RESPONSE
  end

  	NEW_SUBSCRIPTIONS_RESPONSE = <<-BEGIN
{ "item" : "23",
  "max" : { "text" : "Max value",
      "value" : "30"
    },
  "min" : { "text" : "Min value",
      "value" : "10"
    }
}
BEGIN


	SUBSCRIPTION_TYPES_RESPONSE = <<-BEGIN
{ 
chart: { 
     renderTo: 'container' 
},
credits: { 
     enabled: false 
}, 
       series: [{
         type: 'pie',
         name: 'Subscription Types',
         data: [
            ['3m Free', 40],
            {
               name: 'Basic',    
               y: 1882,
               sliced: true,
               selected: true
            },
	        ['Premium 1', 313]
	        ['Premium 2', 325]
	        ['Premium 3', 313]
         ]
      }]
}	
BEGIN

end
