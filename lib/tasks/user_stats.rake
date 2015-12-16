namespace :users do 

	task :name_failures => :environment do
		@users = User.limit(500)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter +=1 if @user_profiles[0].name == "n/a" && @user_profiles[1].name == "n/a"
		end
		puts "Name failures = #{counter}, successes = #{500 - counter}."
	end

	task :linkedin_failures => :environment do
		@users = User.limit(500)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter +=1 if @user_profiles[0].linkedin_url == nil && @user_profiles[1].linkedin_url == nil
		end
		puts "Name failures = #{counter}, successes = #{500 - counter}."
	end

	task :photo_url_failures => :environment do
		@users = User.limit(500)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].photo_url == nil && @user_profiles[1].photo_url == nil
		end
		puts "Photo failures = #{counter}, successes = #{500 - counter}."
	end

	task :company_failures => :environment do
		@users = User.limit(500)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].company == "n/a" && @user_profiles[1].company == "n/a"
		end
		puts "Company failures = #{counter}, successes = #{500 - counter}."
	end

	task :title_failures => :environment do
		@users = User.limit(500)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].title == "n/a" && @user_profiles[1].title == "n/a"
		end
		puts "Title failures = #{counter}, successes = #{500 - counter}."
	end

	task :tag_failures => :environment do
		@users = User.limit(500)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].tags == "n/a" && @user_profiles[1].tags == "n/a"
		end
	end

	task :name_success_overlap => :environment do
		@users = User.limit(500)

		counter = 0
		@users.each do |user|
			@user_profiles = user.profiles
			counter += 1 if @user_profiles[0].name != "n/a" && @user_profiles[1].name != "n/a"
		end
		puts "Name overlaps = #{counter}."
	end

	task :clearbit_success => :environment do
		@name = 500 - Profile.where(source:"Clearbit", name:"n/a").count
		@linkedin = 500 - Profile.where(source:"Clearbit", linkedin_url: nil).count
		@image = 500 - Profile.where(source:"Clearbit", photo_url: nil).count
		@company = 500 - Profile.where(source:"Clearbit", company: "n/a").count
		@title = 500 - Profile.where(source:"Clearbit", title: "n/a").count

		puts "Clearbit success: "
		puts "Name: #{@name}, Linkedin: #{@linkedin}, Image: #{@image}, Company: #{@company}, Title: #{@title}."
	end

	task :fullcontact_success => :environment do
		@name = 500 - Profile.where(source:"Fullcontact", name:"n/a").count
		@linkedin = 500 - Profile.where(source:"Fullcontact", linkedin_url: nil).count
		@image = 500 - Profile.where(source:"Fullcontact", photo_url: nil).count
		@company = 500 - Profile.where(source:"Fullcontact", company: "n/a").count
		@title = 500 - Profile.where(source:"Fullcontact", title: "n/a").count
		@tags = 500 - Profile.where(source:"Fullcontact", tags: "n/a").count

		puts "Fullcontact success: "
		puts "Name: #{@name}, Linkedin: #{@linkedin}, Image: #{@image}, Company: #{@company}, Title: #{@title}."
	end
end