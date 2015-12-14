class FullContactHelpers

	attr_reader :user

	def initialize(user)
		@user = user
	end

	def create_fc_profile
		#Query Fullcontact for user data
		@fullcontact_response = begin
			FullContact.person(email: @user.email)
		rescue FullContact::NotFound
			nil
		rescue FullContact::Invalid
			nil
		rescue FullContact::Accepted
			#Write worker to try again later
			nil
		end 

		#Save Fullcontact response
		@user.responses.create(response_hash: @fullcontact_response.to_json, source: "Fullcontact")

		#Create profile from fullcontact response
		@fc_profile = @user.profiles.create(name: @fullcontact_response.try(:contact_info).try(:full_name) || "n/a",
																 				source: "Fullcontact",
																 				status: @fullcontact_response.try(:status))

		#Fill in other attributes
		find_fc_employment_info
		find_fc_photo_info
		find_fc_tag_info
		find_fc_linkedin_url

		@fc_profile.save
	end

	private

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
		if @social_profiles
			@social_profiles.each do |social_profile|
				if social_profile.try(:type) == "linkedin"
					@fc_profile.linkedin_url = social_profile.try(:url) 
				end
			end
		end
	end
end