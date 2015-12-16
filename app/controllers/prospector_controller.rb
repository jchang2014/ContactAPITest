class ProspectorController < ApplicationController
	def index

	end

	def show
		@people = Clearbit::Prospector.search(domain: params[:company],title: params[:title], email:true)

		Response.create(response_hash: @people.to_json, source:"Prospector")

		@people.each do |person|
			@user = User.create(email:person.email,source:"Prospector")
			@user.profiles.create(name:person.name.full_name, title:person.title,company:person.company,source:"Prospector")
		end
	end
end
