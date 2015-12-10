class UsersController < ApplicationController
	def index
		@users = User.all
	end

	def show
		@user = User.find_by(email: params[:q])

		if @user == nil 
			#Create new user
			@user = User.create(email: params[:q])

			#Create clearbit profile
			#@clearbit_response = Clearbit::Enrichment.find(email: params[:q], stream: true)
			@cb_profile = Profile.create(name: clearbit_response[:person][:name][:fullName] || "n/a",
																	 title: clearbit_response[:person][:employment][:title] || "n/a",
																	 company: clearbit_response[:person][:employment][:name] || "n/a",
																	 photo_url: clearbit_response[:person][:avatar] || "n/a",
																	 source: "clearbit",
																	 user_id: @user.id)

			#Create fullcontact profile
			#@fullcontact_response = FullContact.person(email: params[:q])
			@fc_profile = Profile.create(name: fullcontact_response[:contact_info][:full_name] || "n/a",
																	 title: fullcontact_response[:organizations][0][:title] || "n/a",
																	 company: fullcontact_response[:organizations][0][:name] || "n/a",
																	 photo_url: fullcontact_response[:photos][0][:url] || "n/a",
																	 source: "fullcontact",
																	 user_id: @user.id)
			#Create tags for fc profile
			@tags = []
			@fullcontact_response[:digital_footprint][:topics].each {|item| @tags << item[:value] } if !@fullcontact_response[:digital_footprint][:topics].empty?
			@fc_profile.tags = @tags.join(', ')
		end
	end
end
