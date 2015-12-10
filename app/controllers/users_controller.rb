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

		@cb_profile = @user.profiles.find_by(source:"Clearbit")

		if !@cb_profile
			create_cb_profile
		end

		@fc_profile = @user.profiles.find_by(source:"Fullcontact")

		if !@fc_profile
			create_fc_profile
			find_fc_employment_info
			find_fc_photo_info
			find_fc_tag_info
			
			@fc_profile.save	
		end	
	end

	private

	def create_cb_profile
		@clearbit_response = Clearbit::Enrichment.find(email: params[:q], stream: true)
		@cb_profile = @user.profiles.create(name: @clearbit_response[:person][:name][:fullName] || "n/a",
																 title: @clearbit_response[:person][:employment][:title] || "n/a",
																 company: @clearbit_response[:person][:employment][:name] || "n/a",
																 photo_url: @clearbit_response[:person][:avatar] || "n/a",
																 source: "Clearbit",
																 tags: "n/a")
	end

	def create_fc_profile
		@fullcontact_response = FullContact.person(email: params[:q])
			
		@fc_profile = @user.profiles.create(name: @fullcontact_response.try(:contact_info).try(:full_name) || "n/a",
																 				source: "Fullcontact")
	end

	def find_fc_employment_info
		if @fullcontact_response[:organizations]
		  @fc_profile.title = @fullcontact_response[:organizations][0][:title]
		  @fc_profile.company = @fullcontact_response[:organizations][0][:name]
		else
			@fc_profile.title = "n/a"
			@fc_profile.company = "n/a"
		end
	end

	def find_fc_photo_info
		if @fullcontact_response[:photos]
		  @fc_profile.photo_url = @fullcontact_response[:photos][0][:url]
		else
			@fc_profile.photo_url = "n/a"
		end
	end

	def find_fc_tag_info
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
	end
end
