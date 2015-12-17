require 'csv'

namespace :users do
	
	task :load_uber_users => :environment do
		user_array = CSV.read("./db/uber-users.csv")

		user_array.shift
		user_array.each do |user_row|
			@user = User.find_by(email: user_row[3])
			# if !@user
			# 	user = User.create(email: user_row[3])
			# 	clearbit = ClearbitHelpers.new(user)
			# 	clearbit.create_cb_profile
			# 	user.profiles.create(name:"#{user_row[1]} #{user_row[2]}",
			# 											 title: user_row[4],
			# 											 company: user_row[5],
			# 											 linkedin_url: user_row[6],
			# 											 source: "Salestool")
			# end
			if !@user
				@user = User.create(email: user_row[3])
			end
			@user.profiles.create(name: "#{user_row[1]} #{user_row[2]}",
														title: user_row[4],
														company: user_row[5],
														linkedin_url: user_row[6],
														source: "Salestool")
			fullcontact = FullContactHelpers.new(@user)
			fullcontact.create_fc_profile
		end
	end
end