class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.integer :concierge_id
      t.string :email

      t.timestamps null: false
    end
  end
end
