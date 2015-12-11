# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users_array = ["n3xeurope@gmail.com",
							 "andrew@taplytics.com",
							 "mcgseattle@yahoo.com",
							 "andreajoseph@kw.com",
							 "yalland@live.co.uk",
							 "maor@pandats.com",
							 "scott@makenapartners.com",
							 "haji@bottega8.com",
							 "ajma@live.com",
							 "jeffrey.ouyang@gmail.com",
							 "grace.coopman@pinpoint.jobs",
							 "joenewbry@gmail.com",
							 "thomson@framed.io",
							 "urbanturbanguy@gmail.com",
							 "jon@colab.la",
							 "christopher.hoyd@gmail.com",
							 "chanderson0@gmail.com",
							 "dave@davefriedman.com",
							 "next027@gmail.com",
							 "jasmine@jbcomms.com",
							 "todd.giannattasio@tresnicmedia.com",
							 "itamar@outlook.com",
							 "amg@freebee.pl",
							 "fred@gredglick",
							 "bradleygtucker@gmail.com"
							]

	def create_cb_profile
		@clearbit_response = begin
			Clearbit::Enrichment.find(email: @user.email, stream: true)
		rescue Nestful::ResourceInvalid
			nil
		end
		@cb_profile = @user.profiles.create(name: @clearbit_response.try(:person).try(:name).try(:fullName) || "n/a",
																 title: @clearbit_response.try(:person).try(:employment).try(:title) || "n/a",
																 company: @clearbit_response.try(:person).try(:employment).try(:name) || "n/a",
																 photo_url: @clearbit_response.try(:person).try(:avatar) || "n/a",
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

		find_fc_employment_info
		find_fc_photo_info
		find_fc_tag_info
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


users_array.each do |user|
	@user = User.create(email: user)
	create_cb_profile
	create_fc_profile
end