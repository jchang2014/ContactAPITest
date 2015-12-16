class ProspectorController < ApplicationController
	def index

	end

	def show
		@people = Clearbit::Prospector.search(domain: params[:company],title: params[:title], email:true)

		ProspectorResponse.create(response_hash: @people.to_json, source:"Prospector")

		@people.each do |person|
			@user = User.create(email:person.email,source:"Prospector")
			@user.prospector_profiles.create(first_name: person.name.givenName, 
														last_name: person.name.familyName,
														full_name: person.name.fullName, 
														title:person.title)
		end
	end
end
