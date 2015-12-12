class UsersController < ApplicationController
	include ClearbitHelpers

	def index
		@users = User.all
	end

	def show
		@user = User.find_by(email: params[:q])

		@user = User.create(email: params[:q]) if !@user

		#@cb_profile = @user.profiles.find_by(source:"Clearbit")
		#create_cb_profile(@user) if !@cb_profile

		@fc_profile = @user.profiles.find_by(source:"Fullcontact")
		if !@fc_profile
			@fc_profile = FullContactHelpers.new(@user)
			@fc_profile.create_fc_profile 
		end
	end

end
