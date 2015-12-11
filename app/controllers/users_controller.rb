class UsersController < ApplicationController
	def index
		@users = User.all
	end

	def show
		@user = User.find_by(email: params[:q])

		@user = User.create(email: params[:q]) if !@user

		@cb_profile = @user.profiles.find_by(source:"Clearbit")
		create_cb_profile if !@cb_profile

		@fc_profile = @user.profiles.find_by(source:"Fullcontact")

		create_fc_profile if !@fc_profile
	end


	private
	#Need to move these to a lib file
	def create_cb_profile
		#Query Clearbit for user data
		@clearbit_response = begin
			Clearbit::Enrichment.find(email: @user.email, stream: true)
		rescue Nestful::ResourceInvalid
			nil
		end

		#Save Clearbit response
		@user.responses.create(response_hash: @clearbit_response.to_json, source: "Clearbit")

		#Create profile from clearbit response
		@cb_profile = @user.profiles.create(name: @clearbit_response.try(:person).try(:name).try(:fullName) || "n/a",
																 title: @clearbit_response.try(:person).try(:employment).try(:title) || "n/a",
																 company: @clearbit_response.try(:person).try(:employment).try(:name) || "n/a",
																 photo_url: @clearbit_response.try(:person).try(:avatar) || nil,
																 source: "Clearbit",
																 tags: "n/a")

		#Fill in linkedin url attribute
		@cb_profile.linkedin_url = find_cb_linkedin_url
		@cb_profile.save
	end

	def create_fc_profile
		#Query Fullcontact for user data
		@fullcontact_response = begin
			FullContact.person(email: @user.email)
		rescue FullContact::NotFound
			nil
		rescue FullContact::Invalid
			nil
		end 

		#Save Fullcontact response
		@user.responses.create(response_hash: @fullcontact_response.to_json, source: "Fullcontact")

		#Create profile from fullcontact response
		@fc_profile = @user.profiles.create(name: @fullcontact_response.try(:contact_info).try(:full_name) || "n/a",
																 				source: "Fullcontact")

		#Fill in other attributes
		find_fc_employment_info
		find_fc_photo_info
		find_fc_tag_info
		find_fc_linkedin_url
		@fc_profile.save
	end

	def find_fc_employment_info
	  @fc_profile.title = @fullcontact_response.try(:organizations).try(:at,0).try(:title) || "n/a"
	  @fc_profile.company = @fullcontact_response.try(:organizations).try(:at,0).try(:name) || "n/a"
	end

	def find_fc_photo_info
	  @fc_profile.photo_url = @fullcontact_response.try(:photos).try(:at,0).try(:url) || nil
	end

	def find_fc_tag_info
		@topics = @fullcontact_response.try(:digital_footprint).try(:topics)
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

	def find_fc_linkedin_url
		@social_profiles = @fullcontact_response.try(:social_profiles)
		@social_profiles.each do |profile|
			@fc_profile.linkedin_url = profile.try(:url) if profile.try(:type) == "linkedin"
		end
	end

	def find_cb_linkedin_url
		@url = @clearbit_response.try(:person).try(:linkedin).try(:handle)

		case @url
		when ""
			return nil
		when nil
			return nil
		else 
			return "https://linkedin.com/#{@url}"
		end 
	end
end
