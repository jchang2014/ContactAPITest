require 'csv'

namespace :users do 

	task :create_users => :environment do 
		#Save CSV data to array
		user_array = CSV.read("./db/unapproved-sf-users.csv")
		#Remove headers row
		user_array.shift
		user_array.each do |user_row|
			User.create(email: user_row[3])
		end
	end

	task :create_fullcontact_profiles => :environment do 
		@limit = ENV["LIMIT"]
		@offset = ENV["OFFSET"]
		users = User.limit(@limit).offset(@offset)
		users.each do |user|
			@fc_profile = FullContactHelpers.new(user)
			@fc_profile.create_fc_profile
		end
	end

	task :create_clearbit_profiles => :environment do
		@limit = ENV["LIMIT"]
		@offset = ENV["OFFSET"]
		users = User.limit(@limit).offset(@offset)
		users.each do |user|
			@cb_profile = ClearbitHelpers.new(user)
			@cb_profile.create_cb_profile
		end
	end
end