require 'csv'

class UsersController < ApplicationController
	def index
		@users = []
		csv_array = CSV.read("./db/uber-users.csv")
		csv_array.shift
		csv_array.each do |user_row|
			user = User.find_by(email: user_row[3])
			@users.push(user)
		end
		@users
	end

	def show
		@user = User.find_by(email: params[:q])

		@user = User.create(email: params[:q]) if !@user

		@cb_profile = @user.profiles.find_by(source:"Clearbit")
		if !@cb_profile
			@cb_profile = ClearbitHelpers.new(@user)
			@cb_profile.create_cb_profile
		end

		@fc_profile = @user.profiles.find_by(source:"Fullcontact")
		if !@fc_profile
			@fc_profile = FullContactHelpers.new(@user)
			@fc_profile.create_fc_profile 
		end
	end

end
