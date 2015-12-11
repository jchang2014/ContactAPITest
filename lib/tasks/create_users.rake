namespace :users do 
	task :create_users do 
		#1.Open csv file
		#2.Read each line for email, create user with just the email param
		#3.Close csv file
		#Input: CSV file
		#Output: Users seeded to DB
	end

	task :create_fullcontact_profiles do 
		#For each user in database (Limit 500 calls, but let's limit to 150)
		#1. Query FC with user email
		#2. Save response to response table
		#3. Create profile from response data
		#Input: User email
		#Output: Profile saved to DB
	end

	task :create_clearbit_profiles do
		#For up to 50 users in database (Need to do this 3 times with 3 keys to hit 150)
		#1. Query CB with user email
		#2 Save response to response table
		#3. Create profile from response data
		#Input: User email
		#Output: Profile saved to DB
	end
end