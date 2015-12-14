class AddResponseToProfiles < ActiveRecord::Migration
  def change
  	add_column :profiles, :status, :integer
  end
end
