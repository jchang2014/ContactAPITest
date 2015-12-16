class AddUserIdToProspectorProfiles < ActiveRecord::Migration
  def change
  	add_column :prospector_profiles, :user_id, :integer
  end
end
