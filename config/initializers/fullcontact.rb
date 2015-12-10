require 'fullcontact'

FullContact.configure do |config|
    config.api_key = ENV['FB_KEY']
end