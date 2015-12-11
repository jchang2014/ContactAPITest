module FullContactHelpers

	# attr_reader :user

	# def initialize(user)
	# 	@user = user
	# end
	def create_fc_profile(user)
		#Query Fullcontact for user data
		@fullcontact_response = begin
			FullContact.person(email: user.email)
		rescue FullContact::NotFound
			nil
		rescue FullContact::Invalid
			nil
		end 

		#Save Fullcontact response
		user.responses.create(response_hash: @fullcontact_response.to_json, source: "Fullcontact")

		#Create profile from fullcontact response
		@fc_profile = user.profiles.create(name: @fullcontact_response.try(:contact_info).try(:full_name) || "n/a",
																 				source: "Fullcontact")

		#Fill in other attributes
		find_fc_employment_info(@fullcontact_response, @fc_profile)
		find_fc_photo_info(@fullcontact_response, @fc_profile)
		find_fc_tag_info(@fullcontact_response, @fc_profile)
		find_fc_linkedin_url(@fullcontact_response, @fc_profile)
	end

	def find_fc_employment_info(response, profile)
	  profile.title = response.try(:organizations).try(:at,0).try(:title) || "n/a"
	  profile.company = response.try(:organizations).try(:at,0).try(:name) || "n/a"
	  profile.save
	end

	def find_fc_photo_info(response, profile)
	  profile.photo_url = response.try(:photos).try(:at,0).try(:url) || nil
	  profile.save
	end

	def find_fc_tag_info(response, profile)
		@topics = response.try(:digital_footprint).try(:topics)
		if @topics
			if !@topics.empty?
				@tags = []
				@topics.each {|topic| @tags << topic[:value] } 
				profile.tags = @tags.join(', ')
			else
				profile.tags = "n/a"
			end
		else
			profile.tags = "n/a"
		end
		profile.save
	end

	def find_fc_linkedin_url(response, profile)
		@social_profiles = response.try(:social_profiles)
		@social_profiles.each do |social_profile|
			if social_profile.try(:type) == "linkedin"
				profile.linkedin_url = social_profile.try(:url) 
				profile.save
			end
		end
		puts "final is:#{profile.linkedin_url}"
	end
end