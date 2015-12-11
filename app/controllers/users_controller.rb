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
			p "NOT FOUND"
			create_fc_profile
			find_fc_employment_info
			find_fc_photo_info
			find_fc_tag_info
			
			@fc_profile.save	
		end	
	end

	private

	def create_cb_profile
		@clearbit_response = begin
			Clearbit::Enrichment.find(email: @user.email, stream: true)
		rescue Nestful::ResourceInvalid
			nil
		end
		@cb_profile = @user.profiles.create(name: @clearbit_response.try(:person).try(:name).try(:fullName) || "n/a",
																 title: @clearbit_response.try(:person).try(:employment).try(:title) || "n/a",
																 company: @clearbit_response.try(:person).try(:employment).try(:name) || "n/a",
																 photo_url: @clearbit_response.try(:person).try(:avatar) || nil,
																 source: "Clearbit",
																 tags: "n/a")
	end

	def create_fc_profile
		@fullcontact_response = begin
			FullContact.person(email: @user.email)
		rescue FullContact::NotFound
			nil
		rescue FullContact::Invalid
			nil
		end 

		@fc_profile = @user.profiles.create(name: @fullcontact_response.try(:contact_info).try(:full_name) || "n/a",
																 				source: "Fullcontact")
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
end
