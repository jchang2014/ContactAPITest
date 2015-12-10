class UsersController < ApplicationController
	def index
		@users = User.all
	end

	def show
		@user = User.find_by(email: params[:q])

		if @user == nil 
			#Create new user
			@user = User.create(email: params[:q])
		end

		@cb_profile = @user.profiles.find_by(source:"clearbit")

		if @cb_profile == nil
			#Create clearbit profile
			@clearbit_response = Clearbit::Enrichment.find(email: params[:q], stream: true)
			@cb_profile = @user.profiles.create(name: @clearbit_response[:person][:name][:fullName] || "n/a",
																	 title: @clearbit_response[:person][:employment][:title] || "n/a",
																	 company: @clearbit_response[:person][:employment][:name] || "n/a",
																	 photo_url: @clearbit_response[:person][:avatar] || "n/a",
																	 source: "clearbit")
		end

		@fc_profile = @user.profiles.find_by(source:"fullcontact")

		if @fc_profile == nil
			#Create fullcontact profile
			@fullcontact_response = FullContact.person(email: params[:q])
			
			@fullcontact_response[:organizations]
			@fc_profile = @user.profiles.create(name: @fullcontact_response[:contact_info][:full_name] || "n/a",
																	 				source: "fullcontact")

			#Add employment info if it exists
			if @fullcontact_response[:organizations]
			  @fc_profile.title = @fullcontact_response[:organizations][0][:title]
			  @fc_profile.company = @fullcontact_response[:organizations][0][:name]
			else
				@fc_profile.title = "n/a"
				@fc_profile.company = "n/a"
			end

			#Add photo_url if photos exist
			if @fullcontact_response[:photos]
			  @fc_profile.photo_url = @fullcontact_response[:photos][0][:url]
			else
				@fc_profile.photo_url = "n/a"
			end

			#Create tags for fc profile if they exist
			if @fullcontact_response[:digital_footprint]
				@topics = @fullcontact_response[:digital_footprint][:topics]
				if @topics
					if !@topics.empty?
						@tags = []
						@topics.each {|topic| @tags << topic[:value] } 
						@fc_profile.tags = @tags.join(', ')
					else
						@fc_profile.tags = "n/a"
					end
				else
					@fc_profile.tags = "n/a"
				end
			end
			@fc_profile.save	
		end
	end
end
