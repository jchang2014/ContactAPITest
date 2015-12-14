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

	task :create_fullcontact_profiles do 
		#For each user in database (Limit 500 calls, but let's limit to 100)
		#1. Query FC with user email
		#2. Save response to response table
		#3. Create profile from response data
		#Input: User email
		#Output: Profile saved to DB
		users = User.limit(100)
		users.each do |user|
			@fc_profile = FullContactHelpers.new(user)
			@fc_profile.create_fc_profile
		end
	end

	task :create_clearbit_profiles do
		#For up to 50 users in database (Need to do this 2 times with 2 keys to hit 100)
		#1. Query CB with user email
		#2 Save response to response table
		#3. Create profile from response data
		#Input: User email
		#Output: Profile saved to DB
		users = User.limit(100)
		users.each do |user|
			@cb_profile = ClearbitHelpers.new(user)
			@cb_profile.create_cb_profile
		end
	end
end