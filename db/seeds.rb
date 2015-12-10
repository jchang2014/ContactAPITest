# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users_array = [[1,"n3xeurope@gmail.com"],
							 [2,"andrew@taplytics.com"],
							 [3,"mcgseattle@yahoo.com"],
							 [4,"andreajoseph@kw.com"],
							 [5,"yalland@live.co.uk"],
							 [6,"maor@pandats.com"],
							 [7,"scott@makenapartners.com"],
							 [8,"haji@bottega8.com"],
							 [9,"ajma@live.com"],
							 [10,"jeffrey.ouyang@gmail.com"],
							 [11,"grace.coopman@pinpoint.jobs"],
							 [12,"joenewbry@gmail.com"],
							 [13,"thomson@framed.io"],
							 [14,"urbanturbanguy@gmail.com"],
							 [15,"jon@colab.la"],
							 [16,"christopher.hoyd@gmail.com"],
							 [17,"chanderson0@gmail.com"],
							 [18,"dave@davefriedman.com"],
							 [19,"next027@gmail.com"],
							 [20,"jasmine@jbcomms.com"],
							 [21,"todd.giannattasio@tresnicmedia.com"],
							 [22,"itamar@outlook.com"],
							 [23,"amg@freebee.pl"],
							 [24,"fred@gredglick"],
							 [25,"bradleygtucker@gmail.com"]
							]



users_array.each do |user|
	@user = User.create(concierge_id: user[0], email: user[1])
	create_cb_profile
	create_fc_profile
	find_fc_employment_info
	find_fc_photo_info
	find_fc_tag_info
end

def create_cb_profile
		@clearbit_response = Clearbit::Enrichment.find(email: @user.email, stream: true)
		@cb_profile = @user.profiles.create(name: @clearbit_response[:person][:name][:fullName] || "n/a",
																 title: @clearbit_response[:person][:employment][:title] || "n/a",
																 company: @clearbit_response[:person][:employment][:name] || "n/a",
																 photo_url: @clearbit_response[:person][:avatar] || "n/a",
																 source: "Clearbit",
																 tags: "n/a")
	end

	def create_fc_profile
		@fullcontact_response = FullContact.person(email: @user.email)
			
		@fc_profile = @user.profiles.create(name: @fullcontact_response.try(:contact_info).try(:full_name) || "n/a",
																 				source: "Fullcontact")
	end

	def find_fc_employment_info
		if @fullcontact_response[:organizations]
		  @fc_profile.title = @fullcontact_response.try(:organizations).try(:at,0).try(:title)
		  @fc_profile.company = @fullcontact_response.try(:organizations).try(:at,0).try(:name)
		else
			@fc_profile.title = "n/a"
			@fc_profile.company = "n/a"
		end
	end

	def find_fc_photo_info
		if @fullcontact_response[:photos]
		  @fc_profile.photo_url = @fullcontact_response.try(:photos).try(:at,0).try(:url)
		else
			@fc_profile.photo_url = "n/a"
		end
	end

	def find_fc_tag_info
		if @fullcontact_response[:digital_footprint]
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