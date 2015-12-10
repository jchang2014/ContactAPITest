require 'fullcontact'

FullContact.configure do |config|
    config.api_key = ENV['FC_KEY']
end