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
		#For each user in database (Limit 500 calls, but let's limit to 150)
		#1. Query FC with user email
		#2. Save response to response table
		#3. Create profile from response data
		#Input: User email
		#Output: Profile saved to DB
		users = User.limit(100)
		users.each do |user|
			
		end
	end

	task :create_clearbit_profiles do
		keys = []

		rows.each_slice(3) do |chunk|

			chunk.each_with_index do |row, i|
				key = keys[i]
				FulllContactHelpers.new(row, key)
			end
		end
		#For up to 50 users in database (Need to do this 3 times with 3 keys to hit 150)
		#1. Query CB with user email
		#2 Save response to response table
		#3. Create profile from response data
		#Input: User email
		#Output: Profile saved to DB
	end
end