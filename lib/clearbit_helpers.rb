class ClearbitHelpers

	attr_reader :user 

	def initialize(user)
		@user = user
	end

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

	private 

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