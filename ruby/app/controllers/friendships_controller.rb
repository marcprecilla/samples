class FriendshipsController < ApplicationController
	def index
		@graph = Koala::Facebook::API.new(oauth_access_token)
		@friends = @graph.get_connections('me', 'friends')
	end
end
