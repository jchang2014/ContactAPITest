class User < ActiveRecord::Base
	has_many :profiles
	has_many :responses
	has_many :prospector_profiles
end
