class RemoveConciergeIdFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :concierge_id
  end
end
