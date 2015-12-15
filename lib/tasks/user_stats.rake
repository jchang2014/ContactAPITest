namespace :users do 

	task :photo_url_failures => :environment do
		@users = User.limit(100)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].photo_url == nil && @user_profiles[1].photo_url == nil
		end
		puts "Photo failures = #{counter}"
	end

	task :company_failures => :environment do
		@users = User.limit(100)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].company == "n/a" && @user_profiles[1].company == "n/a"
		end
		puts "Company failures = #{counter}"
	end

	task :title_failures => :environment do
		@users = User.limit(100)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].title == "n/a" && @user_profiles[1].title == "n/a"
		end
		puts "Title failures = #{counter}"
	end

	task :name_success_overlap => :environment do
		@users = User.limit(100)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].name != "n/a" && @user_profiles[1].name != "n/a"
		end
		puts "Name overlaps = #{counter}"
	end
end